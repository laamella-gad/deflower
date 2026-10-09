# CLAUDE.md

Never commit automatically.

Always use snipsert to check generated output.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Deflower semi-automatically disassembles 6502 binaries. The tool traces code automatically, following control flow from entry points. The user supplies the rest by hand: labels, and marked blocks (data, bytes, words, code entries). The `.flo` file is where those annotations live, so the tool is a loop of: run, read the output, add annotations, run again.

Suggested way to use it: keep the disassembler re-running on every save of the `.flo` file, and read the generated `out/<binary>.asm` as it updates. The tool itself does a single run per invocation (`Deflower.main`); there is no built-in file watcher, so the re-run has to come from an external watcher around it.

## Commands

Maven project, Java 14 source/target (JDK 23 installed locally works). Depends on `com.laamella:mpu6502:0.2-SNAPSHOT`, which is not on Maven Central. It must be in the local `~/.m2` repository, so use `-o` (offline) if builds fail to resolve it.

- Build: `mvn -o compile`
- Run all tests: `mvn -o test`
- Run one test class: `mvn -o test -Dtest=DeflowerTest`
- Run one test method: `mvn -o test -Dtest='DeflowerTest#deflowerZwark'`
- Run the tool on a flow file: `Deflower.main` takes a classpath-relative path (e.g. `squirm/squirm.flo`). The file must be on the classpath, so it lives under `src/test/resources`. There is no exec plugin configured, so run it from an IDE or with a manually assembled classpath.
- No linter or formatter is configured.

All `DeflowerTest` cases pass.

## Architecture

The pipeline is: **flow file → parse → memory image + annotations → code-flow analysis → assembly output**. Everything lives in `com.laamella.deflower` except the grammar and the VICE snapshot parser.

- **Input.** A `.flo` file describes the disassembly. Its full, authoritative description is the comment at the top of the grammar, `src/main/antlr4/com/laamella/enflower/Flo.g4` (generated package `com.laamella.enflower`); read it before writing or editing `.flo` lines. In short:
  - `deflower <file>` starts a run: it loads a `.vsf` VICE snapshot or a `.prg`, relative to the `.flo` file. Each run is independent and writes `out/<file without extension>.asm`.
  - An annotation line is `<address or start-end> [virtual] [<type>[<size>]] [<label>] [export <id>] [{]`, with the parts in exactly that order and each at most once. Anything else is a parse error.
    - The range end is exclusive.
    - Types are `char`, `byte`, `word`, `dword` and `code` (an entry point). No type means an `UNKNOWN` placeholder, which a later line may narrow without an area conflict.
    - The size is a number or `*`/`+` over numbers (`byte[40*21]`, `byte[$af]`). A size of 0 is an error.
    - The reserved words can't be labels.
    - `export` and `{ }` parse but do nothing yet.
  - `;`/`#` comments sit on their own line and attach to the next annotation line.
- **`SubjectConfigurer`** drives the two configuration phases.
  - **Parse:** `FloReader` turns the `.flo` file into one `DeflowerRun` per `deflower` line, each holding its `Annotation`s (one per line, plain values; `LineType` is the line's kind). It reads nothing else and changes no memory. Syntax errors abort with "Failed to parse".
  - **Apply:** for each run, `SubjectConfigurer` creates a `Subject`, loads the image (`ViceSnapshotReader` or `PrgReader`, picked by extension), and calls `Subject.annotate` for each annotation. Data lines register one `DataArea` per element; `code` lines push an entry point onto `potentialCodeLocations`.
  - To add `.flo` syntax, change the grammar, `FloReader` and `Annotation`/`Subject.annotate`.
- **`Subject`** holds:
  - the 64K `MemoryLocation[]` (each cell has the byte, an `Area` pointer, a label and a comment);
  - the `potentialCodeLocations` stack and the output path;
  - the `errors` list. `registerBlock` reports one area overwriting a different, non-placeholder one, and `Deflower` skips writing output for a subject with errors.
  - It also answers memory questions used by the output: run and array boundaries (`continuesRun`, `endOfRun`, `endOfArray`), annotations (`isAnnotated`), and the ASCII/screen-code guess (`likelyTextEncoding`).
- **`FlowAnalyser`** pops entry points and follows 6502 control flow using `mpu6502`'s `Instruction` table.
  - It registers an `InstructionArea` for each decoded instruction, follows fall-through and branch/jump/JSR targets (including `JMP (indirect)` through its pointer), and auto-labels targets (`lXXXX`, `dXXXX`, `pXXXX`).
  - Analysis stops at addresses already covered by a non-placeholder area, and won't decode an instruction whose bytes run into one. That is how it avoids loops and detects jumps into data ("Jumping into non-code area").
- **`Area`** is the common base for `DataArea` and `InstructionArea`. Each address belongs to at most one area, and `registerBlock` writes that link into `Subject.memory`. Address ownership is the main signal the analyser uses, so an overlapping `.flo` declaration changes the output.
- **`Deflower`** runs the pipeline. It clears and recreates `<basePath>/out` once per `.flo` file, then for each subject analyses and, if there are no errors, opens `out/<binary>.asm` and hands the writer to `ResultWriter`.
- **`ResultWriter`** walks 0x0000–0xFFFF and drives `AssemblyFileFormat`, which owns the layout and the per-type printing (64tass syntax):
  - `*=` origins at gaps;
  - blank-line separators and label placement inside data runs;
  - `.byte`/`.word`/`.dword`/`.addr` tables;
  - `.text` strings, with `.enc "screen"`/`"none"` switches chosen per char array;
  - `.virtual` blocks;
  - instructions with operands resolved to labels (`label + $offset` inside arrays).

  `LineEmitter` is the low-level writer: lines, indentation, value columns and open quotes.
- **`vicevcf`** parses VICE snapshot files (`ViceVcfFileReader` → `Header` + `Module`s). `C64MemModuleHandler` extracts the `C64MEM` module, which provides the 64K RAM image. Other modules are kept as `UnhandledModule`.
- **`Assert`, `Printing`, `ByteBufferAccess`** in `com.laamella` are small helpers (`assertState`, hex formatting, buffer reads).

Test-driven workflow:
- `DeflowerTest` runs the full pipeline on fixtures in `src/test/resources/<fixture>/` (`<fixture>.flo` plus its binary). The real programs are squirm, zwark and tcmine; the rest are small, purpose-built `.prg` fixtures, one per feature or bug.
- Each run writes its output to `out/<fixture>.asm` next to the `.flo` file under `target/test-classes`, not in the source tree.
- Each test compares that output against the versioned `src/test/resources/<fixture>/expected.asm`, using `com.laamella:snippets-test-junit5-core`'s `Snipsertions.snipsert` (manual: https://github.com/laamella-gad/snippets-test-junit5).
- A changed expectation file in a diff means the generated output changed; review it like any other test failure.
- To accept a new fixture or a deliberate output change, delete the matching `expected.asm` and rerun the test. It creates the file and fails once, so you can review it before committing.
- The small fixtures' `expected.asm` can be checked with 64tass: `64tass -q -b -o x.bin expected.asm` must equal the `.prg` minus its 2-byte header.

Issues are tracked as `issues/NNNN-slug.md` (frontmatter `title`/`status`/`labels`), indexed in `issues/README.md`. To close one, set `status: done`, add a "## Closing note" and update the index row.

## Notes

- Much of the code is debugging-era, with lots of `System.out` tracing ("Marking block", "Unnamed target", "Jumping into non-code area"). Keep that in mind when reading output; it is not a sign of failure.
- Numbers in `.flo` files are decimal, or hex with a `$` prefix.
