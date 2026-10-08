---
title: Output only emits BYTE data
status: open
labels: enhancement
---

`AssemblyFileFormat.print(DataArea, ...)` in `src/main/java/com/laamella/deflower/ResultWriter.java` has a `switch` with only a `case BYTE`. `WORD`, `DWORD`, `CHAR` and `POINTER` areas are silently skipped in `deflowered.asm`. The grammar and `SubjectConfigurer` already accept the first three; `FlowAnalyser` (issue 0011) now registers `POINTER` areas itself for `JMP (indirect)` targets.

Reproduced: `src/test/resources/indirectjmp/expected.asm` labels `_C010_POINTER` but emits no bytes for it. Re-assembling that file with 64tass confirms the gap is real, not just cosmetic — the two pointer bytes come out as `$00 $00` instead of the original `$20 $C0`, so `JMP ($C010)` in the reassembled binary jumps through a zero pointer instead of to `$C020`. (The surrounding unclaimed-memory gaps also reassemble as zero-fill instead of the original `$EA` filler, but that's cosmetic — never executed — and is just how unowned memory already reassembles for every fixture, not specific to `POINTER`.)

Done when: each `DataType` produces the matching assembler directive (`.WORD`, `.DWORD`, `.POINTER` or equivalent, and character data for `CHAR`), and a test confirms a `POINTER`/`WORD` area's bytes round-trip through reassembly (e.g. extend `indirectjmp`'s expectation once this is fixed).
