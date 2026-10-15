## The command line: `--help` and the usage.

import std/[sequtils, strutils, unittest]
import deflower
import deflower/printing

suite "command":
  var printed, errors: seq[string]

  setup:
    printed = @[]
    errors = @[]
    printOut = proc (line: string) = printed.add line
    printErr = proc (line: string) = errors.add line

  teardown:
    printOut = proc (line: string) = stdout.writeLine(line)
    printErr = proc (line: string) = stderr.writeLine(line)

  test "--help prints the manual and succeeds":
    for flag in ["--help", "-h"]:
      printed = @[]
      check command(@[flag]) == 0
      check errors.len == 0
      check printed[0].startsWith("Deflower disassembles")
      check printed.anyIt("--strings" in it)
      check printed.anyIt("[until $xx]" in it)
      check printed[^1] == "The full manual is README.md."

  test "no arguments print the usage and fail":
    check command(@[]) == 2
    check printed.len == 0
    check errors[0] == "Usage: deflower [--verify] [--watch] <file.flo>"
    check errors[^1] == "       deflower --help"

  test "an unknown flag prints the usage and fails":
    check command(@["--frobnicate", "game.flo"]) == 2
    check errors[0].startsWith("Usage:")
