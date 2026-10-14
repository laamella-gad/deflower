---
title: Investigate running the subject's code to find out more than tracing can
status: open
priority: low
labels: research
---

Deflower only reads the code: `FlowAnalyser` follows the control flow statically, from the entry points. Some things can only be found out by running it:

- **Decrunchers and unpackers.** A crunched `.prg` holds a small decruncher and a block of packed data. Tracing finds the decruncher, and the rest looks like data. `3dgolf.prg` is like this: its `start` at `$080d` copies the decruncher to `$0100` and `$00f7`, changes its own operands while copying the packed data, and jumps to `$0116`, where tracing stops, since that memory isn't loaded. The `3dgolf_snap` snapshot was taken after it ran. Running the decruncher until it jumps to the unpacked program gives the real program in memory, without needing a VICE snapshot.
- **Code that is copied before it runs.** The decruncher in `3dgolf_snap` runs from `$0100`, copied there by `decrunch`. In general, code moved to its run address (to the stack page, under the ROMs, to a cartridge area) is traced at the address it is loaded at, where it doesn't run.
- **Indirect jumps and dispatch tables.** `jmp (vector)` and the `pha`/`pha`/`rts` trick go wherever the program puts the address at run time. Static tracing only follows a `jmp (indirect)` through the address the image holds.
- **Self-modifying code.** An instruction whose operand (or opcode) is written by the program does something other than what the image shows.
- **Inline data after a jsr** ([0068](0068-inline-data-after-jsr.md)). Running a call shows where it returns to, so a routine's parameter list could be suggested instead of written by hand.

mpu6502 already has a CPU core: `Mpu6502` with a `step()` and a `Bus` interface (`read`, `write`, `peek`). A `Bus` over `Subject.memory` is enough to start.

## To decide

- **What to run, and until when.** From a `.flo` entry point, until a condition: a jump to an address (`run $080d until $2cd0`), a number of instructions or cycles, a jam, or reaching an address outside the area it started in. Without a limit, a main loop runs forever.
- **What the result is used for.**
  - Replace the image with the memory after the run (unpack, then disassemble the unpacked program).
  - Or only record what happened and feed it to the analysis: which addresses executed (code for sure), which were read or written as data, the targets of indirect jumps and `rts` dispatch, where each `jsr` returned to, which instructions were changed by the program.
  - Or both, as separate steps.
- **The machine around the CPU.** Most code touches I/O, the KERNAL and interrupts. A bare `Bus` over RAM is enough for a decruncher, which usually only banks `$01`. More than that means ROM images (licensing), I/O registers that return something plausible (raster line, CIA timers, the keyboard), and interrupts. Where to stop, and whether to use VICE (its monitor or remote protocol) instead of emulating in Deflower.
- **Snapshots.** A `.vsf` snapshot also holds the CPU registers and the I/O state, not only RAM, so it could resume where it was taken. Deflower reads `C64MEM`, `MAINCPU`, `VIC-II` and the CIAs (for `--init`), but not the SID or the drive.
- **How the `.flo` file says it.** A `run` line, or a `deflower` variant that runs first and disassembles the result; how the result's memory then relates to the original file's addresses and to `Verifier`'s comparison.
- **Determinism.** The output should stay the same from run to run in the watcher loop, so no wall-clock time or random input.
- **mpu6502.** Whether its core is complete and correct enough (undocumented opcodes, decimal mode, cycle counts). It also needs a way to record executed addresses and memory accesses.

Done when: an experiment unpacks `3dgolf.prg` by running its decruncher, the result compared with the `3dgolf_snap` snapshot's memory, and follow-up issues filed for what is worth building.
