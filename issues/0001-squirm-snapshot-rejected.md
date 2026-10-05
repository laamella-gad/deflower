---
title: squirm.vsf rejected as "Old VICE snapshot file"
status: open
labels: bug, test
---

`DeflowerTest.deflowerSquirm` fails with `java.io.IOException: Old VICE snapshot file`, thrown from `ViceVcfFileReader.readHeader` (`src/main/java/com/laamella/vicevcf/ViceVcfFileReader.java`). The reader expects the `VICE Version\032` header after the machine name. `src/test/resources/squirm/squirm.vsf` does not have it, so the snapshot format or the reader is wrong.

Done when: `mvn -o test` passes `deflowerSquirm`, either by supporting this snapshot's format or by replacing the fixture with a supported one.
