---
title: Output only emits BYTE data
status: open
labels: enhancement
---

`AssemblyFileFormat.print(DataArea, ...)` in `src/main/java/com/laamella/deflower/ResultWriter.java` has a `switch` with only a `case BYTE`. `WORD`, `DWORD` and `CHAR` areas are silently skipped in `deflowered.asm`. The grammar and `SubjectConfigurer` already accept these types.

Done when: each `DataType` produces the matching assembler directive (`.WORD`, `.DWORD` or equivalent, and character data for `CHAR`).
