---
title: storeAt does not check bounds
status: open
labels: bug
---

`Subject.storeAt` (`src/main/java/com/laamella/deflower/Subject.java`) writes `memory[startAddress + i]` with no check. A `.prg` whose load address plus length exceeds `$FFFF` throws `ArrayIndexOutOfBoundsException` with no message about the file.

Found by reading the code. Not reproduced.

Done when: `storeAt` rejects an out-of-range write with an error that names the file and address.
