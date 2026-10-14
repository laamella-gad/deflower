## The watcher of `--watch` (issue 0057): which changes bring a new run, and
## what a run with errors does to `out/`.

import std/[os, strutils, tempfiles, times, unittest]
import deflower/[printing, runner, watcher]

proc touch(file, text: string) =
  ## Writes the file with a modification time later than any it had, as two
  ## writes within the file system's time resolution would look the same.
  let later = (if fileExists(file): getLastModificationTime(file) else: getTime()) + initDuration(seconds = 1)
  writeFile(file, text)
  setLastModificationTime(file, later)

suite "watch":
  var directory, flo, prg, asmFile: string
  var printed: seq[string]

  setup:
    directory = createTempDir("deflower", "watch")
    flo = directory / "test.flo"
    prg = directory / "test.prg"
    asmFile = directory / "out" / "test.asm"
    # lda #$01, rts at $c000.
    writeFile(prg, "\x00\xc0\xa9\x01\x60")
    writeFile(directory / "labels.flo", "$c001 virtual byte unused\n")
    writeFile(flo, "deflower test.prg\ninclude labels.flo\n$c000 code start\n")
    printed = @[]
    printOut = proc (line: string) = printed.add line
    printErr = proc (line: string) = printed.add line

  teardown:
    printOut = proc (line: string) = stdout.writeLine(line)
    printErr = proc (line: string) = stderr.writeLine(line)
    removeDir(directory)

  test "runs again after a change to the .flo file":
    var watcher = newWatcher(flo, false)
    check watcher.run() == oFine
    check "start" in readFile(asmFile)
    check printed[^1].endsWith(" ok, watching test.flo")
    check not watcher.changed
    touch(flo, "deflower test.prg\ninclude labels.flo\n$c000 code entry\n")
    check watcher.changed
    check watcher.run() == oFine
    check "entry" in readFile(asmFile)
    check not watcher.changed

  test "watches the included files and the binaries":
    var watcher = newWatcher(flo, false)
    check watcher.run() == oFine
    touch(directory / "labels.flo", "$c002 virtual byte unused\n")
    check watcher.changed
    check watcher.run() == oFine
    touch(prg, "\x00\xc0\xa9\x02\x60")
    check watcher.changed
    check watcher.run() == oFine
    check "#$02" in readFile(asmFile)

  test "a run with errors leaves out/ as it was":
    var watcher = newWatcher(flo, false)
    check watcher.run() == oFine
    let written = readFile(asmFile)
    touch(flo, "deflower test.prg\ninclude labels.flo\n$c000 code start\n$c001 byte start\n")
    check watcher.run() == oFailed
    check readFile(asmFile) == written
    check printed[^1].endsWith(" failed, out/ unchanged, watching test.flo")
    touch(flo, "deflower test.prg\n$c000 * start\n")
    check watcher.run() == oFailed
    check readFile(asmFile) == written
    # The files of the last good run are still watched.
    touch(directory / "labels.flo", "$c002 virtual byte unused\n")
    check watcher.changed

  test "a missing binary fails the run, and its appearing brings a new one":
    removeFile(prg)
    var watcher = newWatcher(flo, false)
    check watcher.run() == oFailed
    writeFile(prg, "\x00\xc0\xa9\x01\x60")
    check watcher.changed
    check watcher.run() == oFine
