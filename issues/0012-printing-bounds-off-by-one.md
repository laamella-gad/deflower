---
title: Printing bounds checks admit out-of-range values
status: open
labels: bug, cleanup
---

`Printing.asAddress` and `asHexWord` (`src/main/java/com/laamella/Printing.java`) check `<= 0x10000`, which admits one past the last valid value. `asHexByte` checks `<= 0x100`, same problem. The check should be `< 0x10000` and `<= 0xFF`.

Found by reading the code. Not reproduced. Low impact today because callers pass values from memory indices.

Done when: the bounds checks reject `0x10000` and `0x100`, and a unit test covers the edges.
