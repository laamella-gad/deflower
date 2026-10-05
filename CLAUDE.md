# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Purpose

Deflower semi-automatically disassembles 6502 binaries. The tool traces code automatically, following control flow from entry points. The user supplies the rest by hand: labels, and marked blocks (data, bytes, words, code entries). The `.flo` file is where those annotations live, so the tool is a loop of: run, read the output, add annotations, run again.

Suggested way to use it: keep the disassembler re-running on every save of the `.flo` file, and read `out/deflowered.asm` as it updates. The tool itself does a single run per invocation (`Deflower.main`); there is no built-in file watcher, so the re-run has to come from an external watcher around it.

## Commands

Maven project, Java 14 source/target (JDK 23 installed locally works). Depends on `com.laamella:mpu6502:0.2-SNAPSHOT`, which is not on Maven Central. It must be in the local `~/.m2` repository, so use `-o` (offline) if builds fail to resolve it.

- Build: `mvn -o compile`
- Run all tests: `mvn -o test`
- Run one test class: `mvn -o test -Dtest=DeflowerTest`
- Run one test method: `mvn -o test -Dtest='DeflowerTest#deflowerZwark'`
- Run the tool on a flow file: `Deflower.main` takes a classpath-relative path (e.g. `squirm/squirm.flo`). The file must be on the classpath, so it lives under `src/test/resources`. There is no exec plugin configured, so run it from an IDE or with a manually assembled classpath.
- No linter or formatter is configured.

Known state: `deflowerSquirm` currently fails with `Old VICE snapshot file`. `squirm.vsf` is not in the VICE format the reader expects (`VICE Version` header check in `ViceVcfFileReader.readHeader`). `deflowerZwark` and `deflowerTCMine` pass.

## Architecture

The pipeline is: **flow file → ANTLR parse → memory image → code-flow analysis → assembly output**. Everything lives in `com.laamella.deflower` except the grammar and the snapshot reader.

- **Input.** A `.flo` file (grammar `src/main/antlr4/com/laamella/enflower/Flo.g4`, generated package `com.laamella.enflower`) describes the disassembly. It has two kinds of statements. `deflower <file>` loads a memory image: a `.vsf` VICE snapshot or a `.prg` (2-byte load address header, then bytes). Other lines annotate memory: an address or range (`$2800-$2ff9`, `$0400`), a data type (`char`, `byte`, `word`, `dword`, `code`, with optional `[n]` array size or `n*m` multiplier), `system`, and a label (`ID`). Paths in `deflower` lines are resolved relative to the `.flo` file's directory.
- **`SubjectConfigurer`** is the ANTLR listener that turns the `.flo` file into a `Subject`. Memory is loaded first (`enterSetFileName` clears memory and reads the image), then each line is applied in `exitLine`. Data lines register `DataArea`s. `code` lines push an entry point onto `potentialCodeLocations`. There is also a legacy hand-written line parser (`parseLine`) that is no longer called from the grammar path. Don't extend it; change the grammar and listener instead.
- **`Subject`** holds the 64K `MemoryLocation[]` (each cell has the byte, an `Area` pointer, and a label), the `potentialCodeLocations` stack, and the output directory. `Subject` creation recreates `<basePath>/out`, deleting its previous contents.
- **`FlowAnalyser`** pops entry points and follows 6502 control flow using `mpu6502`'s `Instruction` table. It registers an `InstructionArea` for each decoded instruction, follows fall-through and branch/jump/JSR targets, and auto-labels targets (`_XXXX_CODE`, `_XXXX_DATA`). Analysis stops at addresses that are already covered by an area. That is how it avoids loops and detects jumps into data (logged as "Jumping into non-code area").
- **`Area`** is the common base for `DataArea` and `InstructionArea`. Each address belongs to at most one area, and `registerBlock` writes that link into `Subject.memory`. Address ownership is the main signal the analyser uses, so an overlapping `.flo` declaration changes the output.
- **`ResultWriter`** walks 0x0000–0xFFFF in order and writes `<basePath>/out/deflowered.asm` (`*=` origins, `.BYTE` lines, and mnemonics). Labels come from `MemoryLocation.label`. Gaps with no area trigger a new `*=` origin. Only `BYTE` data is emitted so far; `WORD`/`DWORD`/`CHAR` cases are not yet handled in `AssemblyFileFormat.print`.
- **`vicevcf`** parses VICE snapshot files (`ViceVcfFileReader` → `Header` + `Module`s). `C64MemModuleHandler` extracts the `C64MEM` module, which provides the 64K RAM image. Other modules are kept as `UnhandledModule`.
- **`Assert`, `Printing`, `ByteBufferAccess`** in `com.laamella` are small helpers (`assertState`, hex formatting, buffer reads).

Test-driven workflow: `DeflowerTest` runs the full pipeline on the three fixtures in `src/test/resources/{squirm,zwark,tcmine}`. Each run writes its output to `src/test/resources/<name>/out/` under `target/test-classes`, so inspect the generated `deflowered.asm` there, not in the source tree.

## Notes

- Much of the code is debugging-era: lots of `System.out` tracing, commented-out loops in `Deflower.deflower`, and a `Subject` that prints every stored byte. Keep that in mind when reading output; it is not a sign of failure.
- Numbers in `.flo` files are decimal, or hex with a `$` prefix.
