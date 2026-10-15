## The deflower command. `--help` and README.md describe its arguments.

import std/[os, strutils]
import deflower/[initializer, look, printing, runner, watcher]

const help = staticRead("deflower/help.txt")

proc printUsage() =
  printErr("Usage: deflower [--verify] [--watch] <file.flo>")
  printErr("       deflower --init <file.vsf or file.prg>")
  printErr("       deflower --dump <file.vsf or file.prg> <start>-<end>")
  printErr("       deflower --find <file.vsf or file.prg> <address or bytes> [in <start>-<end>]")
  printErr("       deflower --strings <file.vsf or file.prg> [<start>-<end>] [min <n>]")
  printErr("       deflower --help")

proc command*(args: seq[string]): int =
  ## Runs the command line and returns the exit code. `--watch` only
  ## returns when interrupted.
  if args.len == 1 and args[0] in ["--help", "-h"]:
    for line in help.strip(leading = false).splitLines:
      printOut(line)
    return 0
  if args.len == 2 and args[0] == "--init":
    return (if writeSkeleton(args[1]): 0 else: 1)
  if args.len >= 2 and args[0] in ["--dump", "--find", "--strings"]:
    try:
      for line in look(args[0], args[1], args[2 .. ^1]):
        printOut(line)
    except ArgumentError as e:
      printErr(e.msg)
      return 2
    return 0
  var verify = false
  var watching = false
  var flowerFile = ""
  for arg in args:
    if arg == "--verify":
      verify = true
    elif arg == "--watch":
      watching = true
    elif flowerFile.len == 0 and not arg.startsWith("-"):
      flowerFile = arg
    else:
      flowerFile = ""
      break
  if flowerFile.len == 0:
    printUsage()
    return 2
  if not fileExists(flowerFile):
    printErr("No such file: " & flowerFile)
    return 2
  if watching:
    setControlCHook(proc () {.noconv.} = quit(0))
    watch(flowerFile, verify)
  if not deflower(flowerFile, verify): 1 else: 0

when isMainModule:
  quit(command(commandLineParams()))
