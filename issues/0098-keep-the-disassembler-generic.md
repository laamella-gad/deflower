---
title: Keep the disassembler generic, with the C64 as one machine on top of it
status: open
priority: medium
labels: cleanup
---

Deflower disassembles 6502 code, and nothing in the tracing or the output needs a C64. All the fixtures are C64 programs, though, so C64 knowledge creeps into whatever gets added next. It should stay in clearly separated machine-specific pieces, so that a VIC-20, a PET, an Atari 8-bit, an NES or a bare 6502 ROM can be disassembled without fighting C64 assumptions.

## Where things stand

Generic, and should stay so:
- `FlowAnalyser`, `AddressSetupFinder`, `SelfModificationFinder`, `Subject`, the areas, `ResultWriter`/`AssemblyFileFormat`, `Verifier`, `MemoryMap`, `CrossReferences`. These only mention the KERNAL as an example in comments.
- The `.flo` grammar, apart from the points below.

Machine-specific:
- **Input formats.** `ViceSnapshotReader` reads only C64 and C64SC snapshots. `PrgReader`'s 2-byte load address is a Commodore convention. `SubjectConfigurer` picks the reader by extension, so there is no way to load a raw binary at a given address (a cartridge or ROM dump), or a format with several segments.
- **Built-in includes.** `src/main/resources/deflower/` holds only `c64*.flo`. That part is fine: a machine is a set of `.flo` files, and others can be added next to them.
- **Text types.** `screencode` is the Commodore screen code (64tass's `"screen"`), and `ascii` is Commodore ASCII (`"none"`). The other Commodores share them, but other machines have their own encodings (ATASCII and Atari's internal codes) or none at all (the NES).
- **`--init` (`Initializer`, issue [0072](0072-inspect-input-file.md)).** Entirely C64: banking through `$01`, the KERNAL vectors at `$0314`, CHRGET at `$73`, the VIC-II and CIAs, the BASIC stub at `$2b`, the choice of `c64*.flo` includes. The `vicevcf` handlers are C64 modules.
- **VICE's power-on pattern** for untouched memory belongs to the emulator and machine, not to the 6502.

## Rule

- No machine knowledge in the analysis and output. A machine's addresses, vectors, ROM labels and entry points come from `.flo` files, never from Java code in the pipeline.
- Machine-specific Java (input formats, `--init`) sits behind a seam: a loader chosen by the input, an initializer chosen by the machine. Adding a machine adds a class and `.flo` files without changing the pipeline.
- New features are checked against this: does it assume a C64? If so, can it be a `.flo` file, or does it belong behind the machine seam?

## To decide

- **Package layout**: e.g. `com.laamella.deflower.c64` for `ViceSnapshotReader`, `PrgReader`, `Initializer`, and the `vicevcf` package, with interfaces for loader and initializer in the core.
- **Raw binaries**: a `deflower <file> at $8000` form (or similar) for a file with no header, now [0117](0117-load-raw-binaries.md). That is the first non-C64 need, e.g. for a cartridge or ROM image.
- **Text encodings**: keep `screencode`/`ascii` as they are and add encodings per machine later, or name them after the machine (`c64screen`) now. Changing the names breaks existing `.flo` files.
- **Machine selection**: from the input file (a `.vsf` names its machine), from an include (`include c64.flo`), or an explicit `machine` line.

Done when: the machine-specific code sits behind the decided seam, the core packages have no C64 references outside comments, a non-C64 binary (e.g. a raw ROM loaded at a given address) disassembles in a short snippet, and `CLAUDE.md` states the rule.
