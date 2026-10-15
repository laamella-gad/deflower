## Runs the snippet files in `tests/snippets`. CLAUDE.md describes the
## kinds of snippets and their format.

import std/[algorithm, options, os, sequtils, strutils, sugar, tempfiles, unittest]
import mpu6502, snippets_test
import deflower/[initializer, look, printing, runner]

const
  testsDir = currentSourcePath().parentDir
  snippets = testsDir / "snippets"
  resources = testsDir / "resources"
  fileHeader = "; file: "
  noRoundTrip = "; no round trip"
    ## In a snippet's assembly, skips the round trip, for a snippet that
    ## shows what verify reports when the output doesn't reassemble.

let format = snippetFileFormat(">>>", "<<<\n", "===\n", "^^^\n", "~~~\n", "vvv\n")

proc readBytes(path: string): seq[byte] =
  cast[seq[byte]](readFile(path))

proc prg(segments: seq[Segment]): seq[byte] =
  ## The segments as one .prg: the load address, then everything from the
  ## lowest to the highest byte, with zeroes in the gaps.
  var start = high(int)
  var finish = 0
  for segment in segments:
    start = min(start, segment.loadAddress)
    finish = max(finish, segment.loadAddress + segment.data.len)
  if segments.len == 0:
    start = 0
  result = newSeq[byte](2 + finish - start)
  result[0] = byte(start and 0xff)
  result[1] = byte((start shr 8) and 0xff)
  for segment in segments:
    for i in 0 ..< segment.data.len:
      result[2 + segment.loadAddress - start + i] = segment.data[i]

proc writeSnippetFile(dir, name, text: string) =
  ## Writes a file for a short snippet: a .prg is assembled from the text, a
  ## .bin too but without the load address, anything else is written as it
  ## is.
  if name.endsWith(".prg"):
    writeFile(dir / name, cast[string](prg(assemble(text))))
  elif name.endsWith(".bin"):
    writeFile(dir / name, cast[string](prg(assemble(text))[2 .. ^1]))
  else:
    writeFile(dir / name, text)

proc outFiles(output: string, asmFiles: bool): seq[string] =
  if not dirExists(output):
    return
  for kind, file in walkDir(output):
    if file.endsWith(".asm") == asmFiles:
      result.add file
  result.sort()

proc hexDump(bytes: seq[byte]): string =
  var line = 0
  while line < bytes.len:
    result.add toLowerAscii(toHex(line, 4)) & ":"
    for i in line ..< min(line + 16, bytes.len):
      result.add " " & toLowerAscii(toHex(int(bytes[i]), 2))
    result.add "\n"
    line += 16

proc endLine(text: string): string =
  ## Ends the text with a newline, so the snippet separator after it starts
  ## a line of its own.
  if text.len == 0 or text.endsWith("\n"): text else: text & "\n"

proc runDeflower(flowerFile: string): seq[string] =
  ## Runs Deflower on the .flo file and returns the three outputs.
  var printed = ""
  let originalOut = printOut
  let originalErr = printErr
  printOut = proc (line: string) = printed.add line & "\n"
  printErr = printOut
  try:
    discard deflower(flowerFile, verify = true)
  finally:
    printOut = originalOut
    printErr = originalErr
  let output = parentDir(flowerFile) / "out"
  let asmFiles = outFiles(output, true)
  var asmText = ""
  for file in asmFiles:
    if asmFiles.len > 1:
      asmText.add "--- " & extractFilename(file) & "\n"
    asmText.add readFile(file)
  var binaries = ""
  for file in outFiles(output, false):
    binaries.add "--- " & extractFilename(file) & "\n"
    binaries.add(if file.endsWith(".map"): readFile(file) else: hexDump(readBytes(file)))
  @[endLine(printed), endLine(asmText), binaries]

proc loadedMemory(dir: string, lines: seq[string]): seq[int] =
  ## The 64K that a deflower line and its load lines load, as values 0-255
  ## and -1 for memory they don't load: each .prg at its own address or the
  ## at one, each .bin at the at one, from its from offset and size bytes.
  ## Read here without Deflower's loader, to check that too.
  result = newSeq[int](0x10000)
  for i in 0 ..< result.len:
    result[i] = -1
  for line in lines:
    let words = line.splitWhitespace
    let bytes = readBytes(dir / words[1])
    var options: seq[(string, int)]
    for i in countup(2, words.len - 2, 2):
      let value = words[i + 1]
      options.add (words[i], if value.startsWith("$"): parseHexInt(value[1 .. ^1]) else: parseInt(value))
    var address = -1
    var offset = 0
    var size = -1
    for (name, value) in options:
      case name
      of "at": address = value
      of "from": offset = value
      of "size": size = value
    var data: seq[byte]
    if words[1].endsWith(".prg"):
      if address == -1:
        address = int(bytes[0]) or int(bytes[1]) shl 8
      data = bytes[2 .. ^1]
    else:
      data = bytes[offset ..< (if size == -1: bytes.len else: offset + size)]
    for i in 0 ..< min(data.len, 0x10000 - address):
      result[address + i] = int(data[i])

proc runImages(dir: string): seq[(string, seq[string])] =
  ## For each deflower line of the snippet's test.flo whose file is a .prg
  ## or .bin, the name of its .asm and its deflower and load lines.
  for line in readFile(dir / "test.flo").splitLines:
    let words = line.splitWhitespace
    if words.len < 2:
      continue
    if words[0] == "deflower":
      result.add (words[1].splitFile.name & ".asm", @[line])
    elif words[0] == "load" and result.len > 0:
      result[^1][1].add line
  result = result.filterIt(it[1][0].splitWhitespace[1].splitFile.ext in [".prg", ".bin"] and
      fileExists(dir / it[1][0].splitWhitespace[1]))

proc assertReassembles(dir: string) =
  ## Every byte an out/X.asm assembles to is loaded by the run that wrote it
  ## and equals the byte there. Bytes the .asm leaves out, like memory the
  ## tracer never reached, aren't checked.
  let output = dir / "out"
  for (asmName, lines) in runImages(dir):
    let asmFile = output / asmName
    if not fileExists(asmFile):
      continue
    let memory = loadedMemory(dir, lines)
    let prgName = lines[0].splitWhitespace[1]
    var segments: seq[Segment]
    try:
      segments = assemble(readFile(asmFile), proc (fileName: string): Option[seq[byte]] =
        some(readBytes(output / fileName)))
    except CatchableError as e:
      raise newException(SnippetTestFailure, extractFilename(asmFile) & " doesn't reassemble: " & e.msg)
    var differences: seq[string]
    for segment in segments:
      for i in 0 ..< segment.data.len:
        let address = segment.loadAddress + i
        let value = toLowerAscii(toHex(int(segment.data[i]), 2))
        if address > 0xffff or memory[address] == -1:
          differences.add "$" & toLowerAscii(toHex(address, 4)) & ": " & value & ", outside " & prgName
        elif memory[address] != int(segment.data[i]):
          differences.add "$" & toLowerAscii(toHex(address, 4)) & ": " & value & ", should be " &
              toLowerAscii(toHex(memory[address], 2))
    if differences.len > 0:
      raise newException(SnippetTestFailure, extractFilename(asmFile) & " doesn't reassemble to " & prgName & ":\n" &
          differences[0 ..< min(10, differences.len)].join("\n") &
          (if differences.len > 10: "\n... " & $(differences.len - 10) & " more" else: ""))

proc runShort(parts: seq[string]): seq[string] =
  if parts.len < 2:
    raise newException(SnippetTestFailure, "input parts: assembly, then the .flo file")
  let dir = createTempDir("deflower", "")
  try:
    if parts[0].strip.len > 0:
      writeSnippetFile(dir, "test.prg", parts[0])
    writeFile(dir / "test.flo", parts[1])
    for part in parts[2 .. ^1]:
      if not part.startsWith(fileHeader):
        raise newException(SnippetTestFailure, "extra input part doesn't start with " & fileHeader)
      let endOfHeader = part.find('\n')
      writeSnippetFile(dir, part[fileHeader.len ..< endOfHeader].strip, part[endOfHeader + 1 .. ^1])
    result = runDeflower(dir / "test.flo")
    if noRoundTrip notin parts[0]:
      assertReassembles(dir)
  finally:
    removeDir(dir)

var largeResources = ""
  ## A copy of tests/resources, made once, since a run writes into the
  ## directory of its .flo file.

proc runLarge(parts: seq[string]): seq[string] =
  if parts.len != 1:
    raise newException(SnippetTestFailure, "input: one .flo path in tests/resources")
  if largeResources.len == 0:
    largeResources = createTempDir("deflower", "")
    copyDir(resources, largeResources)
  runDeflower(largeResources / parts[0].strip)

suite "short snippets":
  runSnippetTests(format, fromPath(snippets / "short"), filesWithExtension("txt"), runShort)

  test "accepts last line without newline":
    # A snippet can't hold a file without a trailing newline, since every
    # part ends in one (issue 0088).
    let source = "*=$c000\nstart:\n\t\tlda data\n\t\trts\ndata:\n\t\t.byte\t$01\n"
    for lastLine in ["$c004 byte data", "; a comment"]:
      let flo = "deflower test.prg\n$c000 code start\n" & lastLine
      check runShort(@[source, flo]) == runShort(@[source, flo & "\n"])

suite "large snippets":
  runSnippetTests(format, fromPath(snippets / "large"), filesWithExtension("txt"), runLarge)

proc runInit(parts: seq[string]): seq[string] =
  if parts.len != 1:
    raise newException(SnippetTestFailure, "input: a .vsf, .prg or .bin path in tests/resources, then its options")
  let input = parts[0].strip.splitWhitespace
  var options = input[1 .. ^1]
  try:
    @[skeleton(resources / input[0], takeImage(input[0], options)).join("\n") & "\n"]
  except ArgumentError as e:
    @[e.msg & "\n"]

proc runLook(flag: string): TestCase =
  ## Runs a tool that looks at an input file, on the file the snippet names
  ## in tests/resources and the arguments after it.
  result = proc (parts: seq[string]): seq[string] =
    if parts.len != 1:
      raise newException(SnippetTestFailure, "input: a .vsf, .prg or .bin path in tests/resources, then the arguments")
    let input = parts[0].strip.splitWhitespace
    try:
      @[look(flag, resources / input[0], input[1 .. ^1]).join("\n") & "\n"]
    except ArgumentError as e:
      @[e.msg & "\n"]

suite "init snippets":
  runSnippetTests(format, fromPath(snippets / "init"), filesWithExtension("txt"), runInit)

suite "dump snippets":
  runSnippetTests(format, fromPath(snippets / "dump"), filesWithExtension("txt"), runLook("--dump"))

suite "find snippets":
  runSnippetTests(format, fromPath(snippets / "find"), filesWithExtension("txt"), runLook("--find"))

suite "strings snippets":
  runSnippetTests(format, fromPath(snippets / "strings"), filesWithExtension("txt"), runLook("--strings"))
