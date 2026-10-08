---
title: asHexDword always throws
status: done
labels: bug
---

`Printing.asHexDword` (`src/main/java/com/laamella/Printing.java`, around line 21) checks `value <= 0xFFFFFFFF`. The literal `0xFFFFFFFF` is an `int` (-1), so the check is `value <= -1`, which is false for every non-negative value. The method throws for every valid input.

The method is unused today. Found by reading the code. Not reproduced.

Done when: `asHexDword` returns the expected string for valid values and a test covers it, or the method is deleted.

**Fix:** changed the bound to `0xFFFFFFFFL` (a `long`), so the comparison actually compares against 4294967295 instead of -1. Added `PrintingTest` covering a valid mid-range value and the negative-rejection case.

Residual gap, not fixed here: since `value` is a signed 32-bit `int`, the method can never actually receive the top half of the dword range (`0x80000000`-`0xFFFFFFFF`) as a positive number - those bit patterns arrive as negative ints and get rejected by `value >= 0`. Fixing that would mean widening the parameter to `long`, which is out of scope for this fix (method has no callers today). Noted here in case a future caller needs the full range.

Verified with `mvn -o test`: 7/7 pass.
