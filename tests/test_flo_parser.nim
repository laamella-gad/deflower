## The committed `.flo` parser is what lindeboom generates from `flo.ldb`
## now (`nimble flo`), skipped when lindeboom's sources aren't there, and
## README.md shows the grammar.

import std/[algorithm, os, osproc, strutils, unittest]

const floDir = currentSourcePath.parentDir.parentDir / "src" / "deflower" / "flo"

proc generatedFiles(dir: string): seq[string] =
  ## The Nim files in `dir` and below, relative to it.
  for path in walkDirRec(dir):
    if path.endsWith(".nim"):
      result.add path.relativePath(dir)
  result.sort()

suite "flo parser":
  test "the committed parser matches the grammar":
    let lindeboom = getEnv("LINDEBOOM_SRC", floDir / ".." / ".." / ".." / ".." / "nim_parser_generator")
    if not fileExists(lindeboom / "src" / "nim_parser_generator.nim"):
      skip()
    else:
      let work = getTempDir() / "deflower_flo_parser_" & $getCurrentProcessId()
      createDir(work)
      defer: removeDir(work)
      let exe = work / "lindeboom"
      let build = execCmdEx("nim c -d:release --hints:off --nimcache:" & quoteShell(work / "cache") &
          " -o:" & quoteShell(exe) & " " & quoteShell(lindeboom / "src" / "nim_parser_generator.nim"))
      check build.exitCode == 0
      let generate = execCmdEx(quoteShell(exe) & " gen --standalone -o " & quoteShell(work / "flo") & " " &
          quoteShell(floDir / "flo.ldb"))
      check generate.exitCode == 0
      let files = generatedFiles(work / "flo")
      check files.len > 0
      check files == generatedFiles(floDir)
      for file in files:
        checkpoint file & " differs; run `nimble flo`"
        check readFile(work / "flo" / file) == readFile(floDir / file)

  test "README.md shows the grammar":
    let grammar = readFile(floDir / "flo.ldb")
    check grammar[grammar.find("grammar Flo;") .. ^1] in readFile(floDir / ".." / ".." / ".." / "README.md")
