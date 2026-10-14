---
title: Convert the whole project to Nim
status: open
priority: medium
labels: enhancement
---

Rewrite deflower in Nim. The main gain is a native single-file executable with no JVM, which settles [0019](0019-ship-as-single-executable.md) along the way, and fast start-up for the run-on-every-save loop ([0057](0057-watch-mode.md)).

Size: about 5400 lines of Java in `src/main` and 420 in `src/test`, plus the grammar and about 120 snippet files.

What has to be replaced, not just translated:
- **`mpu6502`** (`com.laamella:mpu6502`, not on Maven Central): `FlowAnalyser` and `ResultWriter` use its `Instruction` table for opcodes, addressing modes, instruction lengths and the illegal opcodes, plus `toSignedByte`/`word`. That needs a Nim table with all 256 opcodes. An illegal opcode that comes out wrong changes the output. `Verifier` and the snippets' round trip also use its assembler, `SourceParser`, so the Nim side needs one too, or has to call 64tass.

  mpu6502 is the user's own library, and its source is available: [github.com/laamella-gad/Mpu6502](https://github.com/laamella-gad/Mpu6502), checked out locally at `~/IdeaProjects/Mpu6502`. It is a small Java 6502 emulator (about 2800 lines in `src/main`), ported from siddump's `sid.c`. Rather than copying only the opcode table into deflower, it would be nice to convert the whole library to Nim as a separate nimble package, which deflower then depends on. That keeps the opcode table in one place and gives a reusable 6502 emulator in Nim. It can be done first, as its own step, before deflower itself is ported.
- **ANTLR** (`Flo.g4` and the generated parser in `com.laamella.enflower`): ANTLR has no Nim target. Options: a hand-written line parser (each line has a fixed shape since [0050](0050-fixed-flo-line-shape.md), so this is small), or a PEG library such as npeg. The format description in the comment at the top of `Flo.g4` is authoritative, so it has to move to wherever the parser lives, or to its own document.
- **Tests:** JUnit 5, AssertJ and snippets-test (`SnippetTestFactory`). The snippet approach is worth keeping: each file in `src/test/snippets/` holds its input and the expected output, and is rewritten when the expectation is missing. Nim's `unittest` plus a small helper that does the same can replace it. The snippet files and the fixtures in `src/test/resources/` move over unchanged and are the acceptance test.

  snippets-test is the user's own library too, and its source is available: [github.com/laamella-gad/snippets-test-junit5](https://github.com/laamella-gad/snippets-test-junit5), checked out locally at `~/IdeaProjects/snippets-test-junit5`. It manages tests that compare a large print-out with an expectation stored on disk. deflower uses only `snippets-test-junit5-core` (about 600 lines in `src/main`). The other modules (antlr, db, json, table, tree, xml) are format-specific. Rather than writing a one-off helper inside deflower, it would be nice to convert the core to Nim as a separate nimble package, on top of `unittest`, which deflower then depends on. Like mpu6502, that can be done first, as its own step.
- **Build:** Maven goes, replaced by a nimble package. CLAUDE.md's Commands section and the `-o` offline note change with it.

Translates fairly directly: `Subject` and the memory model, the `Area` classes (a Nim object variant, or a ref object hierarchy with methods), `FlowAnalyser`, the finders (`AddressSetupFinder`, `SelfModificationFinder`), `CrossReferences`, `ResultWriter`/`AssemblyFileFormat`/`LineEmitter`, `MemoryMap`, `Verifier`, `PrgReader`, the VICE snapshot reader (`vicevcf`, byte-level parsing), and the other modes (`Initializer`, `Dumper`, `Finder`, `TextFinder`).

Approach to decide:
- **Big bang or side by side.** Write the Nim version next to the Java one, for example in its own directory, run both on all fixtures until every `expected.asm` matches, then delete the Java code. Or convert in place.
- **Behaviour changes on the way.** Keep it a straight port: no output changes in the same step, so the existing expectations prove it works. Fix open issues before or after the port.

Done when: a Nim build produces one executable that passes every snippet unchanged, error cases included, the Java sources, pom.xml and grammar are gone, and CLAUDE.md describes the Nim project.

## Decisions

- **Side by side.** The Nim version lives in its own directory next to the Java one. Both run on all fixtures until every `expected.asm` matches, then the Java code is deleted. A straight port: no output changes in the same step.
- **Tracing behind `--verbose`.** Moot since [0077](0077-analysis-warnings-report.md) dropped the tracing: a run prints only warnings, errors, the files it writes and the verify report.
- **Hand-written parser.** A small tokenizer and line parser replace ANTLR, with no dependency. The format description moves from `Flo.g4`'s header to its own document.
