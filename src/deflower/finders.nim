## Look through the decoded code, after the flow analysis, for address
## setups (issue 0074), self-modifying code (issue 0106) and copy loops
## (issue 0137).

import std/[algorithm, sets, tables]
import mpu6502
import printing, subject, cross_references

proc isAddressVariable(subject: Subject, address: int): bool =
  ## True when an addr element starts at `address`: the only memory an
  ## address setup stores to, since two adjacent bytes, even a word, can
  ## just as well hold two colors, two characters or a number.
  let area = subject.peek(address)
  area.isData and area.address == address and area.dataType == dtAddr

proc storedImmediate(subject: Subject, load, store: int): int =
  ## Where the store at `store` puts the value the immediate load at `load`
  ## gave its register, or -1 when they aren't such a pair.
  let loadInstruction = subject.memory[load].area.instruction
  let storeInstruction = subject.memory[store].area.instruction
  if loadInstruction.addressingMode != AddressingMode.Immediate:
    return -1
  let matchingStore = case loadInstruction.opcode
    of Opcode.LDA: Opcode.STA
    of Opcode.LDX: Opcode.STX
    of Opcode.LDY: Opcode.STY
    else: return -1
  if storeInstruction.opcode != matchingStore:
    return -1
  case storeInstruction.addressingMode
  of AddressingMode.ZeroPage: subject.memory[store + 1].data
  of AddressingMode.Absolute: word(subject.memory[store + 1].data, subject.memory[store + 2].data)
  else: -1

proc findAddressSetups*(subject: Subject) =
  ## Finds the code that stores the two halves of a constant address (issue
  ## 0074): four instructions in a row, each half an immediate load and a
  ## store of the same register, the halves in either order, stored to the
  ## two bytes of an addr. A label on the second, third or fourth
  ## instruction ends the match, since the code can be entered there, and
  ## an instruction is part of one match at most. The built address is
  ## labelled like a data reference, and the writer prints the immediates
  ## as `#<label` and `#>label` (issue 0034). All matches are found before
  ## any label is added, so a new label doesn't end another match.
  var address = 0
  while address < memorySize:
    var starts: array[4, int]
    var next = address
    var i = 0
    while i < 4 and next < memorySize:
      let area = subject.memory[next].area
      if not area.isInstruction or area.address != next or (i > 0 and subject.memory[next].label != nil):
        break
      starts[i] = next
      next += area.size
      inc i
    block match:
      if i < 4:
        break match
      let store1 = subject.storedImmediate(starts[0], starts[1])
      let store2 = subject.storedImmediate(starts[2], starts[3])
      if store1 == -1 or store2 == -1:
        break match
      if not subject.isAddressVariable(min(store1, store2)):
        break match
      var low, high: int
      if store2 == store1 + 1:
        low = starts[0]
        high = starts[2]
      elif store1 == store2 + 1:
        low = starts[2]
        high = starts[0]
      else:
        break match
      let built = word(subject.memory[low + 1].data, subject.memory[high + 1].data)
      subject.lowByteSetups[low] = built
      subject.highByteSetups[high] = built
      # The loop's own increment then lands on the next instruction.
      address = next - 1
    inc address
  for low, built in subject.lowByteSetups:
    subject.labelDataReference(built, low)

proc resolveSelfModNames(subject: Subject) =
  ## Finds the label each selfmod line names (issue 0106), a .flo label or a
  ## banked name, into `selfModLabels`. A line that isn't on an instruction
  ## with an address operand, or names no such label, is an error; one on an
  ## instruction no traced code writes is a warning.
  var addressByName: Table[string, int]
  for location in subject.memory:
    if location.banked != nil and location.banked.name notin addressByName:
      addressByName[location.banked.name] = location.address
    if location.label != nil and not location.label.auto and location.label.name notin addressByName:
      addressByName[location.label.name] = location.address
  var addresses: seq[int]
  for address in subject.selfModNames.keys:
    addresses.add address
  addresses.sort()
  for address in addresses:
    let name = subject.selfModNames[address]
    let area = subject.memory[address].area
    if not area.isInstruction or area.address != address or area.target(subject) == -1 or
        area.instruction.addressingMode == AddressingMode.Relative:
      subject.errors.add "Selfmod line at " & asHexWord(address) & ": no instruction with an address operand there"
      continue
    if name notin addressByName:
      subject.errors.add "Selfmod line at " & asHexWord(address) & " names " & name & ", which is no label"
      continue
    let labelAddress = addressByName[name]
    if not subject.operandModified(address):
      # Not an error: the code that writes it may not be traced yet.
      subject.warn(address, "selfmod line, but no traced instruction writes the operand")
    subject.selfModLabels[address] = labelAddress
    let banked = subject.memory[labelAddress].banked
    if banked != nil and banked.name == name:
      subject.usedBanked.incl labelAddress

proc findSelfModifications*(subject: Subject) =
  ## Records each instruction whose operand bytes an instruction writes to,
  ## with the writers, in `operandWriters`. The operand of such an
  ## instruction holds whatever it held when the image was taken, so it
  ## names nothing: the auto labels only it made are dropped. A branch
  ## offset stays, since its target is code either way.
  for location in subject.memory:
    let writer = location.area
    if not writer.isInstruction or writer.address != location.address:
      continue
    if not writer.instruction.changesTarget:
      continue
    let target = writer.target(subject)
    let written = if target == -1: nil else: subject.memory[target].area
    if written.isInstruction and written.address != target and
        written.instruction.addressingMode != AddressingMode.Relative:
      let writers = addr subject.operandWriters.mgetOrPut(written.address, @[])
      if writer.address notin writers[]:
        writers[].add writer.address
        writers[].sort()
  subject.resolveSelfModNames()
  let referenced = subject.referencedAddresses()
  for address in subject.operandWriters.keys:
    let target = subject.memory[address].area.target(subject)
    let label = if target == -1: nil else: subject.memory[target].label
    if label != nil and label.auto and target notin referenced:
      subject.memory[target].label = nil

proc instructionAt(subject: Subject, address: int): Area =
  if address < 0 or address >= memorySize:
    return nil
  let area = subject.peek(address)
  if area.isInstruction and area.address == address: area else: nil

proc copyRange(subject: Subject, loadAt: int): tuple[source, target, first, finish: int] =
  ## The copy loop whose load is the instruction at `loadAt` (issue 0137):
  ## `lda source, x|y`, maybe a `beq` out on a zero byte, `sta target` on the
  ## same index, the index stepped and a branch back. Returns the offsets
  ## from `first` to `finish` (exclusive) the loop copies, or `source` -1.
  result.source = -1
  let load = subject.instructionAt(loadAt)
  if load == nil or load.instruction.opcode != Opcode.LDA or
      load.instruction.addressingMode notin {AddressingMode.AbsoluteX, AddressingMode.AbsoluteY}:
    return
  let mode = load.instruction.addressingMode
  let byX = mode == AddressingMode.AbsoluteX
  var address = loadAt + 3
  var untilZero = false
  var target = -1
  var step = 0
  var compare = -1
  for count in 0 ..< 6:
    let area = subject.instructionAt(address)
    if area == nil:
      return
    let instruction = area.instruction
    case instruction.opcode
    of Opcode.BEQ:
      if target == -1:
        untilZero = true
    of Opcode.STA:
      if instruction.addressingMode != mode:
        return
      target = subject.wordAt(address + 1)
    of Opcode.DEX, Opcode.DEY, Opcode.INX, Opcode.INY:
      if (instruction.opcode in {Opcode.DEX, Opcode.INX}) != byX:
        return
      step = if instruction.opcode in {Opcode.DEX, Opcode.DEY}: -1 else: 1
    of Opcode.CPX, Opcode.CPY:
      if instruction.addressingMode != AddressingMode.Immediate or (instruction.opcode == Opcode.CPX) != byX:
        return
      compare = subject.byteAt(address + 1)
    of Opcode.BNE, Opcode.BPL, Opcode.JMP:
      let back = if instruction.opcode == Opcode.JMP: subject.wordAt(address + 1)
                 else: address + 2 + toSignedByte(subject.byteAt(address + 1))
      if back > loadAt or target == -1 or step == 0:
        return
      # The index's start: an immediate load right before the loop.
      let before = subject.instructionAt(back - 2)
      if before == nil or before.instruction.addressingMode != AddressingMode.Immediate or
          before.instruction.opcode != (if byX: Opcode.LDX else: Opcode.LDY):
        return
      let start = subject.byteAt(back - 1)
      let source = subject.wordAt(loadAt + 1)
      var first, finish: int
      if untilZero:
        if step != 1:
          return
        first = start
        finish = start
        while source + finish < memorySize and subject.memory[source + finish].loaded and
            subject.byteAt(source + finish) != 0:
          inc finish
      elif step == -1 and instruction.opcode == Opcode.BPL and start < 0x80:
        (first, finish) = (0, start + 1)
      elif step == -1 and instruction.opcode == Opcode.BNE:
        (first, finish) = if start == 0: (0, 256) else: (1, start + 1)
      elif step == 1 and instruction.opcode == Opcode.BNE:
        (first, finish) = (start, if compare == -1: 256 else: compare)
      else:
        return
      if finish <= first:
        return
      return (source, target, first, finish)
    else:
      return
    address += instruction.addressingMode.totalBytes

proc findCopyLoops*(subject: Subject) =
  ## Hints at the loops that copy a block of the image to memory the image
  ## doesn't load and that code calls or jumps into (issue 0137), with the
  ## load line that puts the block there, so its code is traced where it
  ## runs.
  var called: HashSet[int]
  for location in subject.memory:
    let area = location.area
    if area.isInstruction and area.address == location.address and
        area.instruction.opcode in {Opcode.JSR, Opcode.JMP} and
        area.instruction.addressingMode == AddressingMode.Absolute:
      called.incl subject.wordAt(location.address + 1)
  for location in subject.memory:
    let (source, target, first, finish) = subject.copyRange(location.address)
    if source == -1:
      continue
    let (start, to) = (source + first, source + finish)
    let (at, atEnd) = (target + first, target + finish)
    if to > memorySize or atEnd > memorySize:
      continue
    var sourceLoaded, targetLoaded = true
    for a in start ..< to:
      sourceLoaded = sourceLoaded and subject.memory[a].loaded
    for a in at ..< atEnd:
      targetLoaded = targetLoaded and subject.memory[a].loaded
    var calledThere = false
    for a in at ..< atEnd:
      calledThere = calledThere or a in called
    if not sourceLoaded or targetLoaded or not calledThere:
      continue
    let range = asHexWord(start) & "-" & asHexWord(to)
    var line = "hint: " & asHexWord(location.address) & " copies " & range & " to " & asHexWord(at) & "-" &
        asHexWord(atEnd)
    for file in subject.loadedFiles:
      if file.plainPrg and start >= file.start and to <= file.finish:
        line = line & ": load " & file.name & " " & range & " at " & asHexWord(at)
    subject.hints.add (location.address, line)
