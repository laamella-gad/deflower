## Turns a list of assemblables (instructions, data, labels, origins) into
## segments of bytes. Values are 32-bit and wrap like a Java int.

import std/[options, tables]
import specification, segment

type
  AssemblerError* = object of CatchableError
    ## An error while assembling: a value out of range, an undefined value,
    ## addresses that don't settle.

  Value* = proc (): Option[int32] {.closure.}
    ## A value that is looked up when it is asked for, so it can refer to
    ## symbols defined later. None while it is unknown.

  AssemblableKind* = enum
    akOrg, akVirtual, akEndVirtual, akDefine, akLabel, akInstruction, akValues, akFill, akBytes, akWords

  Assemblable* = ref object
    address*: Option[int32]
    sourceLine*: int
      ## The line of the source text this came from, or 0 when it was built in code.
    case kind*: AssemblableKind
    of akDefine:
      defineName: string
      value: Value
    of akLabel:
      labelName: Option[string]
    of akInstruction:
      opcode: int
      zeroPageOpcode: int
        ## The opcode to use instead when the operand is below $100, or -1.
      relative: bool
        ## True when the operand is a branch target, assembled as an offset.
      operand: Value
    of akValues:
      width: int
      signed: bool
      values: seq[Value]
        ## A nil value reserves its bytes; they assemble to 0.
    of akFill:
      amountOfBytes: int
    of akBytes:
      bytes: seq[int]
    of akWords:
      words: seq[int]
    of akOrg, akVirtual, akEndVirtual:
      discard

  Assembler* = ref object
    assemblables: seq[Assemblable]
    symbols: Table[string, Assemblable]

const maxPasses = 20
  ## An instruction's size can depend on a value that depends on the size of
  ## instructions before it, so addresses are resolved again until they settle.

func lo(word: int32): int = int(word and 0xff)
func hi(word: int32): int = int((word shr 8) and 0xff)

proc where(assemblable: Assemblable): string =
  ## A prefix for error messages that says where this came from.
  if assemblable.sourceLine > 0: "line " & $assemblable.sourceLine & ": " else: ""

proc getAddress*(assemblable: Assemblable): Option[int32] =
  ## The address, or for a define its value.
  if assemblable.kind == akDefine: assemblable.value() else: assemblable.address

proc name*(label: Assemblable): Option[string] =
  label.labelName

proc constant*(value: int32): Value =
  ## A value that is known from the start.
  let constant = some(value)
  result = proc (): Option[int32] = constant

# Building assemblables.

proc label*(): Assemblable =
  Assemblable(kind: akLabel)

proc label*(name: string): Assemblable =
  ## A label that expressions can refer to by name, see `symbol`.
  Assemblable(kind: akLabel, labelName: some(name))

proc define*(name: string, value: Value): Assemblable =
  ## A name for the value of an expression, like `name = value` in source text.
  Assemblable(kind: akDefine, defineName: name, value: value)

proc org*(address: int32): Assemblable =
  Assemblable(kind: akOrg, address: some(address))

proc instruction*(opcode: int, operand: Value): Assemblable =
  Assemblable(kind: akInstruction, opcode: opcode, zeroPageOpcode: -1, operand: operand)

proc instruction*(opcode: int, operand: int32): Assemblable =
  instruction(opcode, constant(operand))

proc instruction*(opcode: int, target: Assemblable): Assemblable =
  instruction(opcode, proc (): Option[int32] = target.getAddress)

proc instruction*(opcode: int): Assemblable =
  instruction(opcode, proc (): Option[int32] = none(int32))

proc instruction*(absoluteOpcode, zeroPageOpcode: int, operand: Value): Assemblable =
  ## An instruction that uses its zero page opcode when the operand turns out
  ## to be below $100, and its absolute opcode otherwise.
  Assemblable(kind: akInstruction, opcode: absoluteOpcode, zeroPageOpcode: zeroPageOpcode, operand: operand)

proc branch*(opcode: int, target: Value): Assemblable =
  ## A branch to the target address, assembled as the offset from the next instruction.
  Assemblable(kind: akInstruction, opcode: opcode, zeroPageOpcode: -1, relative: true, operand: target)

proc bytes*(bytes: varargs[int]): Assemblable =
  Assemblable(kind: akBytes, bytes: @bytes)

proc words*(words: varargs[int]): Assemblable =
  Assemblable(kind: akWords, words: @words)

proc values*(width: int, signed: bool, values: seq[Value]): Assemblable =
  ## Values of the given width in bytes (1 to 4), little endian, from
  ## expressions, checked against the range of that width, signed or
  ## unsigned. A nil value reserves its bytes without a value.
  if width < 1 or width > 4:
    raise newException(AssemblerError, "A value is 1 to 4 bytes wide, not " & $width)
  Assemblable(kind: akValues, width: width, signed: signed, values: values)

proc virtual*(address: int32): Assemblable =
  ## Starts a block whose contents get addresses from the given one on, but
  ## produce no bytes, until the matching `endVirtual`. After it, the address
  ## continues where it was before the block.
  Assemblable(kind: akVirtual, address: some(address))

proc endVirtual*(): Assemblable =
  Assemblable(kind: akEndVirtual)

proc fill*(amountOfBytes: int): Assemblable =
  Assemblable(kind: akFill, amountOfBytes: amountOfBytes)

# Sizes and bytes.

proc selectedOpcode(instruction: Assemblable): int =
  ## The opcode this assembles to. While the operand is still unknown, that is the absolute one.
  if instruction.zeroPageOpcode != -1:
    let operand = instruction.operand()
    if operand.isSome and operand.get >= 0 and operand.get <= 0xff:
      return instruction.zeroPageOpcode
  instruction.opcode

proc byteSize*(assemblable: Assemblable): int =
  case assemblable.kind
  of akInstruction: addressingMode[assemblable.selectedOpcode].totalBytes
  of akValues: assemblable.width * assemblable.values.len
  of akFill: assemblable.amountOfBytes
  of akBytes: assemblable.bytes.len
  of akWords: assemblable.words.len * 2
  of akOrg, akVirtual, akEndVirtual, akDefine, akLabel: 0

proc assembleTo(assemblable: Assemblable, data: var seq[byte]) =
  case assemblable.kind
  of akInstruction:
    let selectedOpcode = assemblable.selectedOpcode
    data.add byte(selectedOpcode)
    let byteSize = assemblable.byteSize
    if byteSize > 1:
      let operand = assemblable.operand()
      if operand.isNone:
        raise newException(AssemblerError,
            assemblable.where & "the operand of " & opcodeName[selectedOpcode] & " is undefined")
      var oper = operand.get
      if assemblable.relative:
        oper = oper -% (assemblable.address.get +% 2)
        if oper < -128 or oper > 127:
          raise newException(AssemblerError,
              assemblable.where & "branch target is " & $oper & " bytes away, out of range")
      elif (if byteSize == 2: oper < -128 or oper > 0xff else: oper < 0 or oper > 0xffff):
        raise newException(AssemblerError, assemblable.where & "operand " & $oper & " is out of range")
      data.add byte(lo(oper))
      if byteSize > 2:
        data.add byte(hi(oper))
  of akValues:
    let width = assemblable.width
    let min = if assemblable.signed: -(1'i64 shl (width * 8 - 1)) else: 0'i64
    let max = if assemblable.signed: (1'i64 shl (width * 8 - 1)) - 1 else: (1'i64 shl (width * 8)) - 1
    for value in assemblable.values:
      var v = 0'i64
      if value != nil:
        let known = value()
        if known.isNone:
          raise newException(AssemblerError, assemblable.where & "a value is undefined")
        v = known.get
        if width == 4 and not assemblable.signed:
          # An int32 can't hold the top half of the unsigned range.
          v = v and 0xffffffff'i64
        if v < min or v > max:
          raise newException(AssemblerError,
              assemblable.where & "value " & $v & " is out of range " & $min & ".." & $max)
      for i in 0 ..< width:
        data.add byte((v shr (i * 8)) and 0xff)
  of akFill:
    for i in 0 ..< assemblable.amountOfBytes:
      data.add 0
  of akBytes:
    for b in assemblable.bytes:
      data.add byte(b and 0xff)
  of akWords:
    for w in assemblable.words:
      data.add byte(lo(int32(w)))
      data.add byte(hi(int32(w)))
  of akOrg, akVirtual, akEndVirtual, akDefine, akLabel:
    discard

# The assembler.

proc newAssembler*(): Assembler =
  Assembler()

proc add*(assembler: Assembler, assemblable: Assemblable) =
  ## Adds an assemblable. A named label or a define becomes a symbol.
  let name =
    if assemblable.kind == akLabel: assemblable.labelName
    elif assemblable.kind == akDefine: some(assemblable.defineName)
    else: none(string)
  if name.isSome:
    if name.get in assembler.symbols:
      raise newException(AssemblerError, assemblable.where & "Symbol " & name.get & " is already defined.")
    assembler.symbols[name.get] = assemblable
  assembler.assemblables.add assemblable

proc add*(assembler: Assembler, assemblables: varargs[Assemblable]) =
  for assemblable in assemblables:
    assembler.add assemblable

proc isDefined*(assembler: Assembler, name: string): bool =
  name in assembler.symbols

proc symbol*(assembler: Assembler, name: string): Value =
  ## The value of a symbol, looked up when it is asked for, so it can be
  ## added after this is called. None while the symbol is unknown or has no
  ## value yet.
  result = proc (): Option[int32] =
    if name in assembler.symbols: assembler.symbols[name].getAddress else: none(int32)

proc resolveAddresses(assembler: Assembler): bool =
  ## Gives every assemblable its address. Returns whether any address changed.
  var pc = none(int32)
  # The address to continue at after each open virtual block.
  var outerPcs: seq[Option[int32]]
  for assemblable in assembler.assemblables:
    case assemblable.kind
    of akOrg:
      pc = assemblable.address
    of akVirtual:
      outerPcs.add pc
      pc = assemblable.address
    of akEndVirtual:
      if outerPcs.len == 0:
        raise newException(AssemblerError, assemblable.where & "End of a virtual block that wasn't started.")
      pc = outerPcs.pop
    of akDefine:
      discard # Its value is its own.
    else:
      if pc.isNone:
        raise newException(AssemblerError, assemblable.where & "Cannot assemble without an org(...).")
      result = result or assemblable.address != pc
      assemblable.address = pc
      pc = some(pc.get +% int32(assemblable.byteSize))
  if outerPcs.len > 0:
    raise newException(AssemblerError, "A virtual block isn't ended.")

proc generateMachineCode(assembler: Assembler): seq[Segment] =
  var loadAddress = 0
  var data: seq[byte]
  var started = false
  var virtualDepth = 0
  for assemblable in assembler.assemblables:
    case assemblable.kind
    of akOrg:
      if started:
        result.add Segment(loadAddress: loadAddress, data: data)
      loadAddress = int(assemblable.address.get)
      data = @[]
      started = true
    of akVirtual:
      inc virtualDepth
    of akEndVirtual:
      dec virtualDepth
    else:
      if virtualDepth == 0 and started:
        assemblable.assembleTo(data)
  if started:
    result.add Segment(loadAddress: loadAddress, data: data)

proc assemble*(assembler: Assembler): seq[Segment] =
  ## Resolves the addresses and assembles the segments, one per org.
  var passes = 0
  while assembler.resolveAddresses():
    inc passes
    if passes == maxPasses:
      raise newException(AssemblerError, "Addresses don't settle after " & $maxPasses & " passes.")
  assembler.generateMachineCode()
