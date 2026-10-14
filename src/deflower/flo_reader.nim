## Parses a `.flo` file into its runs: one per 'deflower' line, each with
## the annotations that follow it. Reads nothing but the `.flo` files, and
## changes no memory.
##
## The format is described in `docs/flo-format.md`.
## Two npeg grammars read it: one turns the characters into tokens, the
## other reads one statement (a line) of tokens at a time.

import std/[algorithm, os, strutils, tables]
import npeg
import printing, subject

type
  TokenKind = enum
    tkInt, tkHex, tkId, tkComment, tkNewline,
    tkDeflower = "deflower", tkInclude = "include", tkVirtual = "virtual", tkBanked = "banked",
    tkSelfMod = "selfmod", tkExport = "export", tkNoReturn = "noreturn", tkUntil = "until",
    tkLengthByte = "lengthbyte",
    # The types, in the order of LineType.
    tkScreencode = "screencode", tkAscii = "ascii", tkByte = "byte", tkCode = "code", tkWord = "word",
    tkLong = "long", tkDword = "dword", tkAddr = "addr", tkRta = "rta", tkSbyte = "sbyte",
    tkSword = "sword", tkSlong = "slong", tkSdword = "sdword",
    tkMinus = "-", tkStar = "*", tkPlus = "+", tkOpenSize = "[", tkCloseSize = "]",
    tkOpenParameters = "(", tkComma = ",", tkCloseParameters = ")", tkOpenBlock = "{", tkCloseBlock = "}"

  Token = object
    kind: TokenKind
    text: string
    line: int
    column: int

  Lexer = object
    text: string
    tokens: seq[Token]
    errors: seq[tuple[line, column: int, message: string]]

  StatementKind = enum
    skComment, skDeflower, skInclude, skLine, skEndBlock

  RawParameter = object
    ## A parameter as written: its type, size and name.
    lineType: LineType
    size: seq[Token]
    terminator: int
    lengthByte: bool
    name: string

  Statement = object
    ## What the parser read from one line, as token indexes and flags.
    kind: StatementKind
    text: string
      ## The comment's text, or the file name of a deflower or include line.
    address: int
    addressEnd: int
    virtual: bool
    banked: bool
    selfMod: bool
    hasType: bool
    lineType: LineType
    size: seq[Token]
      ## The tokens of an array size like "40*21".
    terminator: int
    lengthByte: bool
    name: string
    hasParameters: bool
    parameters: seq[RawParameter]
    noReturn: bool
    exportFile: string
    openBlock: bool

  StatementParser = object
    tokens: seq[Token]
    statement: Statement
    parameter: RawParameter
    inParameter: bool

  AnnotationCollector = ref object
    ## Turns the statements into annotations, one line at a time.
    runs: seq[DeflowerRun]
    run: DeflowerRun
    included: bool
      ## True while reading an included file: its lines are weak.
    path: string
      ## The file being read, or empty for a built-in one.
    includeChain: seq[string]
      ## The files being read, outermost first, to catch an include cycle.
    exportLines: TableRef[string, int]
      ## The line each export file name was first given on, across all
      ## runs: they share one output directory.
    pendingComments: seq[string]
    errors: seq[string]
      ## Mistakes the grammar can't catch, like a misplaced block.
    blockBase: int
      ## The open { } block (issue 0035): inner addresses are offsets from
      ## blockBase. -1 when no block is open; blocks don't nest.
    blockVirtual: bool
    blockLine: int

const builtIns = {
  "c64.flo": staticRead("includes/c64.flo"),
  "c64_basic.flo": staticRead("includes/c64_basic.flo"),
  "c64_io.flo": staticRead("includes/c64_io.flo"),
  "c64_kernal.flo": staticRead("includes/c64_kernal.flo"),
  "c64_system.flo": staticRead("includes/c64_system.flo"),
  "c64_zeropage.flo": staticRead("includes/c64_zeropage.flo"),
}.toTable
  ## The .flo files built into Deflower (issue 0078).

const typeTokens = {tkScreencode .. tkSdword}

# Lexing.

proc escape(text: string): string =
  ## A character as an error message shows it.
  text.multiReplace(("\n", "\\n"), ("\r", "\\r"), ("\t", "\\t"))

proc position(lexer: Lexer, index: int): tuple[line, column: int] =
  result.line = 1
  var lineStart = 0
  for i in 0 ..< index:
    if lexer.text[i] == '\n':
      inc result.line
      lineStart = i + 1
  result.column = index - lineStart

proc addToken(lexer: var Lexer, kind: TokenKind, text: string, index: int) =
  let (line, column) = lexer.position(index)
  lexer.tokens.add Token(kind: kind, text: text, line: line, column: column)

proc addWord(lexer: var Lexer, text: string, index: int) =
  ## A word is a keyword, a number or an identifier, in that order.
  var kind = tkId
  for keyword in tkDeflower .. tkSdword:
    if text == $keyword:
      kind = keyword
  if kind == tkId and text.allCharsInSet(Digits):
    kind = tkInt
  lexer.addToken(kind, text, index)

proc addError(lexer: var Lexer, text: string, index: int) =
  let (line, column) = lexer.position(index)
  lexer.errors.add((line, column, "unexpected '" & escape(text) & "'"))

let lexerGrammar = peg("tokens", lexer: Lexer):
  tokens <- *token * !1
  token <- newline | whiteSpace | comment | hex | word | sign | bad
  newline <- >+{'\r', '\n'}:
    lexer.addToken(tkNewline, $1, @1)
  whiteSpace <- +{' ', '\t'}
  comment <- >({';', '#'} * *(1 - {'\r', '\n'})):
    lexer.addToken(tkComment, $1, @1)
  hex <- >('$' * +Xdigit):
    lexer.addToken(tkHex, $1, @1)
  word <- >+{'A'..'Z', 'a'..'z', '0'..'9', '.', '_', '?'}:
    lexer.addWord($1, @1)
  sign <- >{'-', '*', '+', '[', ']', '(', ')', ',', '{', '}'}:
    for kind in tkMinus .. tkCloseBlock:
      if $1 == $kind:
        lexer.addToken(kind, $1, @1)
  # A '$' without a hex digit takes the next character along, as ANTLR did.
  bad <- >('$' * utf8char | utf8char):
    lexer.addError($1, @1)
  utf8char <- {'\x00'..'\x7f'} | {'\xc0'..'\xff'} * *{'\x80'..'\xbf'} | 1

# Parsing.

proc tokenAt(parser: StatementParser, index: int): Token =
  parser.tokens[index]

proc number(text: string): int =
  if text.startsWith("$"): parseHexInt(text[1 .. ^1]) else: parseInt(text)

proc lineTypeOf(kind: TokenKind): LineType =
  LineType(ord(kind) - ord(tkScreencode))

let statementGrammar = peg("statement", TokenKind, p: StatementParser):
  statement <- (comment | deflowerLine | includeLine | line | endBlock) * [tkNewline] * !1
  comment <- >[tkComment]:
    let text = p.tokenAt(@1).text[1 .. ^1]
    p.statement = Statement(kind: skComment, text: if text.startsWith(" "): text[1 .. ^1] else: text)
  deflowerLine <- [tkDeflower] * >[tkId]:
    p.statement = Statement(kind: skDeflower, text: p.tokenAt(@1).text)
  includeLine <- [tkInclude] * >[tkId]:
    p.statement = Statement(kind: skInclude, text: p.tokenAt(@1).text)
  endBlock <- [tkCloseBlock]:
    p.statement = Statement(kind: skEndBlock)
  number <- [tkInt] | [tkHex]
  line <- (memoryRange | address) * ?setVirtual * ?setBanked * ?setSelfMod * ?lineType * ?setLabel *
      ?parameters * ?noReturn * ?exportPart * ?openBlock
  address <- >number:
    p.statement = Statement(kind: skLine, address: number(p.tokenAt(@1).text), addressEnd: -1, terminator: -1,
        lineType: ltUnknown)
  memoryRange <- >number * [tkMinus] * >number:
    p.statement = Statement(kind: skLine, address: number(p.tokenAt(@1).text),
        addressEnd: number(p.tokenAt(@2).text), terminator: -1, lineType: ltUnknown)
  setVirtual <- [tkVirtual]:
    p.statement.virtual = true
  setBanked <- [tkBanked]:
    p.statement.banked = true
  setSelfMod <- [tkSelfMod]:
    p.statement.selfMod = true
  setLabel <- >[tkId]:
    p.statement.name = p.tokenAt(@1).text
  noReturn <- [tkNoReturn]:
    p.statement.noReturn = true
  exportPart <- [tkExport] * >[tkId]:
    p.statement.exportFile = p.tokenAt(@1).text
  openBlock <- [tkOpenBlock]:
    p.statement.openBlock = true
  # A data type with its size, on the line or on a parameter.
  lineType <- typeName * ?([tkOpenSize] * ?(untilSize | lengthByte | arraySize) * [tkCloseSize])
  typeName <- >([tkScreencode] | [tkAscii] | [tkByte] | [tkWord] | [tkLong] | [tkDword] | [tkAddr] | [tkRta] |
      [tkSbyte] | [tkSword] | [tkSlong] | [tkSdword] | [tkCode]):
    let lineType = lineTypeOf(p.tokenAt(@1).kind)
    if p.inParameter:
      p.parameter.lineType = lineType
    else:
      p.statement.hasType = true
      p.statement.lineType = lineType
  untilSize <- [tkUntil] * >number:
    let terminator = number(p.tokenAt(@1).text)
    if p.inParameter: p.parameter.terminator = terminator else: p.statement.terminator = terminator
  lengthByte <- [tkLengthByte]:
    if p.inParameter: p.parameter.lengthByte = true else: p.statement.lengthByte = true
  # "*" binds tighter than "+".
  arraySize <- sizeNumber * *(sizeOperator * sizeNumber)
  sizeNumber <- >number:
    let token = p.tokenAt(@1)
    if p.inParameter: p.parameter.size.add token else: p.statement.size.add token
  sizeOperator <- >([tkStar] | [tkPlus]):
    let token = p.tokenAt(@1)
    if p.inParameter: p.parameter.size.add token else: p.statement.size.add token
  parameters <- parametersStart * parameter * *([tkComma] * parameter) * [tkCloseParameters]
  parametersStart <- [tkOpenParameters]:
    p.statement.hasParameters = true
  parameter <- parameterStart * lineType * ?parameterName:
    p.statement.parameters.add p.parameter
    p.inParameter = false
  parameterStart <- 0:
    p.inParameter = true
    p.parameter = RawParameter(terminator: -1)
  parameterName <- >[tkId]:
    p.parameter.name = p.tokenAt(@1).text

# Error messages.

const lineParts = ["virtual", "banked", "selfmod", "a type", "a label", "parameters", "noreturn", "export", "'{'"]
  ## The optional parts of an annotation line after its address, in order.

proc remainingLineParts(line: openArray[Token], codeLine: bool): seq[string] =
  ## The parts that may follow the last part of an annotation line, which
  ## holds `line`, named as in the format description.
  var last = -1
  var depth = 0
  for i in 1 ..< line.len:
    let kind = line[i].kind
    if kind == tkOpenParameters:
      inc depth
    elif kind == tkCloseParameters:
      dec depth
      last = lineParts.find("parameters")
    elif depth > 0:
      continue
    elif kind in typeTokens:
      last = lineParts.find("a type")
    elif kind == tkId:
      last = if line[i - 1].kind == tkExport: lineParts.find("export") else: lineParts.find("a label")
    elif kind == tkOpenBlock:
      last = lineParts.find("'{'")
    elif line[i].text in lineParts:
      last = lineParts.find(line[i].text)
  for part in lineParts[last + 1 .. ^1]:
    if not codeLine and part in ["parameters", "noreturn"]:
      continue
    result.add part
  if line[^1].kind in typeTokens:
    result.insert("a size", 0)
  result.add "the end of the line"

proc expectedParts(line: openArray[Token]): seq[string] =
  ## What may come after `line`, the tokens of a line before a mistake.
  if line.len == 0:
    return @["an address", "deflower", "include", "'}'"]
  let previous = line[^1].kind
  if previous in {tkDeflower, tkInclude, tkExport}:
    return @["a file name"]
  if line[0].kind notin {tkInt, tkHex}:
    return @["the end of the line"]
  if previous == tkMinus:
    return @["a number"]
  var depth = 0
  var inSize = false
  for token in line:
    case token.kind
    of tkOpenParameters: inc depth
    of tkCloseParameters: dec depth
    of tkOpenSize: inSize = true
    of tkCloseSize: inSize = false
    else: discard
  if inSize:
    return case previous
      of tkOpenSize: @["a number", "until", "lengthbyte", "']'"]
      of tkStar, tkPlus, tkUntil: @["a number"]
      else: @["']'"]
  if depth > 0:
    return if previous in {tkOpenParameters, tkComma}: @["a type"] else: @["',' or ')'"]
  var codeLine = false
  for token in line:
    codeLine = codeLine or token.kind == tkCode
  remainingLineParts(line, codeLine)

proc describe(line: openArray[Token], found: Token): string =
  ## Says what was expected where `found` is, in the words of the format
  ## description: "expected a type, a label or the end of the line, found
  ## 'x'".
  let parts = expectedParts(line)
  let foundText = if found.kind == tkNewline: "the end of the line" else: "'" & found.text & "'"
  let list = if parts.len == 1: parts[0] else: parts[0 ..< ^1].join(", ") & " or " & parts[^1]
  "expected " & list & ", found " & foundText

proc parseStatements(text: string, errors: var seq[string]): seq[tuple[line: int, statement: Statement]] =
  ## The statements of `text`, or nothing with the syntax errors in `errors`:
  ## the first one on each line, by column.
  var lexer = Lexer(text: text)
  discard lexerGrammar.match(text, lexer)
  var firstErrors: Table[int, tuple[column: int, message: string]]
  for error in lexer.errors:
    if error.line notin firstErrors or error.column < firstErrors[error.line].column:
      firstErrors[error.line] = (error.column, error.message)
  var start = 0
  while start < lexer.tokens.len:
    var finish = start
    while lexer.tokens[finish].kind != tkNewline:
      inc finish
    var kinds: seq[TokenKind]
    for token in lexer.tokens[start .. finish]:
      kinds.add token.kind
    var parser = StatementParser(tokens: lexer.tokens[start .. finish])
    let match = statementGrammar.match(kinds, parser)
    if match.ok:
      result.add (lexer.tokens[start].line, parser.statement)
    else:
      let index = min(match.matchMax, finish - start)
      let found = parser.tokens[index]
      if found.line notin firstErrors or found.column < firstErrors[found.line].column:
        firstErrors[found.line] = (found.column, describe(parser.tokens[0 ..< index], found))
    start = finish + 1
  var lines: seq[int]
  for line in firstErrors.keys:
    lines.add line
  lines.sort()
  for line in lines:
    errors.add "line " & $line & ": " & firstErrors[line].message

# Collecting the annotations.

proc newCollector(run: DeflowerRun, included: bool, path: string, includeChain: seq[string],
    exportLines: TableRef[string, int]): AnnotationCollector =
  AnnotationCollector(run: run, included: included, path: path, includeChain: includeChain,
      exportLines: exportLines, blockBase: -1)

proc collect(text, sourceName: string, collector: AnnotationCollector)

proc closeRun(collector: AnnotationCollector) =
  ## A block ends inside the run it opened in: a new 'deflower' line or the
  ## end of the file with a block still open is an error.
  if collector.blockBase != -1:
    collector.errors.add "line " & $collector.blockLine & ": block is not closed with '}'"
  collector.blockBase = -1

proc lineError(collector: AnnotationCollector, line: int, message: string) =
  collector.errors.add "line " & $line & ": " & message

proc startRun(collector: AnnotationCollector, line: int, fileName: string) =
  if collector.included:
    collector.lineError(line, "an included file can't start a run")
    return
  collector.closeRun()
  collector.run = DeflowerRun(targetName: fileName)
  collector.pendingComments = @[]
  collector.runs.add collector.run

proc includeFile(collector: AnnotationCollector, line: int, name: string) =
  ## Reads the included file's lines into the current run, marked as
  ## included (issue 0078). The file is looked up next to the file being
  ## read, then among the built-in ones.
  assertState(collector.run != nil, "Start the file with a 'deflower <file>' line.")
  if collector.blockBase != -1:
    collector.lineError(line, "can't include inside a block")
    return
  # A comment above an include line is about the include.
  collector.pendingComments = @[]
  if name in collector.includeChain:
    collector.lineError(line, "include cycle: " & collector.includeChain.join(" -> ") & " -> " & name)
    return
  let chain = collector.includeChain & name
  let local = if collector.path.len > 0: collector.path.parentDir / name else: ""
  if local.len > 0 and fileExists(local):
    var text: string
    try:
      text = readFile(local)
    except IOError as e:
      collector.lineError(line, "can't read " & name & ": " & e.msg)
      return
    collect(text, name, newCollector(collector.run, true, local, chain, collector.exportLines))
  elif name in builtIns:
    collect(builtIns[name], name, newCollector(collector.run, true, "", chain, collector.exportLines))
  else:
    collector.lineError(line, "no file " & name & " to include")

proc checkTerminator(collector: AnnotationCollector, line: int, lineType: LineType, value: int): bool =
  ## The value an "until" size ends at must fit in one element.
  if lineType != ltCode and value >= 1 shl (8 * lineType.dataType.sizeInBytes):
    collector.lineError(line, "until $" & hex(value) & " doesn't fit in one " & $lineType.dataType)
    return false
  true

proc checkLengthByte(collector: AnnotationCollector, line: int, lineType: LineType): bool =
  ## A length byte counts elements of one byte (issue 0094).
  if lineType != ltCode and lineType.dataType.sizeInBytes != 1:
    collector.lineError(line, "lengthbyte needs a one-byte type, not " & $lineType.dataType)
    return false
  true

proc checkExport(collector: AnnotationCollector, line: int, statement: Statement, isVirtual: bool): bool =
  ## Only a data line can be exported (issue 0022), to a file whose name
  ## ends in .bin or .prg and that no other line exports to.
  let file = statement.exportFile
  var problem = ""
  if collector.included:
    problem = "an included file can't export"
  elif not (file.endsWith(".bin") or file.endsWith(".prg")) or file.len == ".bin".len:
    problem = "export " & file & " needs a file name ending in .bin or .prg"
  elif statement.lineType == ltCode:
    problem = "code can't be exported"
  elif isVirtual:
    problem = "a virtual area can't be exported"
  elif statement.lineType == ltUnknown and statement.addressEnd == -1:
    problem = "export needs a type or a range"
  elif file in collector.exportLines:
    problem = file & " is already exported on line " & $collector.exportLines[file]
  if problem.len > 0:
    collector.lineError(line, problem)
    return false
  collector.exportLines[file] = line
  true

proc evaluate(size: seq[Token]): int =
  ## The value of an array size like "40*21+3": "*" binds tighter than "+".
  if size.len == 0:
    return 1
  var product = 1
  for token in size:
    case token.kind
    of tkPlus:
      result += product
      product = 1
    of tkStar:
      discard
    else:
      product *= number(token.text)
  result += product

proc parameters(collector: AnnotationCollector, statement: Statement, line: int,
    parameters: var seq[Parameter]): bool =
  ## A routine's parameter list (issue 0068): the data after each jsr to
  ## it, in order. False after a mistake, which is reported.
  for raw in statement.parameters:
    if raw.lineType == ltCode:
      collector.lineError(line, "a parameter can't be code")
      return false
    let amount = evaluate(raw.size)
    if raw.terminator != -1 and not collector.checkTerminator(line, raw.lineType, raw.terminator):
      return false
    if raw.lengthByte and not collector.checkLengthByte(line, raw.lineType):
      return false
    if amount <= 0:
      collector.lineError(line, "zero-size parameter")
      return false
    parameters.add Parameter(dataType: raw.lineType.dataType, amount: amount, terminator: raw.terminator,
        lengthByte: raw.lengthByte, name: raw.name)
  true

proc openBlock(collector: AnnotationCollector, statement: Statement, address, line: int, isVirtual: bool,
    comment: seq[string]) =
  ## A '{' line only gives the base address and, optionally, 'virtual',
  ## which then applies to every line inside. It covers no memory itself; a
  ## comment above it goes onto the base address.
  if collector.blockBase != -1:
    collector.lineError(line, "blocks can't be nested (the open one starts at line " & $collector.blockLine & ")")
    return
  if statement.addressEnd != -1 or statement.banked or statement.selfMod or statement.hasType or
      statement.name.len > 0 or statement.exportFile.len > 0 or statement.hasParameters or statement.noReturn:
    collector.lineError(line, "a block's opening line takes only an address and 'virtual'")
    return
  collector.blockBase = address
  collector.blockVirtual = isVirtual
  collector.blockLine = line
  if comment.len > 0:
    collector.run.annotations.add Annotation(address: address, addressEnd: -1, lineType: ltUnknown, amount: 1,
        comment: comment, included: collector.included, terminator: -1)

proc annotationLine(collector: AnnotationCollector, statement: Statement, line: int) =
  ## Turns an annotation line into an Annotation.
  assertState(collector.run != nil, "Start the file with a 'deflower <file>' line.")
  let comment = collector.pendingComments
  collector.pendingComments = @[]
  var address = statement.address
  var addressEnd = statement.addressEnd
  var isVirtual = statement.virtual
  if collector.blockBase != -1:
    address += collector.blockBase
    if addressEnd != -1:
      addressEnd += collector.blockBase
    isVirtual = isVirtual or collector.blockVirtual
    if address > 0xffff or addressEnd > 0x10000:
      collector.lineError(line, "the block's base plus this offset runs past $ffff")
      return
  if statement.openBlock:
    collector.openBlock(statement, address, line, isVirtual, comment)
    return
  if statement.exportFile.len > 0 and not collector.checkExport(line, statement, isVirtual):
    return
  if statement.terminator != -1 and not collector.checkTerminator(line, statement.lineType, statement.terminator):
    return
  if statement.lengthByte and not collector.checkLengthByte(line, statement.lineType):
    return
  if statement.banked and (addressEnd != -1 or statement.virtual or statement.hasType or statement.name.len == 0 or
      statement.hasParameters or statement.noReturn or statement.exportFile.len > 0):
    collector.lineError(line, "a banked line takes only an address and a label")
    return
  if statement.selfMod and (addressEnd != -1 or statement.virtual or statement.banked or statement.hasType or
      statement.name.len == 0 or statement.hasParameters or statement.noReturn or statement.exportFile.len > 0):
    collector.lineError(line, "a selfmod line takes only an address and a label")
    return
  # A virtual block's 'virtual' is about the memory, not a banked name or a
  # selfmod line.
  isVirtual = isVirtual and not statement.banked and not statement.selfMod
  var parameters: seq[Parameter]
  if statement.hasParameters and not collector.parameters(statement, line, parameters):
    return
  if (statement.hasParameters or statement.noReturn) and statement.lineType != ltCode:
    collector.lineError(line, "only a code line takes parameters or noreturn")
    return
  collector.run.annotations.add Annotation(address: address, addressEnd: addressEnd, lineType: statement.lineType,
      virtual: isVirtual, amount: evaluate(statement.size), name: statement.name, comment: comment,
      included: collector.included, exportFile: statement.exportFile, terminator: statement.terminator,
      lengthByte: statement.lengthByte, hasParameters: statement.hasParameters, parameters: parameters,
      noReturn: statement.noReturn, banked: statement.banked, selfMod: statement.selfMod)

proc collect(text, sourceName: string, collector: AnnotationCollector) =
  ## Parses `text` and turns its lines into annotations with `collector`,
  ## failing on a syntax error or a mistake the collector found.
  # The grammar ends every line with a newline; the last one may lack it
  # (issue 0088).
  let lines = if text.len == 0 or text.endsWith("\n") or text.endsWith("\r"): text else: text & "\n"
  var parseErrors: seq[string]
  let statements = parseStatements(lines, parseErrors)
  assertState(parseErrors.len == 0, "Failed to parse " & sourceName & ":\n" & parseErrors.join("\n"))
  for (line, statement) in statements:
    case statement.kind
    of skComment:
      collector.pendingComments.add statement.text
    of skDeflower:
      collector.startRun(line, statement.text)
    of skInclude:
      collector.includeFile(line, statement.text)
    of skLine:
      collector.annotationLine(statement, line)
    of skEndBlock:
      if collector.blockBase == -1:
        collector.lineError(line, "'}' without an open block")
      collector.blockBase = -1
  collector.closeRun()
  assertState(collector.errors.len == 0, "Failed to parse " & sourceName & ":\n" & collector.errors.join("\n"))

proc readFlo*(path, sourceName: string): seq[DeflowerRun] =
  ## The runs of the .flo file at `path`, which messages call `sourceName`.
  let collector = newCollector(nil, false, path, @[sourceName], newTable[string, int]())
  collect(readFile(path), sourceName, collector)
  collector.runs
