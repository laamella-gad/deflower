# CLAUDE.md

Never commit automatically.

Always use snipsert to check generated output.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Deflower semi-automatically disassembles 6502 binaries. The tool traces code automatically, following control flow from entry points. The user supplies the rest by hand: labels, and marked areas (data, bytes, words, code entries). The `.flo` file is where those annotations live, so the tool is a loop of: run, read the output, add annotations, run again.

Suggested way to use it: keep the disassembler re-running on every save of the `.flo` file, and read the generated `out/<binary>.asm` as it updates. The tool itself does a single run per invocation (`Deflower.main`); there is no built-in file watcher, so the re-run has to come from an external watcher around it.

## Commands

Maven project, Java 14 source/target (JDK 23 installed locally works). Depends on `com.laamella:mpu6502:0.2-SNAPSHOT`, which is not on Maven Central. It must be in the local `~/.m2` repository, so use `-o` (offline) if builds fail to resolve it.

- Build: `mvn -o compile`
- Run all tests: `mvn -o test`
- Run one test class: `mvn -o test -Dtest=DeflowerTest`
- Run only the short or large snippets: `mvn -o test -Dtest='DeflowerTest#shortSnippets'` (or `#largeSnippets`)
- Run the tool on a flow file: `Deflower.main` takes a classpath-relative path (e.g. `squirm/squirm.flo`). The file must be on the classpath, so it lives under `src/test/resources`. `Deflower.deflower(Path)` takes a file-system path instead. There is no exec plugin configured, so run it from an IDE or with a manually assembled classpath.
- Verify a disassembly: `Deflower.main --verify <file.flo>` (or `new Deflower(true)`). After writing each `.asm`, `Verifier` reassembles it with mpu6502's `SourceParser` and prints `Verify out/<binary>.asm: N bytes emitted, N differ, N virtual, N gaps`, then `differ $addr expected $xx got $yy` lines (the first 10) and `gap $start-$end` lines (end exclusive, pastable into the `.flo` file). A gap is loaded memory no area covers; an included virtual area dropped as unused still counts as covered. The exit code is 1 when anything differs, there is a gap, or a run has errors. A disassembly is done when it verifies with 0 differ and 0 gaps.
- No linter or formatter is configured.

All `DeflowerTest` cases pass.

## Architecture

The pipeline is: **flow file → parse → memory image + annotations → code-flow analysis → assembly output**. Everything lives in `com.laamella.deflower` except the grammar and the VICE snapshot parser.

- **Input.** A `.flo` file describes the disassembly. Its full, authoritative description is the comment at the top of the grammar, `src/main/antlr4/com/laamella/enflower/Flo.g4` (generated package `com.laamella.enflower`); read it before writing or editing `.flo` lines. In short:
  - `deflower <file>` starts a run: it loads a `.vsf` VICE snapshot or a `.prg`, relative to the `.flo` file. Each run is independent and writes `out/<file without extension>.asm`.
  - An annotation line is `<address or start-end> [virtual] [<type>[<size>]] [<label>] [export <id>] [{]`, with the parts in exactly that order and each at most once. Anything else is a parse error.
    - The range end is exclusive.
    - Types are `char`, `byte`, `word`, `long` (24 bits), `dword`, `addr` (a 16-bit address, printed as `.addr` with its target's label), `sbyte`/`sword`/`slong`/`sdword` (signed, printed as `.char`/`.sint`/`.lint`/`.dint`) and `code` (an entry point). A range with no type is an `UNKNOWN` placeholder, which a later line may narrow without an area conflict. A single address with no type is only a label/comment and registers no area.
    - The size is a number or `*`/`+` over numbers (`byte[40*21]`, `byte[$af]`). A size of 0 is an error.
    - The reserved words can't be labels.
    - `export <file>.bin` on a data line writes its bytes to `out/<file>.bin` and prints `.binary "<file>.bin"` in their place. `export <file>.prg` puts the region's start address in front as a load address, printed as `.binary "<file>.prg", 2`. The region is fixed data, even untyped (`ExportRegion`, `DataArea.export`).
  - `include <file>` reads another `.flo` file's lines into the run: relative to the including file, else a built-in one from `src/main/resources/deflower/` (`c64.flo`, which includes `c64_zeropage.flo`, `c64_system.flo`, `c64_io.flo`, `c64_basic.flo` and `c64_kernal.flo`). Included lines are weak: the including file's own lines win wherever they overlap, in any order. Included virtual areas and labels on uncovered memory are only printed when an operand or `.addr` value refers to them.
  - A `<address> [virtual] {` line opens a block, closed by `}`: addresses inside are offsets from that address, and `virtual` applies to every line inside. Blocks don't nest; `FloReader` resolves them, so nothing after parsing knows about them.
  - `;`/`#` comments sit on their own line and attach to the next annotation line.
- **`SubjectConfigurer`** drives the two configuration phases.
  - **Parse:** `FloReader` turns the `.flo` file into one `DeflowerRun` per `deflower` line, each holding its `Annotation`s (one per line, plain values; `LineType` is the line's kind; `included` for a line from an included file). It reads nothing but `.flo` files and changes no memory. Syntax errors abort with "Failed to parse".
  - **Apply:** for each run, `SubjectConfigurer` creates a `Subject`, loads the image (`ViceSnapshotReader` or `PrgReader`, picked by extension), and calls `Subject.annotate` for each annotation, the run's own ones first and the included ones after, so these only fill in what is still free. Data lines register one `DataArea` per element; `code` lines push an entry point onto `potentialCodeLocations`.
  - To add `.flo` syntax, change the grammar, `FloReader` and `Annotation`/`Subject.annotate`.
- **`Subject`** holds:
  - the 64K `MemoryLocation[]` (each location has the byte, an `Area` reference, a label and a comment);
  - the `potentialCodeLocations` stack and the output path;
  - the `errors` list. `registerArea` reports one area overwriting a different, non-placeholder one, and `Deflower` skips writing output for a subject with errors.
  - It also answers memory questions used by the output: run and array boundaries (`continuesRun`, `endOfRun`, `endOfArray`), annotations (`isAnnotated`), and the ASCII/screen-code guess (`likelyTextEncoding`).
- **`FlowAnalyser`** pops entry points and follows 6502 control flow using `mpu6502`'s `Instruction` table.
  - It registers an `InstructionArea` for each decoded instruction, follows fall-through and branch/jump/JSR targets (including `JMP (indirect)` through the address it reads), and auto-labels targets (`lXXXX`, `dXXXX`, `aXXXX`).
  - Analysis stops at addresses already covered by a non-placeholder area, and won't decode an instruction whose bytes run into one. It also stops at memory the image didn't load (`MemoryLocation.loaded`): the target keeps its label, printed as a define. That is how it avoids loops and detects jumps into data ("Jumping into non-code area").
- **`Area`** is the common base for `DataArea` and `InstructionArea`. Each address belongs to at most one area, and `registerArea` writes that link into `Subject.memory`. Address ownership is the main signal the analyser uses, so an overlapping `.flo` declaration changes the output.
- **`Deflower`** runs the pipeline. It clears and recreates `<basePath>/out` once per `.flo` file, then for each subject analyses, drops the unused included names (`Subject.dropUnusedIncludes`) and, if there are no errors, opens `out/<binary>.asm` and hands the writer to `ResultWriter`. It also writes `out/<binary>.map` (`MemoryMap`: one line per code run, split at routine labels, per array and per gap, e.g. `$c007-$c009 word table`), and with verify on runs `Verifier`.
- **`ResultWriter`** walks 0x0000–0xFFFF and drives `AssemblyFileFormat`, which owns the layout and the per-type printing (64tass syntax, all lowercase except labels and comments):
  - `*=` origins at gaps;
  - blank-line separators and label placement inside data runs;
  - `.byte`/`.word`/`.long`/`.dword`/`.addr`/`.char`/`.sint`/`.lint`/`.dint` tables;
  - `.text` strings, with `.enc "screen"`/`"none"` switches chosen per char array, and `.null`/`.ptext` for null-terminated and length-prefixed ones;
  - a blank line above a label only where the instruction before it ends the flow (`jmp`, `rts`, `rti`, `brk`), and after such an instruction even without a label;
  - `.virtual` blocks;
  - instructions with operands resolved to labels (`label + $offset` inside arrays), and `@w` on absolute operands below `$100` so they don't reassemble as zero page;
  - labels inside an array, a multi-byte element or an instruction printed as `label = $XXXX` defines after it, and labels on uncovered memory as defines in place;
  - cross-references above each label (`; called by:`, `jumped to by:`, `read by:`, `written by:`, `modified by:`), collected by `CrossReferences` from the decoded instructions and named by the nearest routine label before each one (auto labels of branch and `jmp` targets no `jsr` calls are local and skipped).

  `LineEmitter` is the low-level writer: lines, indentation, value columns and open quotes.
- **`vicevcf`** parses VICE snapshot files (`ViceVcfFileReader` → `Header` + `Module`s). `C64MemModuleHandler` extracts the `C64MEM` module, which provides the 64K RAM image. Other modules are kept as `UnhandledModule`.
- **`Assert`, `Printing`, `ByteBufferAccess`** in `com.laamella` are small helpers (`assertState`, hex formatting, buffer reads).

Test-driven workflow:
- `DeflowerTest` runs snippet files from `src/test/snippets/`, one test case per `.txt` file, with `com.laamella:snippets-test-junit5-core`'s `SnippetTestFactory` (manual: https://github.com/laamella-gad/snippets-test-junit5).
- A snippet file is an optional description between `>>>` and `<<<`, the input parts separated by `===` lines, a `^^^` line, the three expectations separated by `~~~` lines, and a closing `vvv` line. The expectations are what Deflower printed (stdout and stderr together, paths relative to the `.flo` file), the generated `.asm` (each under a `--- <name>` line when a `.flo` file has several runs; empty when the run had errors), and the other files in `out/`, each under `--- <name>`: the `.map` files as text and the exported binaries as hex dumps. The snippets run with verify on, so the printed part ends with each run's verify report.
- Short snippets (`short/`, purpose-built, one per feature or bug, error cases in `short/invalid/`):
  - The first input part is 64tass assembly, which mpu6502's `SourceParser` assembles into `test.prg`. Leave it empty when the `.flo` file fails before loading anything.
  - The second part is the `.flo` file, written as `test.flo`.
  - More parts are more files, each starting with a `; file: <name>` line. A `.prg` one is assembled, like the first part.
  - All files go into a temporary directory, and Deflower runs on `test.flo` there.
  - Round trip: every generated `.asm` must reassemble, with `SourceParser`, to the bytes of the `.prg` with its name. Bytes it leaves out aren't checked. A failure fails the test outright, without writing an expectation. A `; no round trip` line in the assembly skips this, for a snippet that shows verify reporting a difference (`short/verify.txt`).
- Large snippets (`large/`) are the real programs, whose binaries are too big for a snippet. The only input is a `.flo` path on the test classpath, e.g. `zwark/zwark.flo`, with the `.flo` file and its binary in `src/test/resources/<program>/`. Output goes to `out/` next to the `.flo` file under `target/test-classes`.
- A changed snippet file in a diff means the generated output changed; review it like any other test failure.
- To accept a new snippet or a deliberate output change, delete everything from the `^^^` line on and rerun the tests. Running with `-DREGENERATE_EXPECTATIONS` rewrites all of them. Either way, the test writes the actual output into the file and fails once, so you can review it before committing.
- The `.asm` of a short snippet can also be checked with 64tass: `64tass -q -b -o x.bin test.asm` must equal `test.prg` minus its 2-byte header.

Issues are tracked as `issues/NNNN-slug.md` (frontmatter `title`/`status`/`priority`/`labels`, priority `low`/`medium`/`high`); `issues/README.md` describes the format. To close one, set `status: done`, remove its `priority` and add a "## Closing note".

## Notes

- Much of the code is debugging-era, with lots of `System.out` tracing ("Marking area", "Unnamed target", "Jumping into non-code area"). Keep that in mind when reading output; it is not a sign of failure.
- Numbers in `.flo` files are decimal, or hex with a `$` prefix.
