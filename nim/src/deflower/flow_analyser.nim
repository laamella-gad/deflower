## Follows the 6502 control flow from the code entries, decoding the
## instructions it reaches into instruction areas, and registers the data
## a routine's parameter list says follows each jsr to it (InlineData).

import std/[options, strutils, tables]
import mpu6502
import printing, subject

proc registerInlineData*(subject: Subject, jsrAddress, start: int, routine: Routine): int =
  ## Registers the data a routine's parameter list (issue 0068) says follows
  ## the jsr at `jsrAddress`, from `start` on, and returns where the call
  ## returns to: after that data. Data a .flo line already declared there
  ## wins, and the call returns after it. Returns -1, with a warning, when
  ## the data doesn't fit: no terminator before memory the image doesn't
  ## load, or running into an area.
  if routine.parameters.len == 0:
    return start
  let existing = if start < memorySize: subject.peek(start) else: nil
  if existing.isData and not existing.isPlaceholder and not existing.isVirtual:
    var finish = start
    while finish < memorySize and subject.peek(finish).isData and not subject.peek(finish).isPlaceholder and
        not subject.peek(finish).isVirtual:
      inc finish
    return finish
  var areas: seq[Area]
  var names: seq[string]
  var address = start
  for parameter in routine.parameters:
    let what = if parameter.name.len > 0: parameter.name else: $parameter.dataType
    var amount = parameter.amount
    if parameter.terminator != -1:
      amount = subject.countUntil(address, parameter.dataType.sizeInBytes, parameter.terminator)
      if amount == -1:
        subject.warn(jsrAddress, "no $" & hexDigits(parameter.terminator, 2) & " ends " & what &
            " after the jsr before memory the image doesn't load")
        return -1
    if parameter.lengthByte:
      if address >= memorySize or not subject.memory[address].loaded:
        subject.warn(jsrAddress, "the data after the jsr runs past the image")
        return -1
      amount = 1 + subject.byteAt(address)
    for i in 0 ..< amount:
      areas.add newDataArea(address, parameter.dataType, false, "", i, false, nil, parameter.terminator,
          parameter.lengthByte)
      address += parameter.dataType.sizeInBytes
    if parameter.name.len > 0:
      names.add parameter.name
  for a in start ..< address:
    if a >= memorySize or not subject.memory[a].loaded:
      subject.warn(jsrAddress, "the data after the jsr runs past the image")
      return -1
    let area = subject.peek(a)
    if area != nil and not area.isPlaceholder:
      subject.warn(jsrAddress, "the data after the jsr runs into " & (if area.isInstruction:
          "the instruction at " & asHexWord(area.address) else: "data at " & asHexWord(a)))
      return -1
  for area in areas:
    subject.registerArea(area)
  for area in areas:
    subject.addReturnAddress(area)
  if names.len > 0:
    subject.callComments[jsrAddress] = names.join(", ")
  address

proc warnFlow(subject: Subject, entry: CodeEntry, into, entryProblem: string) =
  ## Warns about flow into memory that isn't code to decode (issue 0077),
  ## at the instruction the flow comes from, or at a .flo code entry.
  var target = asHexWord(entry.address)
  var label = subject.memory[entry.address].labelName
  if label.len == 0 and subject.memory[entry.address].area != nil:
    label = subject.memory[entry.address].area.labelFor(entry.address, subject)
  if label.len > 0:
    target.add " (" & label & ")"
  if entry.source == -1:
    subject.warn(entry.address, "code entry " & entryProblem)
    return
  let origin = subject.memory[entry.source].area
  if origin.isData:
    subject.warn(entry.source, "rta " & target & " goes into " & into)
    return
  let mnemonic = toLowerAscii($origin.instruction.opcode)
  if entry.fallsThrough and origin.instruction.opcode == Opcode.JSR:
    # Often a routine that reads inline data after its jsr (0068).
    subject.warn(entry.source, mnemonic & " returns into " & into & " at " & target)
  elif entry.fallsThrough:
    subject.warn(entry.source, "falls through into " & into & " at " & target)
  else:
    subject.warn(entry.source, mnemonic & " " & target & " goes into " & into)

proc runsIntoExistingArea(subject: Subject, address: int, instruction: Instruction): bool =
  ## Decoding started cleanly at a free address, but a 2- or 3-byte
  ## instruction's own length can still run into an address another area
  ## already owns - typically a .flo-declared data area (issue 0023). Don't
  ## disassemble into it: this is the mirror case of jumping straight into
  ## a non-code area, caught the same way. Running past the end of the
  ## memory the image loads (issue 0065) is refused too.
  for offset in 1 ..< instruction.addressingMode.totalBytes:
    if address + offset > 0xffff or not subject.memory[address + offset].loaded:
      subject.warn(address, "the instruction runs past the image, not decoded")
      return true
    let existing = subject.memory[address + offset].area
    if existing != nil and not existing.isPlaceholder:
      let what = if existing.isInstruction: "the instruction at " & asHexWord(existing.address)
                 else: "data at " & asHexWord(address + offset)
      subject.warn(address, "the instruction runs into " & what & ", not decoded")
      return true
  false

proc absoluteOperand(subject: Subject, address: int): int =
  word(subject.memory[address + 1].data, subject.memory[address + 2].data)

proc relativeOperand(subject: Subject, address: int): int =
  address + toSignedByte(subject.memory[address + 1].data) + 2

proc analyseCodeFlow(subject: Subject, entry: CodeEntry) =
  let startAddress = entry.address
  let memoryLocation = subject.memory[startAddress]
  let area = memoryLocation.area
  if area != nil and not area.isPlaceholder:
    # Issue 0077: a virtual area, like a KERNAL routine, is code that isn't
    # in the image, so calling it is fine.
    if area.isData and not area.isVirtual:
      subject.warnFlow(entry, "data", "is data")
    elif area.isInstruction and area.address != startAddress:
      let instruction = "the instruction at " & asHexWord(area.address)
      subject.warnFlow(entry, "the middle of " & instruction, "is inside " & instruction)
    return
  if not memoryLocation.loaded:
    # Issue 0065: what is there at run time isn't in the image, so there is
    # nothing to decode. The target keeps its label; one from the .flo file
    # says the user knows what is there.
    if memoryLocation.label == nil or memoryLocation.label.auto:
      subject.warnFlow(entry, "memory the image doesn't load", "is memory the image doesn't load")
    return
  let decoded = instructionByNr[memoryLocation.data]
  let address = memoryLocation.address
  if decoded.isNone:
    subject.warn(address, "jam ($" & hexDigits(memoryLocation.data, 2) & "), not decoded")
    return
  let instruction = decoded.get
  if subject.runsIntoExistingArea(address, instruction):
    return
  subject.registerArea(newInstructionArea(address, instruction))
  let next = address + instruction.addressingMode.totalBytes
  case instruction.opcode
  of Opcode.RTS, Opcode.RTI, Opcode.BRK:
    discard
  of Opcode.JSR:
    let target = subject.absoluteOperand(address)
    var returnAddress = next
    let routine = subject.routines.getOrDefault(target, nil)
    if routine != nil:
      returnAddress = subject.registerInlineData(address, returnAddress, routine)
      if returnAddress != -1 and routine.parameters.len > 0:
        subject.callsByReturnAddress[returnAddress] = address
    if returnAddress != -1 and (routine == nil or not routine.noReturn):
      subject.addPotentialCodeLocation(returnAddress, false, address)
    subject.addCallTarget(target, address)
  of Opcode.JMP:
    if instruction.addressingMode == AddressingMode.Indirect:
      # The operand is where the destination address is stored, not the
      # destination: mark that location as an addr and follow the address
      # stored there. A pointer a .flo line already declared, like a virtual
      # KERNAL vector, keeps its area, and one the image doesn't load holds
      # no address to follow.
      let addrLocation = subject.absoluteOperand(address)
      subject.ensureLabelled(addrLocation, "a", address)
      let existing = subject.peek(addrLocation)
      if existing == nil or existing.isPlaceholder:
        subject.registerArea(newDataArea(addrLocation, dtAddr, false, "", 0))
      if subject.memory[addrLocation].loaded and subject.memory[(addrLocation + 1) and 0xffff].loaded:
        subject.addPotentialCodeLocation(subject.wordAt(addrLocation), true, address)
    else:
      subject.addPotentialCodeLocation(subject.absoluteOperand(address), true, address)
  of Opcode.BCC, Opcode.BCS, Opcode.BEQ, Opcode.BMI, Opcode.BNE, Opcode.BPL, Opcode.BVC, Opcode.BVS:
    subject.addPotentialCodeLocation(subject.relativeOperand(address), true, address)
    subject.addPotentialCodeLocation(next, false, address)
  else:
    # Every control-flow instruction has its own case above, so an absolute
    # operand here is a data reference.
    if instruction.addressingMode in {AddressingMode.Absolute, AddressingMode.AbsoluteX, AddressingMode.AbsoluteY}:
      subject.labelDataReference(subject.absoluteOperand(address), address)
    subject.addPotentialCodeLocation(next, false, address)

proc analyseCodeFlows*(subject: Subject) =
  while subject.potentialCodeLocations.len > 0:
    subject.analyseCodeFlow(subject.potentialCodeLocations.pop())
