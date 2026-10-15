## Writes a Subject as 64tass assembly: ResultWriter walks the memory and
## drives AssemblyFileFormat, which owns the layout and the printing of
## each type; LineEmitter is the low-level writer.

import std/[strutils, tables]
import mpu6502
import printing, subject, cross_references

type
  LineEmitter = object
    ## Writes assembly text line by line, and is the one place that knows
    ## how a line starts and finishes: it tracks whether anything is on the
    ## current line yet, how many values a directive line like `.byte` or
    ## `.text` holds so far, and whether a string literal on it is still
    ## open. When to break, separate or glue lines is decided by its caller.
    text: string
    atLineStart: bool
      ## True right after a newLine - nothing has been written on the
      ## current line yet - false once any text is printed.
    column: int
      ## The number of values printed on the current line.
    inQuotes: bool
      ## True while a double-quoted literal is open on the current line;
      ## newLine closes it.

  AssemblyFileFormat = object
    output: LineEmitter
    crossReferences: CrossReferences
    lastArea: Area
    needsToReOrg: bool
    encoding: string
      ## The 64tass text encoding in effect at this point of the output;
      ## "none" is 64tass's own default.
    textArrayStart: int
      ## The text array being printed (the elements one .flo line
      ## declared), as an address range.
    textArrayEnd: int
    textDirective: string
      ## The directive of the .text, .null or .ptext line being printed.
    ptextOpened: bool
      ## True right after a .ptext line was opened on its length byte, which
      ## prints nothing: the next character goes onto that same line.

const textBytesPerLine = 32

# LineEmitter.

proc print(output: var LineEmitter, s: string) =
  output.text.add s
  output.atLineStart = false

proc closeQuotes(output: var LineEmitter) =
  if output.inQuotes:
    output.print("\"")
    output.inQuotes = false

proc newLine(output: var LineEmitter) =
  output.closeQuotes()
  output.text.add "\n"
  output.column = 0
  output.atLineStart = true

proc finishLine(output: var LineEmitter) =
  ## Closes the current line, unless nothing has been written on it yet.
  if not output.atLineStart:
    output.newLine()

proc indent(output: var LineEmitter) =
  output.print("\t\t")

proc item(output: var LineEmitter, value: string) =
  ## Prints one value of a directive line, separated from the previous one
  ## by a comma.
  output.closeQuotes()
  if output.column != 0:
    output.print(", ")
  output.print(value)
  inc output.column

proc quotedCharacter(output: var LineEmitter, character: char) =
  ## Prints one character as a value of a directive line, inside a
  ## double-quoted literal shared with the characters right before it.
  if not output.inQuotes:
    if output.column != 0:
      output.print(", ")
    output.print("\"")
    output.inQuotes = true
  output.print($character)
  inc output.column

# AssemblyFileFormat.

proc memoryByte(subject: Subject, address: int): int =
  ## The byte at `address`, or 0 past the end of memory.
  if address < memorySize: subject.memory[address].data else: 0

proc considerReOrg(f: var AssemblyFileFormat, address: int) =
  if f.needsToReOrg:
    f.output.newLine()
    f.output.print("*=" & asHexWord(address))
    f.needsToReOrg = false

proc printCommentLines(f: var AssemblyFileFormat, address: int, subject: Subject) =
  ## Prints the comment at `address` and the cross-references to its label
  ## (issue 0076), one "; " line each.
  for line in subject.memory[address].comment & f.crossReferences.linesFor(address):
    f.output.print("; " & line)
    f.output.newLine()

proc isSingleValueRun(address: int, area: Area, subject: Subject): bool =
  ## True when printing `area` at `address` produces just one value before
  ## the run breaks (the next address has its own label/comment, isn't the
  ## same kind of data, or isn't there at all) - the case where gluing the
  ## label onto its one data value (issue 0029) reads better than putting
  ## the label on its own line.
  not subject.continuesArray(area, address + area.size)

proc printAnnotation(f: var AssemblyFileFormat, address: int, label: string, currentArea: Area, subject: Subject) =
  ## Prints a comment (one output line per source line, each prefixed "; ",
  ## followed by the label's cross-references), a label (as "label:"),
  ## both, or neither, for the given address. Comment and label share one
  ## blank-line separator above them.
  ##
  ## Exception (issue 0027): when this address merely continues the same
  ## contiguous same-type data run as the address before it, skip the
  ## blank-line separator and put the label/comment on its own line
  ## instead. Within that, a single value glues onto the label's line, and
  ## several values get their own line (issue 0029).
  let afterOrigin = f.needsToReOrg
  f.considerReOrg(address)
  let sameKindAsPrevious = currentArea.isData and f.lastArea.isData and f.lastArea.dataType == currentArea.dataType
  let continuesRun = sameKindAsPrevious and f.lastArea.lastOccupiedAddress == address - 1
  # Issue 0073: execution falls through from the instruction before into
  # the code at this label, so no blank line suggests a break in the flow.
  # A label on data keeps its blank line.
  let fallsThrough = not afterOrigin and currentArea.isInstruction and f.lastArea.isInstruction and
      not f.lastArea.endsFlow
  f.output.finishLine()
  if not (continuesRun or fallsThrough):
    f.output.newLine()
  f.printCommentLines(address, subject)
  if label.len > 0:
    f.output.print(label & ":")
    if sameKindAsPrevious and not isSingleValueRun(address, currentArea, subject):
      f.output.newLine()
  if f.lastArea.isInstruction:
    # The instruction after this label isn't right after a flow end
    # anymore: printInstruction needs no blank line of its own.
    f.lastArea = nil

proc printDefines(f: var AssemblyFileFormat, addresses: seq[int], subject: Subject) =
  ## Prints the labels at `addresses` as address defines (issue 0028), each
  ## after its comment lines. The last define's line is left open, like
  ## any other printed content, for whatever prints next to close;
  ## forgetting the last area makes the next data start a fresh line.
  if addresses.len > 0:
    f.lastArea = nil
  for address in addresses:
    f.output.finishLine()
    f.printCommentLines(address, subject)
    let label = subject.memory[address].labelName
    if label.len > 0:
      f.output.print(label & " = " & asHexWord(address))

proc printBankedDefines(f: var AssemblyFileFormat, subject: Subject) =
  ## Prints the banked names (issue 0102) as address defines, each after
  ## its comment lines and the jumps and calls to it, at the top of the
  ## file: the memory at their addresses is the RAM's.
  var first = true
  for address in 0 ..< memorySize:
    if not subject.isPrintedBanked(address):
      continue
    let lines = subject.memory[address].bankedComment & f.crossReferences.bankedLinesFor(address)
    if not first and lines.len > 0:
      f.output.newLine()
    for line in lines:
      f.output.print("; " & line)
      f.output.newLine()
    f.output.print(subject.memory[address].banked.name & " = " & asHexWord(address))
    f.output.newLine()
    first = false

func reservationDirective(dataType: DataType): string =
  case dataType
  of dtByte, dtUnknown, dtScreencode, dtAscii: ".byte"
  of dtWord: ".word"
  of dtLong: ".long"
  of dtDword: ".dword"
  of dtAddr: ".addr"
  of dtRta: ".rta"
  of dtSbyte: ".char"
  of dtSword: ".sint"
  of dtSlong: ".lint"
  of dtSdword: ".dint"

proc printVirtualStretch(f: var AssemblyFileFormat, start: int, subject: Subject): int =
  ## Prints a stretch of consecutive virtual areas (issue 0046) as one
  ## 64tass `.virtual` block: memory the code uses but whose contents
  ## aren't part of the program. Nothing is emitted for it, but its labels,
  ## type and size survive as reservations - `.byte ?` for a single value,
  ## `.fill n` for a run of same-type elements - so references like
  ## `screen_ram + $50` still assemble. Returns the first address after the
  ## stretch.
  f.output.finishLine()
  f.output.newLine()
  f.output.print(".virtual " & asHexWord(start))
  f.output.newLine()
  var address = start
  while address < memorySize and subject.isVirtualAt(address):
    let area = subject.peek(address)
    let label = subject.memory[address].labelName
    f.printCommentLines(address, subject)
    if address != area.address:
      # A label landing inside a multi-byte element (the second byte of a
      # word): no reservation of its own to hang it on.
      if label.len > 0:
        f.output.print(label & " = " & asHexWord(address))
        f.output.newLine()
      inc address
      continue
    let finish = subject.endOfRun(area)
    let count = (finish - address) div area.size
    if label.len > 0:
      f.output.print(label & ":")
    if count == 1:
      f.output.indent()
      f.output.print(reservationDirective(area.dataType) & "\t?")
    else:
      if label.len > 0:
        f.output.newLine()
      f.output.indent()
      f.output.print(".fill\t" & $(finish - address))
    f.output.newLine()
    address = subject.firstAnnotatedAddressInside(address, finish)
  f.output.print(".endv")
  f.output.newLine()
  f.needsToReOrg = true
  f.lastArea = nil
  address

proc printExport(f: var AssemblyFileFormat, region: ExportRegion, subject: Subject): int =
  ## Prints a region exported to a binary file (issue 0022) as a 64tass
  ## `.binary` line, skipping a .prg file's load address, after the label
  ## and comment at its start. The labels inside it become address defines
  ## after it. Returns the first address after the region.
  f.considerReOrg(region.start)
  f.output.finishLine()
  f.output.newLine()
  f.printCommentLines(region.start, subject)
  let label = subject.memory[region.start].labelName
  if label.len > 0:
    f.output.print(label & ":")
    f.output.newLine()
  f.output.indent()
  f.output.print(".binary\t\"" & region.fileName & "\"" &
      (if region.headerSize != 0: ", " & $region.headerSize else: ""))
  f.lastArea = nil
  var inside: seq[int]
  for address in region.start + 1 ..< region.finish:
    if subject.isAnnotated(address):
      inside.add address
  f.printDefines(inside, subject)
  region.finish

proc nameForAddress(address: int, formatWhenNumeric: int, subject: Subject): string =
  ## The name of `address`, or the address as a number of
  ## `formatWhenNumeric` hex digits.
  let area = subject.memory[address].area
  let label = if area == nil:
      # Memory no area covers can still carry a label: a user label, or a
      # jump target whose instruction couldn't be decoded.
      subject.memory[address].labelName
    else:
      area.labelFor(address, subject)
  if label.len > 0: label else: "$" & hexDigits(address, formatWhenNumeric)

proc nameForAbsoluteAddress(address: int, subject: Subject): string =
  ## An absolute-mode operand. Below $100, 64tass would pick the shorter
  ## zero-page form, label or number alike, so `@w` forces the 16-bit one
  ## (issue 0053).
  let name = nameForAddress(address, 4, subject)
  if address < 0x100: "@w " & name else: name

proc nameForFlow(area: Area, target: int, subject: Subject): string =
  ## A jsr, jmp or branch target: the banked name there (issue 0102), else
  ## the RAM's.
  if subject.bankedTarget(area) != -1: subject.memory[target].banked.name
  else: nameForAddress(target, 4, subject)

proc nameForImmediate(address, value: int, subject: Subject): string =
  ## An immediate operand. The low or high byte of an address an address
  ## setup builds (issue 0074) is named `<label` or `>label` (issue 0034),
  ## but only for a label on that address itself: 64tass reads `<label + 1`
  ## as the low byte of the sum, mpu6502 as the low byte of the label plus
  ## one.
  let isLow = address in subject.lowByteSetups
  if isLow or address in subject.highByteSetups:
    let built = if isLow: subject.lowByteSetups[address] else: subject.highByteSetups[address]
    var label = subject.exactLabel(built)
    if label.len == 0:
      label = subject.bankedValueName(built)
    if label.len > 0:
      return (if isLow: "<" else: ">") & label
  "$" & hexDigits(value, 2)

proc operand(instruction: Instruction, zeroPage, absolute: string): string =
  ## The operand of the instruction, with `zeroPage` for a zero-page or
  ## immediate value and `absolute` for an absolute one.
  case instruction.addressingMode
  of AddressingMode.IndX: "(" & zeroPage & ", x)"
  of AddressingMode.IndY: "(" & zeroPage & "), y"
  of AddressingMode.Indirect: "(" & absolute & ")"
  of AddressingMode.Absolute: absolute
  of AddressingMode.AbsoluteX: absolute & ", x"
  of AddressingMode.AbsoluteY: absolute & ", y"
  of AddressingMode.Immediate: "#" & zeroPage
  of AddressingMode.ZeroPage: zeroPage
  of AddressingMode.ZeroPageX: zeroPage & ", x"
  of AddressingMode.ZeroPageY: zeroPage & ", y"
  of AddressingMode.Relative, AddressingMode.Jam, AddressingMode.Accumulator, AddressingMode.None:
    raise newException(StateError, "no operand to modify")

proc numericOperand(instruction: Instruction, byte1, word: int): string =
  ## The operand of an instruction whose operand other code writes (issue
  ## 0106), as numbers: what the image holds names nothing.
  operand(instruction, "$" & hexDigits(byte1, 2), (if word < 0x100: "@w $" else: "$") & hexDigits(word, 4))

proc namedOperand(area: Area, subject: Subject): string =
  ## The operand a selfmod line names (issue 0106): the label, plus or minus
  ## the distance to the value the image holds.
  let labelAddress = subject.selfModLabels[area.address]
  let value = area.target(subject)
  var name = subject.selfModNames[area.address]
  if value > labelAddress:
    name.add " + $" & hex(value - labelAddress)
  elif value < labelAddress:
    name.add " - $" & hex(labelAddress - value)
  let zeroPageForm = area.instruction.addressingMode in {AddressingMode.ZeroPage, AddressingMode.ZeroPageX,
      AddressingMode.ZeroPageY, AddressingMode.IndX, AddressingMode.IndY}
  operand(area.instruction, name, if zeroPageForm or value >= 0x100: name else: "@w " & name)

proc printInstruction(f: var AssemblyFileFormat, area: Area, subject: Subject) =
  let afterOrigin = f.needsToReOrg
  f.considerReOrg(area.address)
  if sameArea(area, f.lastArea):
    return
  if not afterOrigin and f.lastArea.isInstruction and f.lastArea.endsFlow:
    # Issue 0073: code right after a jmp, rts, rti or brk is only reached
    # some other way, so set it apart like a label there.
    f.output.finishLine()
    f.output.newLine()
  let instruction = area.instruction
  let byte1 = subject.memoryByte(area.address + 1)
  let byte2 = subject.memoryByte(area.address + 2)
  let word = word(byte1, byte2)
  let operand =
    if area.address in subject.selfModLabels: namedOperand(area, subject)
    elif subject.operandModified(area.address): numericOperand(instruction, byte1, word)
    else:
      case instruction.addressingMode
      of AddressingMode.IndX: "(" & nameForAddress(byte1, 2, subject) & ", x)"
      of AddressingMode.IndY: "(" & nameForAddress(byte1, 2, subject) & "), y"
      of AddressingMode.Relative: nameForFlow(area, area.address + toSignedByte(byte1) + 2, subject)
      of AddressingMode.Indirect: "(" & nameForAddress(word, 4, subject) & ")"
      of AddressingMode.Absolute:
        if subject.bankedTarget(area) != -1: nameForFlow(area, word, subject)
        else: nameForAbsoluteAddress(word, subject)
      of AddressingMode.AbsoluteX: nameForAbsoluteAddress(word, subject) & ", x"
      of AddressingMode.AbsoluteY: nameForAbsoluteAddress(word, subject) & ", y"
      of AddressingMode.Immediate: "#" & nameForImmediate(area.address, byte1, subject)
      of AddressingMode.ZeroPage: nameForAddress(byte1, 2, subject)
      of AddressingMode.ZeroPageX: nameForAddress(byte1, 2, subject) & ", x"
      of AddressingMode.ZeroPageY: nameForAddress(byte1, 2, subject) & ", y"
      of AddressingMode.Jam, AddressingMode.Accumulator, AddressingMode.None: ""
  # A comment or label right above has already closed its line.
  f.output.finishLine()
  f.output.indent()
  var comments: seq[string]
  let text = toLowerAscii($instruction.opcode) & " " & operand
  if assembledOpcode(instruction.nr) != instruction.nr:
    # Issue 0086: another opcode has this mnemonic and mode and is the one
    # an assembler picks, so this one prints as its bytes.
    var bytes: seq[string]
    for i in 0 ..< area.size:
      bytes.add asHexByte(subject.memoryByte(area.address + i))
    f.output.print(".byte\t" & bytes.join(", "))
    comments.add text.strip
  else:
    f.output.print(text)
  # The names of the inline data after this jsr (issue 0068).
  if area.address in subject.callComments:
    comments.add subject.callComments[area.address]
  if area.address in subject.operandWriters:
    # Issue 0106: the operand is only what the image holds.
    var names: seq[string]
    for writer in subject.operandWriters[area.address]:
      let name = referrerName(subject.memory[writer].area, subject)
      if name notin names:
        names.add name
    comments.add "operand set by " & names.join(", ")
  if comments.len > 0:
    f.output.print("\t; " & comments.join("; "))
  f.lastArea = area

proc tabularPrint(f: var AssemblyFileFormat, command, data: string) =
  if f.output.column == 16:
    f.output.newLine()
  if f.output.column == 0:
    f.output.indent()
    f.output.print(command & "\t")
  f.output.item(data)

proc characterFor(encoding: string, value: int): int =
  ## The character `value` is written as in a string under 64tass's
  ## `encoding` in its default raw mode (no `--ascii`), or -1 when there is
  ## none and it must be printed as hex. "none" is the identity; "screen"
  ## maps screen codes $00-$1F to "@A-Z[\]^_", $20-$3F to themselves and
  ## $40-$5E to "`a-z{|}~" (checked against 64tass 1.59). Reverse video
  ## ($80-$FF), $5F-$7F and the double quote, which would end the literal,
  ## have none.
  var character = value
  if encoding == "screen":
    if value <= 0x1f:
      character = value + 0x40
    elif value >= 0x40 and value <= 0x5e:
      character = value + 0x20
    elif value > 0x3f:
      return -1
  if character >= 0x20 and character <= 0x7e and character != ord('"'): character else: -1

proc textDirectiveFor(f: AssemblyFileFormat, area: Area, subject: Subject): string =
  ## The directive for a line of the current text array opening at `area`
  ## (issue 0094): `.ptext` at the start of an array sized by [lengthbyte],
  ## however long; `.null` for the line that ends an array sized by [until
  ## $00], when the rest of the array fits on the line; else `.text`. A
  ## comment inside the rest of the array would break the line, so it rules
  ## both out.
  let address = area.address
  for inside in address + 1 ..< f.textArrayEnd:
    if subject.memory[inside].comment.len > 0 and subject.memory[inside].label == nil:
      return ".text"
  if area.lengthByte:
    return if address == f.textArrayStart: ".ptext" else: ".text"
  if area.terminator == 0 and f.textArrayEnd - f.textArrayStart >= 2:
    return if f.textArrayEnd - 1 - address <= textBytesPerLine: ".null" else: ".text"
  ".text"

proc textPrint(f: var AssemblyFileFormat, area: Area, value: int, subject: Subject) =
  ## Prints one text value as an item of a 64tass `.text` line (issue
  ## 0039), the string counterpart of tabularPrint: consecutive printable
  ## characters share one double-quoted literal, anything else becomes a
  ## hex item, e.g. `.text "AB", $0D, "C"`. Wraps every textBytesPerLine
  ## values.
  ##
  ## A screencode value is read as a Commodore screen code, an ascii one as
  ## Commodore ASCII (issue 0094). A line opening under a different
  ## encoding than the one in effect first switches it with `.enc`, so the
  ## output reassembles to the same bytes; the next array in another
  ## encoding starts a new line.
  ##
  ## An array sized by [until $00] ends in a `.null` line, and one sized by
  ## [lengthbyte] is a `.ptext` (textDirectiveFor); the terminator and the
  ## length byte then print as nothing.
  let newArray = area.address < f.textArrayStart or area.address >= f.textArrayEnd
  if newArray:
    f.textArrayStart = area.arrayStart
    f.textArrayEnd = subject.endOfArray(area)
  let valueEncoding = if area.dataType == dtScreencode: "screen" else: "none"
  let continuesPtext = f.ptextOpened
  f.ptextOpened = false
  # A .ptext string can't be split, so it makes one long line. A .null or
  # .ptext line holds one array, which then opens its own.
  let wraps = f.textDirective != ".ptext"
  let ownLine = newArray and (f.textDirective != ".text" or area.lengthByte or area.terminator == 0)
  if (wraps and f.output.column == textBytesPerLine) or
      (f.output.column != 0 and (ownLine or valueEncoding != f.encoding)):
    f.output.newLine()
  if f.output.column == 0 and not continuesPtext:
    if valueEncoding != f.encoding:
      f.output.indent()
      f.output.print(".enc\t\"" & valueEncoding & "\"")
      f.output.newLine()
      f.encoding = valueEncoding
    f.textDirective = f.textDirectiveFor(area, subject)
    f.output.indent()
    f.output.print(f.textDirective & "\t")
    if f.textDirective == ".ptext":
      if f.textArrayEnd == area.address + 1:
        f.output.print("\"\"")
        f.output.newLine()
        return
      f.ptextOpened = true
      return
  if f.textDirective == ".null" and area.address == f.textArrayEnd - 1:
    return
  let character = characterFor(valueEncoding, value)
  if character != -1:
    f.output.quotedCharacter(char(character))
  else:
    f.output.item(asHexByte(value))

proc printData(f: var AssemblyFileFormat, area: Area, address: int, subject: Subject) =
  # A multi-byte area (word, long, dword, addr, ...) owns several
  # consecutive addresses but is one value: print it once, at its first
  # address.
  if address != area.address:
    return
  f.considerReOrg(address)
  if not f.lastArea.isData or area.dataType != f.lastArea.dataType:
    f.output.newLine()
  case area.dataType
  of dtByte, dtUnknown:
    f.tabularPrint(".byte", asHexByte(subject.byteAt(address)))
  of dtScreencode, dtAscii:
    f.textPrint(area, subject.byteAt(address), subject)
  of dtWord:
    f.tabularPrint(".word", asHexWord(subject.wordAt(address)))
  of dtLong:
    f.tabularPrint(".long", asHexLong(subject.longAt(address)))
  of dtDword:
    f.tabularPrint(".dword", asHexDword(subject.dwordAt(address)))
  of dtAddr:
    # 64tass's .addr is specifically "a 16-bit address constant" (issue
    # 0036) - more precise than .word for a value that's always an
    # address, not an arbitrary 16-bit number.
    let bankedValue = subject.bankedValueName(subject.wordAt(address))
    f.tabularPrint(".addr", if bankedValue.len > 0: bankedValue
                            else: nameForAddress(subject.wordAt(address), 4, subject))
  of dtRta:
    # 64tass stores the label minus one (issue 0038).
    let returnAddress = subject.returnAddressAt(address)
    let banked = subject.memory[returnAddress].banked
    f.tabularPrint(".rta", if banked != nil: banked.name else: nameForAddress(returnAddress, 4, subject))
  of dtSbyte:
    f.tabularPrint(".char", $int(cast[int8](subject.byteAt(address))))
  of dtSword:
    f.tabularPrint(".sint", $int(cast[int16](subject.wordAt(address))))
  of dtSlong:
    # Sign-extend the 24-bit value.
    let value = subject.longAt(address)
    f.tabularPrint(".lint", $(if value >= 0x800000: value - 0x1000000 else: value))
  of dtSdword:
    f.tabularPrint(".dint", $subject.dwordAt(address))
  f.lastArea = area

# ResultWriter.

proc continuesPrevious(area: Area, address: int, subject: Subject): bool =
  ## True when `address` carries on what the address before it printed: it
  ## lies inside the same area (a multi-byte element, an instruction's
  ## operand), or starts the next element of the same array.
  if area == nil or address == 0:
    return false
  let previous = subject.peek(address - 1)
  if area == previous:
    return true
  previous.isData and subject.continuesArray(previous, address)

proc writeAssembly*(subject: Subject): string =
  ## The subject as 64tass assembly.
  ##
  ## Labels that would interrupt what is being printed become address
  ## defines instead (issue 0028): a label inside a declared array, inside
  ## a multi-byte element or on an instruction's operand byte is printed as
  ## `label = $XXXX` after the array or instruction, so its dump stays
  ## unbroken and the label still gets its exact address. A label on memory
  ## no area covers is printed as a define in place, instead of an origin
  ## block with nothing in it.
  var f = AssemblyFileFormat(output: LineEmitter(atLineStart: true), crossReferences: newCrossReferences(subject),
      needsToReOrg: true, encoding: "none", textArrayStart: -1, textArrayEnd: -1, textDirective: ".text")
  f.printBankedDefines(subject)
  var deferred: seq[int]
  var address = 0
  while address < memorySize:
    let currentArea = subject.peek(address)
    if not continuesPrevious(currentArea, address, subject):
      f.printDefines(deferred, subject)
      deferred = @[]
    if currentArea != nil and currentArea.isVirtual:
      address = f.printVirtualStretch(address, subject)
      continue
    if currentArea.isData and currentArea.exported != nil:
      address = f.printExport(currentArea.exported, subject)
      continue
    # Is there a comment or a label here? Print them.
    if subject.isAnnotated(address):
      if currentArea == nil:
        f.printDefines(@[address], subject)
      elif continuesPrevious(currentArea, address, subject):
        deferred.add address
      else:
        f.printAnnotation(address, subject.memory[address].labelName, currentArea, subject)
    if currentArea == nil:
      f.needsToReOrg = true
    elif currentArea.isData:
      f.printData(currentArea, address, subject)
    else:
      f.printInstruction(currentArea, subject)
    inc address
  f.printDefines(deferred, subject)
  f.output.closeQuotes()
  f.output.text
