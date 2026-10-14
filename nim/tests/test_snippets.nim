## Runs the snippet files in `src/test/snippets` of the Java project, the
## same files DeflowerTest runs (issue 0059). Every snippet has three
## expectations: what Deflower printed (stdout and stderr together), the
## generated `.asm` files, and the other files in `out/`: the memory maps as
## text and the exported binaries as hex dumps. Deflower runs with verify
## on, so the printed part ends with each run's verify report.
##
## A short snippet (`short/`) holds its whole test: assembly source,
## assembled into `test.prg`, then the `.flo` file, written as `test.flo`.
## More input parts are more files, each starting with a `; file: <name>`
## line; a `.prg` one is assembled. Every generated `.asm` must reassemble
## to the bytes of the `.prg` with its name, unless the assembly has a
## `; no round trip` line.
##
## A large snippet (`large/`) names a `.flo` file in `src/test/resources`,
## for programs too big to keep as source in a snippet.
##
## An init snippet (`init/`) names a `.vsf` or `.prg` file in
## `src/test/resources`, and expects the `.flo` skeleton that `--init`
## writes for it (issue 0072).
##
## A dump snippet (`dump/`) names such a file and a range, and expects what
## `--dump` prints for it, or its error (issue 0097). Find and strings
## snippets (`find/`, `strings/`) name such a file and the arguments of
## `--find` (issue 0099) or `--strings` (issue 0100), and expect what it
## prints, or its error.

import std/[algorithm, options, os, strutils, sugar, tempfiles, unittest]
import mpu6502, snippets_test
import deflower/[initializer, look, printing, runner]

const
  projectRoot = currentSourcePath().parentDir / ".." / ".."
  snippets = projectRoot / "src" / "test" / "snippets"
  resources = projectRoot / "src" / "test" / "resources"
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
  ## Writes a file for a short snippet: a .prg is assembled from the text,
  ## anything else is written as it is.
  if name.endsWith(".prg"):
    writeFile(dir / name, cast[string](prg(assemble(text))))
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

proc assertReassembles(dir: string) =
  ## Every byte an out/X.asm assembles to lies inside X.prg and equals the
  ## byte there. Bytes the .asm leaves out, like memory the tracer never
  ## reached, aren't checked.
  let output = dir / "out"
  for asmFile in outFiles(output, true):
    let prgName = extractFilename(asmFile).dup(removeSuffix(".asm")) & ".prg"
    let prgFile = dir / prgName
    if not fileExists(prgFile):
      continue
    let prg = readBytes(prgFile)
    let load = int(prg[0]) or int(prg[1]) shl 8
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
        let offset = 2 + address - load
        let value = toLowerAscii(toHex(int(segment.data[i]), 2))
        if offset < 2 or offset >= prg.len:
          differences.add "$" & toLowerAscii(toHex(address, 4)) & ": " & value & ", outside " & prgName
        elif prg[offset] != segment.data[i]:
          differences.add "$" & toLowerAscii(toHex(address, 4)) & ": " & value & ", should be " &
              toLowerAscii(toHex(int(prg[offset]), 2))
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
  ## A copy of src/test/resources, made once, since a run writes into the
  ## directory of its .flo file.

proc runLarge(parts: seq[string]): seq[string] =
  if parts.len != 1:
    raise newException(SnippetTestFailure, "input: one .flo path in src/test/resources")
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
    raise newException(SnippetTestFailure, "input: one .vsf or .prg path in src/test/resources")
  @[skeleton(resources / parts[0].strip).join("\n") & "\n"]

proc runLook(flag: string): TestCase =
  ## Runs a tool that looks at an input file, on the file the snippet names
  ## in src/test/resources and the arguments after it.
  result = proc (parts: seq[string]): seq[string] =
    if parts.len != 1:
      raise newException(SnippetTestFailure, "input: a .vsf or .prg path in src/test/resources, then the arguments")
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
