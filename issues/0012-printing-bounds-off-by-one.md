---
title: Printing bounds checks admit out-of-range values
status: done
labels: bug, cleanup
---

`Printing.asAddress` and `asHexWord` (`src/main/java/com/laamella/Printing.java`) check `<= 0x10000`, which admits one past the last valid value. `asHexByte` checks `<= 0x100`, same problem. The check should be `< 0x10000` and `<= 0xFF`.

Found by reading the code. Not reproduced. Low impact today because callers pass values from memory indices.

Done when: the bounds checks reject `0x10000` and `0x100`, and a unit test covers the edges.

**Fix:** changed the upper bounds to `<= 0xFFFF` (`asAddress`, `asHexWord`) and `<= 0xFF` (`asHexByte`). Checked all call sites (`Area`, `Subject`, `ResultWriter`) - they only ever pass real memory addresses (0-0xFFFF) or byte values (0-0xFF), never the former one-past edge, so no caller depended on the old leniency.

`PrintingTest` (added for [0013](0013-asHexDword-always-throws.md)) already had `RejectsValuesAboveRange` tests; updated their boundary values (`0x10001`→`0x10000`, `0x101`→`0x100`) to match the tightened check, and removed the three tests that had pinned the old buggy behavior.

Verified with `mvn -o test`: 16/16 pass.
