## Reads assembler source text, in a subset of 64tass's syntax, into an
## `Assembler`.
##
## - One statement per line. A `;` starts a comment.
## - `*=address` starts a segment at the address.
## - A label is a name followed by `:`, or a name at the start of the line
##   that isn't a mnemonic. An instruction or directive can follow it on the
##   same line.
## - `name = value` defines a name for a value.
## - Instructions: every opcode in every addressing mode, including the
##   illegal ones (see `opcodeFor`). Zero page is used when the operand is
##   below $100, unless it is prefixed with `@w`.
## - Values: `$hex`, `%binary`, decimal, `'c'` and names, combined with `+`
##   and `-`, and prefixed with `<` (low byte), `>` (high byte) or `-`.
## - Directives: `.byte`, `.word`, `.addr`, `.long`, `.dword` and their
##   signed counterparts `.char`, `.sint`, `.lint`, `.dint`, and `.rta` (an
##   address minus one, for an `rts` to return to), where `?` reserves a
##   value; `.fill count[, value]`; `.text`, `.null` (adds a 0) and `.ptext`
##   (adds the length in front), with strings encoded by `.enc "none"` or
##   `.enc "screen"` (Commodore screen codes); `.virtual address` ...
##   `.endv`; and `.binary "file"[, offset[, length]]`.
##
## The text is read as Unicode characters, with Java's idea of white space,
## letters and digits, so that the messages match the Java version's.

import std/[options, strutils, tables, unicode]
import specification, segment, assembler

type
  SourceError* = object of AssemblerError
    ## An error in assembler source text, at a line.
    line*: int

  Files* = proc (name: string): Option[seq[byte]]
    ## Gives the contents of a file that `.binary` names, or none when there is none.

  SourceParser = object
    assembler: Assembler
    files: Files
    references: OrderedTable[string, int]
      ## The line each name was first used on, to report the ones that are never defined.
    encoding: string
    lineNumber: int
    line: seq[Rune]
    pos: int

# Mnemonics.

const aliases = {"isb": "isc", "ins": "isc", "asr": "alr", "sbx": "axs", "sha": "ahx", "shs": "tas",
                 "ane": "xaa", "lds": "las", "dcm": "dcp", "lse": "sre"}.toTable
  ## 64tass's names for illegal opcodes, next to the names in the opcode table.

func buildOpcodes(): Table[string, array[AddressingMode, int]] =
  for opcode in 0 ..< 0x100:
    let name = opcodeName[opcode].toLowerAscii
    if name notin result:
      var none: array[AddressingMode, int]
      for mode in AddressingMode: none[mode] = -1
      result[name] = none
    let mode = if addressingMode[opcode] == AddressingMode.Jam: AddressingMode.None else: addressingMode[opcode]
    let known = result[name][mode]
    if known == -1 or illegal[known] and not illegal[opcode]:
      result[name][mode] = opcode

const opcodesByName = buildOpcodes()
  ## Some mnemonics have several opcodes in one mode (e.g. `sbc #` is $e9 and
  ## $eb, and `nop` has many): the legal one is used, else the lowest.

proc canonical(name: string): string =
  let lowerCase = unicode.toLower(name)
  aliases.getOrDefault(lowerCase, lowerCase)

proc isMnemonic(name: string): bool =
  canonical(name) in opcodesByName

proc opcodeFor(mnemonic: string, mode: AddressingMode): Option[int] =
  ## The opcode for a mnemonic in an addressing mode.
  let name = canonical(mnemonic)
  if name in opcodesByName and opcodesByName[name][mode] != -1:
    result = some(opcodesByName[name][mode])

# Characters, as Java's Character class sees them.

func isJavaWhitespace(r: Rune): bool =
  let c = int(r)
  c in 0x09 .. 0x0d or c in 0x1c .. 0x20 or c == 0x1680 or c in 0x2000 .. 0x2006 or c in 0x2008 .. 0x200a or
    c in [0x2028, 0x2029, 0x205f, 0x3000]

func isDigit(r: Rune): bool =
  int(r) in ord('0') .. ord('9')

proc isLetter(r: Rune): bool =
  if int(r) < 0x80: char(int(r)) in Letters else: r.isAlpha

func digit(r: Rune, radix: int): int =
  ## The value of the digit in the radix, or -1.
  let c = int(r)
  result =
    if c in ord('0') .. ord('9'): c - ord('0')
    elif c in ord('a') .. ord('z'): c - ord('a') + 10
    elif c in ord('A') .. ord('Z'): c - ord('A') + 10
    else: -1
  if result >= radix:
    result = -1

func `==`(r: Rune, c: char): bool = int(r) == ord(c)

func isBlank(runes: openArray[Rune]): bool =
  for r in runes:
    if not r.isJavaWhitespace:
      return false
  true

func startsWith(runes: seq[Rune], prefix: string, pos: int): bool =
  if pos + prefix.len > runes.len:
    return false
  for i, c in prefix:
    if runes[pos + i] != c:
      return false
  true

func withoutComment(text: seq[Rune]): seq[Rune] =
  ## The line without its comment: from the first `;` outside a string or
  ## character literal.
  var inString = false
  var i = 0
  while i < text.len:
    let c = text[i]
    if c == '"':
      inString = not inString
    elif not inString and c == '\'' and i + 2 < text.len and text[i + 2] == '\'':
      i += 2
    elif not inString and c == ';':
      return text[0 ..< i]
    inc i
  text

func sourceLines(source: string): seq[string] =
  ## The lines, split at "\n" or "\r\n", with the empty ones at the end.
  for line in source.split('\n'):
    result.add line
  for i in 0 ..< result.len - 1:
    if result[i].endsWith('\r'):
      result[i].setLen(result[i].len - 1)

# Reading a line.

proc error(p: SourceParser, message: string): ref SourceError =
  result = newException(SourceError, "line " & $p.lineNumber & ": " & message)
  result.line = p.lineNumber

proc rest(p: SourceParser, start: int): string =
  $p.line[min(start, p.line.len) .. ^1]

proc atEnd(p: SourceParser): bool =
  p.pos >= p.line.len

proc peek(p: SourceParser): Rune =
  if p.atEnd: Rune(0) else: p.line[p.pos]

proc skip(p: var SourceParser, c: char): bool =
  if p.peek == c:
    inc p.pos
    return true
  false

proc skipSpaces(p: var SourceParser) =
  while not p.atEnd and p.line[p.pos].isJavaWhitespace:
    inc p.pos

proc expect(p: var SourceParser, c: char) =
  if not p.skip(c):
    raise p.error("expected '" & c & "' at '" & p.rest(p.pos) & "'")

proc expectEnd(p: var SourceParser) =
  p.skipSpaces()
  if not p.atEnd:
    raise p.error("unexpected '" & p.rest(p.pos) & "'")

proc identifier(p: var SourceParser): string =
  let start = p.pos
  while p.pos < p.line.len and (p.line[p.pos].isLetter or p.line[p.pos].isDigit or p.line[p.pos] == '_'):
    inc p.pos
  if start == p.pos or p.line[start].isDigit:
    raise p.error("expected a name at '" & p.rest(start) & "'")
  $p.line[start ..< p.pos]

proc add(p: SourceParser, assemblable: Assemblable) =
  assemblable.sourceLine = p.lineNumber
  p.assembler.add assemblable

proc checkNew(p: SourceParser, name: string) =
  if p.assembler.isDefined(name):
    raise p.error(name & " is already defined")

# Values.

proc map(value: Value, operator: proc (v: int32): int32): Value =
  result = proc (): Option[int32] = value().map(operator)

proc combine(left, right: Value, subtract: bool): Value =
  result = proc (): Option[int32] =
    let l = left()
    if l.isNone: return none(int32)
    let r = right()
    if r.isNone: return none(int32)
    some(if subtract: l.get -% r.get else: l.get +% r.get)

proc encode(p: SourceParser, character: Rune): int32 =
  ## The byte for a character in a string under the current encoding.
  ## "screen" maps "@A-Z[\]^_" to $00-$1F, " " to "?" to themselves, and
  ## "`a-z{|}~" to $40-$5E.
  let c = int32(character)
  if p.encoding == "screen":
    if c in 0x20'i32 .. 0x3f'i32:
      return c
    elif c in 0x40'i32 .. 0x5f'i32:
      return c - 0x40
    elif c in 0x60'i32 .. 0x7e'i32:
      return c - 0x20
    raise p.error("character " & $character & " has no screen code")
  if c > 0xff:
    raise p.error("character " & $character & " doesn't fit in a byte")
  c

proc number(p: var SourceParser, radix: int): int32 =
  let start = p.pos
  while p.pos < p.line.len and p.line[p.pos].digit(radix) != -1:
    inc p.pos
  if start == p.pos:
    raise p.error("expected a number at '" & p.rest(start) & "'")
  let digits = $p.line[start ..< p.pos]
  var value = 0'i64
  for i in start ..< p.pos:
    let d = p.line[i].digit(radix)
    if value > (high(int64) - d) div radix:
      # Java's Long.parseLong fails on it before the 32-bit check.
      raise newException(AssemblerError, "For input string: \"" & digits & "\"" &
          (if radix == 10: "" else: " under radix " & $radix))
    value = value * radix + d
  if value > 0xffffffff'i64:
    raise p.error("number " & digits & " is larger than 32 bits")
  cast[int32](uint32(value))

proc expression(p: var SourceParser): Value

proc term(p: var SourceParser): Value =
  p.skipSpaces()
  let c = p.peek
  if p.skip('<'):
    return p.term().map(proc (v: int32): int32 = v and 0xff)
  elif p.skip('>'):
    return p.term().map(proc (v: int32): int32 = (v shr 8) and 0xff)
  elif p.skip('-'):
    return p.term().map(proc (v: int32): int32 = 0'i32 -% v)
  elif p.skip('$'):
    return constant(p.number(16))
  elif p.skip('%'):
    return constant(p.number(2))
  elif c.isDigit:
    return constant(p.number(10))
  elif c == '\'' and p.pos + 2 < p.line.len and p.line[p.pos + 2] == '\'':
    p.pos += 3
    return constant(p.encode(p.line[p.pos - 2]))
  elif c.isLetter or c == '_':
    let name = p.identifier()
    if name notin p.references:
      p.references[name] = p.lineNumber
    return p.assembler.symbol(name)
  raise p.error("expected a value at '" & p.rest(p.pos) & "'")

proc expression(p: var SourceParser): Value =
  var value = p.term()
  while true:
    p.skipSpaces()
    if p.skip('+'):
      value = combine(value, p.term(), false)
    elif p.skip('-'):
      value = combine(value, p.term(), true)
    else:
      return value

proc constant(p: var SourceParser): int32 =
  ## A value that must be known while parsing, like an address for `*=`.
  let value = p.expression()()
  if value.isNone:
    raise p.error("the value must be known here")
  value.get

proc quoted(p: var SourceParser): string =
  p.expect('"')
  while true:
    if p.atEnd:
      raise p.error("string isn't closed")
    let c = p.line[p.pos]
    inc p.pos
    if c == '"':
      if p.peek != '"':
        return
      inc p.pos
    result.add $c

# Instructions.

proc opcode(p: SourceParser, mnemonic: string, mode: AddressingMode): int =
  let opcode = opcodeFor(mnemonic, mode)
  if opcode.isNone:
    raise p.error(mnemonic & " has no " & mode.name & " addressing mode")
  opcode.get

proc expectIndex(p: var SourceParser, register: string) =
  p.skipSpaces()
  let index = p.identifier()
  if cmpIgnoreCase(index, register) != 0:
    raise p.error("expected index register " & register & ", not " & index)

proc parseInstruction(p: var SourceParser, mnemonic: string) =
  if not isMnemonic(mnemonic):
    raise p.error("unknown mnemonic " & mnemonic)
  p.skipSpaces()
  if p.atEnd:
    var opcode = opcodeFor(mnemonic, AddressingMode.None)
    if opcode.isNone:
      opcode = opcodeFor(mnemonic, AddressingMode.Accumulator)
    if opcode.isNone:
      raise p.error(mnemonic & " needs an operand")
    p.add instruction(opcode.get)
    return
  if p.peek == '#':
    inc p.pos
    let immediate = p.opcode(mnemonic, AddressingMode.Immediate)
    p.add instruction(immediate, p.expression())
    p.expectEnd()
    return
  if p.peek == '(':
    inc p.pos
    let operand = p.expression()
    p.skipSpaces()
    var mode: AddressingMode
    if p.peek == ',':
      inc p.pos
      p.expectIndex("x")
      p.skipSpaces()
      p.expect(')')
      mode = AddressingMode.IndX
    else:
      p.expect(')')
      p.skipSpaces()
      if p.peek == ',':
        inc p.pos
        p.expectIndex("y")
        mode = AddressingMode.IndY
      else:
        mode = AddressingMode.Indirect
    p.expectEnd()
    p.add instruction(p.opcode(mnemonic, mode), operand)
    return
  if p.line.startsWith("a", p.pos) and p.line.toOpenArray(p.pos + 1, p.line.len - 1).isBlank:
    # The opcode table has asl, lsr, rol and ror on the accumulator as None.
    var accumulator = opcodeFor(mnemonic, AddressingMode.Accumulator)
    if accumulator.isNone:
      accumulator = opcodeFor(mnemonic, AddressingMode.None)
    if accumulator.isSome:
      p.add instruction(accumulator.get)
      return
  var forceAbsolute = false
  if p.line.startsWith("@w", p.pos) and p.pos + 2 < p.line.len and p.line[p.pos + 2].isJavaWhitespace:
    p.pos += 2
    forceAbsolute = true
  let operand = p.expression()
  p.skipSpaces()
  var index = ""
  if p.peek == ',':
    inc p.pos
    p.skipSpaces()
    index = unicode.toLower(p.identifier())
  p.expectEnd()
  var absolute, zeroPage: AddressingMode
  case index
  of "":
    let branchOpcode = opcodeFor(mnemonic, AddressingMode.Relative)
    if branchOpcode.isSome:
      p.add branch(branchOpcode.get, operand)
      return
    absolute = AddressingMode.Absolute
    zeroPage = AddressingMode.ZeroPage
  of "x":
    absolute = AddressingMode.AbsoluteX
    zeroPage = AddressingMode.ZeroPageX
  of "y":
    absolute = AddressingMode.AbsoluteY
    zeroPage = AddressingMode.ZeroPageY
  else:
    raise p.error("index register must be x or y, not " & index)
  let absoluteOpcode = opcodeFor(mnemonic, absolute)
  let zeroPageOpcode = opcodeFor(mnemonic, zeroPage)
  if forceAbsolute:
    p.add instruction(p.opcode(mnemonic, absolute), operand)
  elif absoluteOpcode.isSome and zeroPageOpcode.isSome:
    p.add instruction(absoluteOpcode.get, zeroPageOpcode.get, operand)
  elif absoluteOpcode.isSome:
    p.add instruction(absoluteOpcode.get, operand)
  elif zeroPageOpcode.isSome:
    p.add instruction(zeroPageOpcode.get, operand)
  else:
    raise p.error(mnemonic & " has no " & absolute.name & " addressing mode")

# Directives.

proc values(p: var SourceParser, width: int, signed: bool, operator: proc (v: int32): int32 = nil) =
  var list: seq[Value]
  while true:
    p.skipSpaces()
    if p.peek == '?':
      inc p.pos
      list.add nil
    else:
      let value = p.expression()
      list.add(if operator == nil: value else: value.map(operator))
    p.skipSpaces()
    if not p.skip(','):
      break
  p.add values(width, signed, list)

proc fill(p: var SourceParser) =
  let count = p.constant()
  p.skipSpaces()
  if p.skip(','):
    let value = p.expression()
    var list: seq[Value]
    for i in 0 ..< count:
      list.add value
    p.add values(1, false, list)
  else:
    p.add fill(int(count))

proc text(p: var SourceParser, directive: string) =
  var list: seq[Value]
  while true:
    p.skipSpaces()
    if p.peek == '"':
      for character in p.quoted().runes:
        let encoded = p.encode(character)
        if directive == "null" and encoded == 0:
          raise p.error(".null text can't hold a 0")
        list.add constant(encoded)
    else:
      list.add p.expression()
    p.skipSpaces()
    if not p.skip(','):
      break
  if directive == "null":
    list.add constant(0'i32)
  elif directive == "ptext":
    if list.len > 0xff:
      raise p.error(".ptext text is longer than 255")
    list.insert(constant(int32(list.len)), 0)
  p.add values(1, false, list)

proc binary(p: var SourceParser) =
  let fileName = p.quoted()
  p.skipSpaces()
  var offset = 0
  var length = -1
  if p.skip(','):
    offset = p.constant()
    p.skipSpaces()
    if p.skip(','):
      length = p.constant()
  let contents = p.files(fileName)
  if contents.isNone:
    raise p.error("can't read " & fileName)
  let size = contents.get.len
  if length == -1:
    length = size - offset
  if offset < 0 or length < 0 or offset + length > size:
    raise p.error(fileName & " has " & $size & " bytes, too few for offset " & $offset & " and length " & $length)
  var included = newSeq[int](length)
  for i in 0 ..< length:
    included[i] = int(contents.get[offset + i])
  p.add bytes(included)

proc directive(p: var SourceParser) =
  inc p.pos
  let directive = unicode.toLower(p.identifier())
  p.skipSpaces()
  case directive
  of "byte": p.values(1, false)
  of "char": p.values(1, true)
  of "word", "addr": p.values(2, false)
  of "sint": p.values(2, true)
  # An rts adds one to the address it pulls; wraps like 64tass.
  of "rta": p.values(2, false, proc (v: int32): int32 = (v -% 1) and 0xffff)
  of "long": p.values(3, false)
  of "lint": p.values(3, true)
  of "dword": p.values(4, false)
  of "dint": p.values(4, true)
  of "fill": p.fill()
  of "text", "null", "ptext": p.text(directive)
  of "enc":
    p.encoding = p.quoted()
    if p.encoding != "none" and p.encoding != "screen":
      raise p.error("unknown encoding " & p.encoding & ", only none and screen are known")
  of "virtual": p.add virtual(p.constant())
  of "endv", "endvirtual": p.add endVirtual()
  of "binary": p.binary()
  else: raise p.error("unknown directive ." & directive)
  p.expectEnd()

# Lines.

proc statement(p: var SourceParser) =
  p.skipSpaces()
  if p.atEnd:
    return
  if p.peek == '.':
    p.directive()
  else:
    p.parseInstruction(p.identifier())

proc parseLine(p: var SourceParser, text: string) =
  p.line = withoutComment(text.toRunes)
  p.pos = 0
  if p.line.isBlank:
    return
  let atLineStart = not p.line[0].isJavaWhitespace
  p.skipSpaces()
  if p.peek == '*':
    inc p.pos
    p.skipSpaces()
    p.expect('=')
    p.add org(p.constant())
    p.expectEnd()
    return
  if p.peek == '.':
    p.directive()
    return
  let name = p.identifier()
  p.skipSpaces()
  if p.peek == '=':
    inc p.pos
    p.checkNew(name)
    p.add define(name, p.expression())
    p.expectEnd()
  elif p.peek == ':' or atLineStart and not isMnemonic(name):
    if p.peek == ':':
      inc p.pos
    p.checkNew(name)
    p.add label(name)
    p.statement()
  else:
    p.parseInstruction(name)

proc parse*(assembler: Assembler, source: string, files: Files = nil) =
  ## Reads source text into the assembler. Raises a `SourceError` for an
  ## error in it.
  var p = SourceParser(assembler: assembler, encoding: "none",
      files: if files == nil: (proc (name: string): Option[seq[byte]] = none(seq[byte])) else: files)
  for i, line in sourceLines(source):
    p.lineNumber = i + 1
    p.parseLine(line)
  for name, line in p.references:
    if not assembler.isDefined(name):
      var e = newException(SourceError, "line " & $line & ": " & name & " is not defined")
      e.line = line
      raise e

proc assemble*(source: string, files: Files = nil): seq[Segment] =
  ## Assembles source text into segments, one per `*=`. `files` gives the
  ## contents of a file that `.binary` names. Raises an `AssemblerError`,
  ## which a `SourceError` is, with the message the Java version gives.
  let assembler = newAssembler()
  assembler.parse(source, files)
  assembler.assemble()
