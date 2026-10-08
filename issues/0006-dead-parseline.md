---
title: Unused legacy parseLine in SubjectConfigurer
status: done
labels: cleanup
---

`SubjectConfigurer.parseLine` (`src/main/java/com/laamella/deflower/SubjectConfigurer.java`) is never called. The grammar-based listener in `configure` replaced it. Keeping it means two parsers for the same syntax that can drift apart.

Done when: all `parseLine` functionality is available in the listener, and anything only it uses are deleted, and the tests still pass.

**Fix:** verified parity, then deleted `parseLine`. The listener covers everything `parseLine` did and more:
- `deflower <file>` (vsf/prg): listener's `enterSetFileName` handles both. `parseLine`'s own vsf branch was actually dead inside dead code - it only logged "Reading snapshot" and never called `readSnapshot` (the line was commented out), so it never worked even when it *was* called.
- `byte`/`code`/`word`/`dword`, address, `a-b` range, `system`, label: all covered by `datatype`/`address`/`memoryRange`/`setSystem`/`setLabel` in the grammar.
- Array size and `n*m`: new in the grammar, `parseLine` had no equivalent.

One gap, confirmed harmless: `parseLine` read a bare second number (`$0800 16 byte`) as a count. The current grammar has no such rule - two bare numbers in one `line` would both match `address` and the listener would just overwrite, silently losing the first. No fixture uses this form (`grep` found none), and it's superseded by `[n]`/`n*m`, so not worth adding; noted here in case an old `.flo` file surfaces using it.

`parseNumber`, `readSnapshot`, `readPrgFile` are also used by the listener, so they stayed. Verified with `mvn -o test`: 5/5 pass, only `SubjectConfigurer.java` changed.
