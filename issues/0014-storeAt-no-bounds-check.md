---
title: storeAt does not check bounds
status: done
labels: bug
---

`Subject.storeAt` (`src/main/java/com/laamella/deflower/Subject.java`) writes `memory[startAddress + i]` with no check. A `.prg` whose load address plus length exceeds `$FFFF` throws `ArrayIndexOutOfBoundsException` with no message about the file.

Found by reading the code. Not reproduced.

Done when: `storeAt` rejects an out-of-range write with an error that names the file and address.

## Closing note

`Subject.storeAt` now takes the image's source path and checks `startAddress + bytes.length <= $10000` before copying. Otherwise it fails with `<file>: <n> bytes loaded at <address> run past $FFFF`. `Deflower` prints that message and writes nothing, like any other configuration error. `PrgReader` and `ViceSnapshotReader` pass their file.

Reproduced first with the new fixture `toolong/` (load address `$FFF0`, 32 bytes), which used to end in an `ArrayIndexOutOfBoundsException`. Test: `DeflowerTest#rejectsPrgRunningPastEndOfMemory`. 43/43 tests green, no expectations changed.
