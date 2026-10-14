## Which instructions refer to each label (issue 0076), printed as comment
## lines above it: "called by: game_loop, l336F". A reference is listed at
## the label its operand prints, so one into an array is listed at the
## array's label. The referrer is named by the nearest routine label at or
## before its instruction, skipping local labels (issue 0084), each once
## per kind, and a label referring to itself (a loop back to its own start)
## is left out.

import std/tables
import mpu6502
import printing, subject

type
  ReferenceKind* = enum
    rkCall = "called by"
    rkJump = "jumped to by"
    rkRead = "read by"
    rkWrite = "written by"
    rkModify = "modified by"

  Referrers = array[ReferenceKind, seq[string]]
    ## The names, in the order they were found, without doubles.

  CrossReferences* = object
    referrersByLabelAddress: Table[int, Referrers]
    referrersByBankedAddress: Table[int, Referrers]
      ## The references to banked names (issue 0102), by their address: the
      ## RAM's own label there may have references of its own.

const
  writes = {Opcode.STA, Opcode.STX, Opcode.STY, Opcode.SAX, Opcode.AHX, Opcode.SHX, Opcode.SHY, Opcode.TAS}
  modifies = {Opcode.INC, Opcode.DEC, Opcode.ASL, Opcode.LSR, Opcode.ROL, Opcode.ROR, Opcode.SLO, Opcode.RLA,
      Opcode.SRE, Opcode.RRA, Opcode.DCP, Opcode.ISC}

proc kind*(instruction: Instruction): ReferenceKind =
  ## What the instruction does with the address its operand names. An
  ## indirect mode only reads the pointer there, whatever the instruction
  ## does with the memory it points to.
  case instruction.addressingMode
  of AddressingMode.IndX, AddressingMode.IndY, AddressingMode.Indirect:
    return rkRead
  of AddressingMode.Relative:
    return rkJump
  else:
    discard
  let opcode = instruction.opcode
  if opcode == Opcode.JSR: rkCall
  elif opcode == Opcode.JMP: rkJump
  elif opcode in writes: rkWrite
  elif opcode in modifies: rkModify
  else: rkRead

proc changesTarget*(instruction: Instruction): bool =
  ## True when the instruction writes or modifies the memory its operand
  ## names, not only a pointer there.
  instruction.kind in {rkWrite, rkModify}

proc referrerAddress(area: Area, subject: Subject): int =
  ## The address of the nearest routine label at or before the instruction
  ## in `area`, looking back through the instructions right before it, and
  ## past the inline data of a call (issue 0068), or -1 when that code has
  ## none.
  var current = area
  while true:
    let location = subject.memory[current.address]
    if location.label != nil and not location.label.local:
      return current.address
    var previous = if current.address > 0: subject.peek(current.address - 1) else: nil
    if current.address in subject.callsByReturnAddress:
      previous = subject.peek(subject.callsByReturnAddress[current.address])
    if not previous.isInstruction:
      return -1
    current = previous

proc referrerName*(area: Area, subject: Subject): string =
  ## The routine label of the code the instruction in `area` is in, or its
  ## address.
  let address = referrerAddress(area, subject)
  if address != -1: subject.memory[address].labelName else: asHexWord(area.address)

proc addName(referrers: var Referrers, kind: ReferenceKind, name: string) =
  if name notin referrers[kind]:
    referrers[kind].add name

proc add(references: var CrossReferences, area: Area, subject: Subject) =
  var target = area.target(subject)
  let named = area.address in subject.selfModLabels
  if named:
    # A selfmod line (issue 0106) names the label itself.
    target = subject.selfModLabels[area.address]
  elif target == -1 or subject.operandModified(area.address):
    return
  let referrerAddress = referrerAddress(area, subject)
  let referrer = if referrerAddress != -1: subject.memory[referrerAddress].labelName else: asHexWord(area.address)
  let banked = subject.memory[target].banked
  if (if named: banked != nil and banked.name == subject.selfModNames[area.address]
      else: subject.bankedTarget(area) != -1):
    references.referrersByBankedAddress.mgetOrPut(target, default(Referrers)).addName(area.instruction.kind, referrer)
    return
  let targetArea = subject.peek(target)
  let labelAddress = if targetArea != nil: targetArea.labelAddressFor(target, subject)
                     elif subject.memory[target].label != nil: target
                     else: -1
  if labelAddress == -1 or labelAddress == referrerAddress:
    return
  references.referrersByLabelAddress.mgetOrPut(labelAddress, default(Referrers)).addName(area.instruction.kind,
      referrer)

proc newCrossReferences*(subject: Subject): CrossReferences =
  for location in subject.memory:
    if location.area.isInstruction and location.area.address == location.address:
      result.add(location.area, subject)

proc lines(referrers: Referrers): seq[string] =
  for kind in ReferenceKind:
    if referrers[kind].len > 0:
      var line = $kind & ": "
      for i, name in referrers[kind]:
        if i > 0:
          line.add ", "
        line.add name
      result.add line

proc linesFor*(references: CrossReferences, address: int): seq[string] =
  ## The comment lines listing the references to the label at `address`,
  ## one per kind, or none.
  if address in references.referrersByLabelAddress:
    result = lines(references.referrersByLabelAddress[address])

proc bankedLinesFor*(references: CrossReferences, address: int): seq[string] =
  ## The comment lines listing the jumps and calls to the banked name at
  ## `address` (issue 0102), one per kind, or none.
  if address in references.referrersByBankedAddress:
    result = lines(references.referrersByBankedAddress[address])
