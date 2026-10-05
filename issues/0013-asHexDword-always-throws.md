---
title: asHexDword always throws
status: open
labels: bug
---

`Printing.asHexDword` (`src/main/java/com/laamella/Printing.java`, around line 21) checks `value <= 0xFFFFFFFF`. The literal `0xFFFFFFFF` is an `int` (-1), so the check is `value <= -1`, which is false for every non-negative value. The method throws for every valid input.

The method is unused today. Found by reading the code. Not reproduced.

Done when: `asHexDword` returns the expected string for valid values and a test covers it, or the method is deleted.
