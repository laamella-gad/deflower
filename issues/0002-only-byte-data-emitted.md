---
title: Output only emits BYTE data
status: done
labels: enhancement
---

`AssemblyFileFormat.print(DataArea, ...)` in `src/main/java/com/laamella/deflower/ResultWriter.java` had a `switch` with only a `case BYTE`. `WORD`, `DWORD`, `CHAR` and `POINTER` areas were silently skipped in `deflowered.asm`.

Fixed:
- `.WORD` for `WORD` (via `subject.wordAt`), `.DWORD` for `DWORD` (via `subject.dwordAt`), `.BYTE` with a character literal (`'A'`) for printable `CHAR` bytes (falling back to hex for control codes/quotes/backslash), and `.WORD <label>` for `POINTER` (resolving to a label the same way instruction operands do).
- `print(DataArea, ...)` now only emits once per area (`address == block.address`), not once per byte the area covers — needed once areas could span more than one byte.
- Along the way, found and fixed a second bug this surfaced: `SubjectConfigurer.exitLine`'s switch never included `CHAR_BLOCK` in the group that registers data areas, so any `char` line threw `RuntimeException("No data type")` before this fix — `char` annotations were completely broken, not just unprinted.

Covered by `DeflowerTest#emitsWordDwordAndCharData` (`src/test/resources/datatypes/`: two `word`s, one `dword`, three printable `char`s) and `DeflowerTest#followsIndirectJmpTarget` (issue 0011's `POINTER` area). Both expectations were round-tripped through `64tass` by hand to confirm the reassembled bytes match the original binaries exactly.

Done when: each `DataType` produces the matching assembler directive (`.WORD`, `.DWORD` or equivalent, and character data for `CHAR`). ✅
