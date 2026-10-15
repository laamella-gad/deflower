## Verify's report on an .asm that differs from the image. Deflower's own
## output has no known way to differ any more (issue 0086), so the test
## writes the .asm by hand.

import std/[os, tempfiles, unittest]
import deflower/[printing, runner, verifier]

suite "verifier":
  test "reports the bytes that differ and the gaps":
    let dir = createTempDir("deflower", "")
    defer: removeDir(dir)
    writeFile(dir / "test.prg", "\x00\xc0\xa9\x01\x60\xff")
    writeFile(dir / "test.flo", "deflower test.prg\n")
    let subject = configure(dir / "test.flo")[0]
    writeFile(dir / "test.asm", "*=$c000\n\t\tlda #$02\n\t\trts\n*=$c004\n\t\t.byte $00\n")
    var printed: seq[string]
    printOut = proc (line: string) = printed.add line
    defer: printOut = proc (line: string) = stdout.writeLine(line)
    check not verify(subject, dir / "test.asm")
    check printed == @[
      "Verify test.asm: 4 bytes emitted, 2 differ, 0 virtual, 1 gap",
      "differ $c001 expected $01 got $02",
      "differ $c004 expected nothing got $00",
      "gap $c000-$c004"]
