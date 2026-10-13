---
title: A command line flag that lists what is of interest for disassembling an input file
status: done
labels: enhancement
---

Starting a disassembly means finding facts about the input file before the first `.flo` line can be written: where the code starts, which interrupt handlers are installed, where the screen and graphics are, and which memory the program uses at all. Deflower shows none of that, so for each fixture so far (`1nvader_snap`, `2krace_snap`, `3dgolf_snap`, `3dgolfpic_snap`, `zwark`) these were dug out by hand with throwaway scripts that parse the `.vsf` outside Deflower.

Want: a command line flag, e.g. `deflower --inspect <file>`, that reads a `.vsf` or `.prg` and prints everything of interest for disassembling it. It writes no `.asm` and needs no `.flo` file.

## What to list

For a snapshot (`.vsf`):
- **CPU state** from the `MAINCPU` module: PC, A, X, Y, SP, status. The PC is the surest code entry point a snapshot has. In VICE 3.9 snapshots (module version 1.4) the module starts with an 8-byte clock, then `A`, `X`, `Y`, `SP`, a 16-bit `PC` and the status register; `3dgolfpic_snap.vsf` has PC = `$7f84`. Older snapshots differ: `squirm.vsf` has module version 1.1 with a 4-byte clock (PC = `$3122`), so the layout depends on the module version.
- **Banking**: the processor port (`$00`/`$01` from `C64MEM`), i.e. which of BASIC, KERNAL, I/O and character ROM are visible.
- **Vectors**: IRQ, BRK and NMI at `$0314`/`$0316`/`$0318`, and the hardware vectors at `$fffa-$ffff` in RAM, each marked as pointing into ROM or RAM. Handlers in RAM are code entry points.
- **The stack**: SP and the return addresses on it, which are likely code.
- **Video**: the VIC bank (from CIA2 port A), the mode (`$d011`/`$d016`), the screen, character set and bitmap addresses (from `$d018`), the sprite pointers, the enabled sprites and the raster interrupt line.
- **Interrupt sources**: VIC raster interrupt enable, CIA1/CIA2 timer interrupt enables.
- **Used memory**: the ranges of RAM that differ from VICE's power-on pattern, and the ranges that still hold it (untouched). This is what decides which areas need disassembling at all.
- **BASIC pointers**: start and end of the program (`$2b`-`$2e`), and the `SYS` address if a BASIC stub is still present.
- **Patched system locations**: CHRGET at `$73` (zwark patches it to `jmp $9009`), and the KERNAL vectors at `$0314-$0333` that differ from their defaults.

For a program (`.prg`):
- load address and end address;
- the `SYS` address from a BASIC stub, which is the entry point;
- the RAM ranges it overwrites with its load.

## To decide

- **Flag name and form**: `--inspect`, `--info`, ... And whether `Deflower.main` keeps taking a classpath-relative path, or takes a file system path with the flag.
- **Output**: plain text for reading, or ready-to-paste `.flo` lines (`$7f84 code snapshot_pc`, `$0314 addr irq_vector`, `$5c00 byte[40*25] screen`, `$1a12-$5800 virtual byte untouched_1a12`, ...), or both.
- **Untouched memory**: VICE's power-on pattern differs per VICE version and setting (`RAMInitPattern`, random bits). Detecting it needs a tolerant match, like the 32-byte window match used by hand so far.
- **Parsing**: `ViceSnapshotReader` passes only a `C64MemModuleHandler` to `ViceVcfFileReader`, so every other module ends up as an `UnhandledModule`. This needs handlers for `MAINCPU`, `VIC-II` and `CIA1`/`CIA2`, and a way to give the reader more than one handler.

Not part of this: using any of it automatically as `.flo` annotations. That changes the output and needs its own decision.

Done when: the flag prints the list above for each snapshot fixture and for a `.prg` fixture, the values match what the fixtures' `.flo` files declare by hand (e.g. the `snapshot_pc` lines), and the flag is described in `CLAUDE.md`.

## Closing note

`deflower --init <file>` (renamed from `--inspect`: it is how a disassembly starts) takes a `.vsf` or `.prg` by file system path and writes a `.flo` skeleton next to it, `<file without extension>.flo`, unless that exists (`Initializer`). The skeleton holds the facts as `;` comments, then the `deflower` line, `code` lines for the entries, `virtual byte` lines for untouched (`untouched_xxxx`) and all-zero (`unused_xxxx`) ranges, and the includes that match the banking (`c64.flo` when everything is banked in). Every fixture's skeleton runs as a `.flo` file. `init/` snippets cover the eight snapshots, `1nvader.prg` and `tcmine.prg`.

- **Parsing.** New handlers: `MainCpuModuleHandler` (1.1 has a 4-byte clock, 1.4 an 8-byte one), `VicIIModuleHandler` (x64sc's 1.3: one byte, then the 64 registers), `CiaModuleHandler` (2.x: ports, directions, timers, TOD, serial data, then the interrupt mask). The layouts were checked on the fixtures, e.g. `3dgolfpic_snap`'s `$d018` gives its `$5c00` screen in bank 1. Old snapshots get the RAM facts, CPU and CIA interrupts; their video says `VIC-II 1.1 isn't read`.
- **Code entries.** Only for RAM outside the zero page, the hardware vectors and untouched memory, so `bigmac`'s and `2krace_snap`'s stale vectors into RAM under the KERNAL add none. They match the hand-written lines: the `snapshot_pc` of every snapshot, the irq/nmi of `commando`, `3dgolf_snap`, `bigmac` and `squirm`, `2krace_snap`'s hardware IRQ `$09fd`, and `zwark`'s CHRGET patch `jmp $9009`.
- **Untouched memory.** A byte belongs to the pattern when it is `$00`/`$ff`, or one bit off it next to one that is. A screen of spaces then isn't the pattern. Runs of 64 bytes and more count, and a single odd byte inside them is allowed. Zero runs of 256 bytes or more inside them are `unused`. Scanning starts at `$0400`, skips I/O while it is banked in and the hardware vectors while the KERNAL is out, and stops at visible ROM boundaries. The ranges come within a few bytes of the hand-written ones, sometimes splitting where a hand-written range runs through sprite data.
- **Stack.** Shows the top 16 bytes, and the top read as a `jsr` return address and as an interrupt's. `1nvader_snap`'s `$4382` is the one its `.flo` describes.

`3dgolf_snap`'s skeleton traces into data and verifies with 3 differences: those are illegal opcodes that share a mnemonic, issue [0086](0086-duplicate-opcodes-do-not-reassemble.md).
