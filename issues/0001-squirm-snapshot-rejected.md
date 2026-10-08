---
title: squirm.vsf rejected as "Old VICE snapshot file"
status: done
labels: bug, test
---

`DeflowerTest.deflowerSquirm` failed with `java.io.IOException: Old VICE snapshot file`, thrown from `ViceVcfFileReader.readHeader` (`src/main/java/com/laamella/vicevcf/ViceVcfFileReader.java`). The reader expected the `VICE Version\032` header after the machine name. `src/test/resources/squirm/squirm.vsf` does not have it.

Root cause: `squirm.vsf` is VICE snapshot format 1.1 (header version bytes `01 01`). That format has no `VICE Version` sub-block; modules start right after the 16-byte machine name. `zwark.vsf` is format 2.0, which does have the block. Confirmed by comparing the hex of both headers.

Fix: `readHeader` now reads the 13 bytes speculatively. If they match `VICE Version\032`, it consumes the version dwords as before. If not, it rewinds the buffer by 13 bytes, since what it read is already the start of the first module, and returns the header without error.

`mvn -o test` passes all three tests.
