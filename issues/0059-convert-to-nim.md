---
title: Convert the whole project to Nim
status: open
priority: medium
labels: enhancement
---

Rewrite deflower in Nim. The main gain is a native single-file executable with no JVM, which settles [0019](0019-ship-as-single-executable.md) along the way, and fast start-up for the run-on-every-save loop ([0057](0057-watch-mode.md)). [0056](0056-help-flag.md), [0057](0057-watch-mode.md) and [0082](0082-mcp-server.md) wait for it, so their command line is written once, in Nim.

## Size

Checked on 2026-10-14:
- **deflower**: 5375 lines of Java in `src/main`, the grammar `Flo.g4` (mostly its format comment), 420 lines in `src/test` (`DeflowerTest` 329, the rest `PrintingTest`), and 123 snippet files (`short` 78, `large` 13, `init` 10, `find` 9, `strings` 7, `dump` 6). The largest classes are `Subject` (760), `ResultWriter` with `AssemblyFileFormat` (720), `Initializer` (578) and `FloReader` (488).
- **mpu6502**: 3774 lines. Deflower uses only part of it: the opcode table (`specification`: `Instruction`, `Opcode`, `AddressingMode`, about 720 lines), `ByteManipulation`, and the assembler (`SourceParser` with `Segment`, about 600 lines plus `assembler` helpers). The emulator core (`Mpu6502`, 1289 lines) is unused today; [0096](0096-run-the-code.md) would need it.
- **snippets-test-junit5-core**: 621 lines.
- Nim 2.2.10 and nimble are installed, and so is 64tass.

## What has to be replaced, not just translated

- **mpu6502** ([github.com/laamella-gad/Mpu6502](https://github.com/laamella-gad/Mpu6502), the user's own, checked out at `~/IdeaProjects/Mpu6502`). The opcode table decides how every byte decodes; an illegal opcode that comes out wrong changes the output. `SourceParser` is what `Verifier` and the snippets' round trip assemble with, so the Nim side needs an assembler too. Calling 64tass instead would bring back an outside dependency for `--verify`, and the snippets were checked against `SourceParser`, which differs from 64tass in places (e.g. `<label + 1`, issue [0074](0074-detect-address-setup-pattern.md)). Plan: convert mpu6502 to Nim in deflower's source tree but kept apart (see Decisions), the opcode table and the assembler first, the emulator core when [0096](0096-run-the-code.md) needs it.
- **ANTLR** (`Flo.g4` and the generated parser in `com.laamella.enflower`). ANTLR has no Nim target. Decided: [npeg](https://github.com/zevv/npeg) (see Decisions). The format description in `Flo.g4`'s header moves to a document of its own, e.g. `docs/flo-format.md`, which `CLAUDE.md` then points to.
- **Parse error messages.** 9 snippets expect ANTLR's wording: `line 2:8 mismatched input '*' expecting {'virtual', 'banked', ...}`, `missing NEWLINE at '$0900'`, `extraneous input 'foo' expecting NEWLINE`. npeg won't reproduce these, and shouldn't: they list grammar tokens, not what the user should write.
- **snippets-test** ([github.com/laamella-gad/snippets-test-junit5](https://github.com/laamella-gad/snippets-test-junit5), the user's own, checked out at `~/IdeaProjects/snippets-test-junit5`). It finds the snippet files, splits them into parts and expectations, compares, and rewrites missing expectations (`REGENERATE_EXPECTATIONS`). Deflower uses only the core (`SnippetTestFactory`, `SnippetFileFormat`, `BasePath`). Plan: convert the core to Nim on top of `unittest`, in deflower's source tree but kept apart (see Decisions). The snippet file format stays the same, so the 123 files move over unchanged.

  What runs each snippet is deflower's own: `DeflowerTest` (329 lines) gives the library one function per kind (`runShort`, `runLarge`, `runInit`, `runDump`, `runFind`, `runStrings`), which turns a snippet's input parts into its expected parts. They write the parts to a temporary directory, assemble `.prg` parts with `SourceParser`, run deflower and capture what it prints, hex-dump exported binaries, and check the round trip. These port along with deflower, on top of the Nim snippets-test.
- **Built-in includes.** `src/main/resources/deflower/c64*.flo` are read from the classpath. In Nim they are compiled into the executable (`staticRead`), so the single file still has them.
- **Build and scripts.** Maven, `pom.xml` and the `./deflower` script with its cached classpath go; a nimble package builds one executable. `CLAUDE.md`'s Commands section changes with it.

## What translates fairly directly

`Subject` and the memory model; the `Area` classes (a Nim object variant, or `ref object` with methods); `FlowAnalyser`; `AddressSetupFinder` and `SelfModificationFinder`; `CrossReferences`; `ResultWriter`/`AssemblyFileFormat`/`LineEmitter`; `MemoryMap`; `Verifier`; `PrgReader`, `MemoryImage` and the VICE snapshot reader (`vicevcf`, byte-level parsing); and the other modes (`Initializer`, `Dumper`, `Finder`, `TextFinder`).

Spots where Java behaviour leaks into the output and the port has to match it on purpose:
- iteration order of the maps and sets that feed the output (`HashMap` against `TreeMap`/`LinkedHashSet`): where the Java code relies on a sorted or insertion order, Nim needs the same, and where the order is a `HashMap`'s, the snippets fix it, so it is worth making explicit in Java first;
- `String.format` and `Integer.toHexString` (case, padding);
- sort stability (`Comparator` chains, `Stream.sorted`);
- error and warning texts, word for word.

## Steps

1. **mpu6502 in Nim**: the opcode table and `ByteManipulation`, with a test that decodes all 256 opcodes like the Java table; then `SourceParser`, with its own tests. Deflower's round trip then checks that it assembles every snippet's output to the same bytes as the Java one.
2. **snippets-test core in Nim**, with its Java tests ported (`SplitTest`, `TestCaseFilenameFilterTest`, `SnippetTestFactoryTest` and their resource files), not deflower's snippets.
3. **Prepare in Java**: everything that changes snippet output, done before the port so the snippets stay the measure: parse error messages in deflower's own words (see "To decide"), and explicit orders where a `HashMap`'s order reaches the output.
4. **Port deflower**, in pipeline order, each step turning more snippets green: `.flo` parsing; the loaders; `Subject`, the tracing and the finders; the writer, the map and `Verifier` (now all `short` and `large` snippets); then `--init`, `--dump`, `--find`, `--strings`.
5. **Switch over**: the Nim executable passes all 123 snippets; delete the Java sources, `pom.xml`, the grammar and `./deflower`'s classpath handling; update `CLAUDE.md` and the open issues that name Java classes.

## To decide

- **Where the Nim code lives.** `~/IdeaProjects/deflower_nim` holds an earlier start (May 2026, one commit, 289 lines): a `.flo` tokenizer for the grammar of then (`system`, `char`, no blocks, includes or parameters), and a `CLAUDE.md` that describes deflower as it was. Too little and too old to build on. Options: a `nim/` directory in this repository, sharing `src/test/snippets/` and `src/test/resources/` directly and keeping one history (recommended); or the separate repository, restarted, which then needs the snippets and fixtures copied or linked.
- **Parse error wording.** Write deflower's own messages in the Java `FloReader` first (step 3), e.g. `line 2: expected a type or a label, found '*'`, so the 9 snippets change once, in Java, and the Nim parser then matches them. Or let only those 9 snippets change in the port. The first keeps "passes every snippet unchanged" exact.
- **Feature work during the port.** Every change to the Java code during the port has to be made twice. Either freeze features until the switch, or accept porting late changes, with the snippets showing what is missing.

Done when: a Nim build produces one executable that passes every snippet (with the parse error wording as decided), `--verify` works without outside tools, the Java sources, `pom.xml` and grammar are gone, the `.flo` format is described in its own document, and `CLAUDE.md` describes the Nim project.

## Decisions

- **Side by side.** The Nim version is written next to the Java one. Both run on all snippets until the Nim one passes every one, then the Java code is deleted.
- **A straight port.** No output changes in the same step; open issues are fixed before or after the port. Output changes the port needs (parse errors) are made in Java first, or decided above.
- **npeg replaces ANTLR.** [npeg](https://github.com/zevv/npeg) (MIT, by zevv, after Lua's LPeg; the most used Nim parsing library, 1.3.0 installed) turns a PEG grammar written in Nim into Nim procs at compile time, so it adds no run-time dependency to the single executable. The grammar stays a grammar, as `Flo.g4` is now, rather than hand-written code. Its code-block captures fill the `Annotation`s directly, so there is no generated parse tree to walk as `FloReader` does now. For errors it has `E"..."` atoms, which fail with a message of our own (`E"a label"` after a type), and `matchMax`, the furthest position reached; a quick try gave `a label at 6` for `$c000 * foo`. That fits deflower's own error wording (step 3). Others looked at: `std/pegs` (string-based patterns, no captures with code, weaker errors), nimly (LALR(1) lexer and parser generator, less used, nothing on error messages). The format description moves from `Flo.g4`'s header to its own document.
- **mpu6502 and snippets-test live in deflower's source tree, but apart.** Each is its own directory (e.g. `mpu6502/` and `snippets_test/` next to deflower's own sources), with its own tests. They don't import deflower or each other, and hold nothing deflower-specific: deflower uses them only through their public procs, as it would a library. Deflower's snippet runners stay in deflower's tests. That way each can be split off into its own nimble package and repository later, by moving the directory, without changing its code.
- **No tracing.** [0077](0077-analysis-warnings-report.md) dropped it, so there is no `--verbose` to port: a run prints only warnings, errors, the files it writes and the verify report.
