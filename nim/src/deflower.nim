## The deflower command.
##
## Usage: [--verify] <.flo file>. Exits with 1 when a run has errors or,
## with --verify, doesn't verify. Or: --init <.vsf or .prg file>, which
## writes a .flo skeleton next to the file to start its disassembly (issue
## 0072), and exits with 1 when that .flo file exists already. Or: --dump
## <.vsf or .prg file> <range>, which hex-dumps that memory of the file
## (issue 0097). Or: --find <.vsf or .prg file> <address or bytes> [in
## <range>], which searches its memory (issue 0099). Or: --strings <.vsf or
## .prg file> [<range>] [min <n>], which lists the text in its memory
## (issue 0100).

import std/[os, strutils]
import deflower/[initializer, look, printing, runner]

proc main() =
  let args = commandLineParams()
  if args.len == 2 and args[0] == "--init":
    if not writeSkeleton(args[1]):
      quit(1)
    return
  if args.len >= 2 and args[0] in ["--dump", "--find", "--strings"]:
    try:
      for line in look(args[0], args[1], args[2 .. ^1]):
        printOut(line)
    except ArgumentError as e:
      printErr(e.msg)
      quit(2)
    return
  var verify = false
  var flowerFile = ""
  for arg in args:
    if arg == "--verify":
      verify = true
    elif flowerFile.len == 0 and not arg.startsWith("--"):
      flowerFile = arg
    else:
      flowerFile = ""
      break
  if flowerFile.len == 0:
    printErr("Usage: deflower [--verify] <file.flo>")
    printErr("       deflower --init <file.vsf or file.prg>")
    printErr("       deflower --dump <file.vsf or file.prg> <start>-<end>")
    printErr("       deflower --find <file.vsf or file.prg> <address or bytes> [in <start>-<end>]")
    printErr("       deflower --strings <file.vsf or file.prg> [<start>-<end>] [min <n>]")
    quit(2)
  if not fileExists(flowerFile):
    printErr("No such file: " & flowerFile)
    quit(2)
  if not deflower(flowerFile, verify):
    quit(1)

when isMainModule:
  main()
