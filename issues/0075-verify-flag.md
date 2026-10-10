---
title: A flag that reassembles the output and checks it against the input
status: open
priority: high
labels: enhancement
---

A disassembly is done when the generated `.asm` reassembles to exactly the bytes of the input, and every byte of memory is covered by an area. Deflower checks neither. For `zwark`, `tcmine` and `squirm` this was checked by hand with throwaway scripts:
- run Deflower;
- assemble `out/<binary>.asm` with `64tass -b -L <listing>`;
- read the listing to see which address every emitted byte landed at, and compare each one with the memory image;
- list the addresses no area covers, merged into gaps, and count the bytes in `virtual` areas separately.

The result was one line like `14153 bytes emitted, 0 differ`, `51383 bytes virtual`, `region $0000-$ffff: 0 uncovered in 0 gaps`. That line was the main signal while iterating, and the definition of done.

Want: a flag, e.g. `--verify`, that does this as part of a run and prints:
- the number of bytes emitted, and every address where the reassembled byte differs from the image (first few in full, then a count);
- the uncovered ranges, as `$start-$end` lines that can be pasted into the `.flo` file;
- the number of bytes covered by `virtual` areas;
- an exit code that is non-zero when anything differs or is uncovered.

## To decide

- **Assembler.** Call 64tass as an external program (the tests already rely on it being installed for the small fixtures), or compare against Deflower's own idea of the bytes it emitted, which needs no assembler but doesn't catch output 64tass reads differently (e.g. zero page vs absolute, which `@w` exists for).
- **Region.** Check all 64K, or only the ranges the input loads (a `.prg`), or ranges given on the command line.
- **Untouched memory.** In a snapshot, RAM still holding VICE's power-on pattern doesn't need disassembling. Count it as covered when detected (see [0072](0072-inspect-input-file.md)), or require `virtual` lines for it as today.
- **Output format.** One item per line, address first, in a fixed format (`gap $23f3-$23fa`, `differ $2441 expected $f5 got $60`), so the result can be grepped, counted and pasted into the `.flo` file. No JSON unless a tool needs it.
- **Memory map file.** Also write `out/<binary>.map`, one line per area with start, end, type and label (`$2648-$2658 word snake_0_head`), and one per gap. Verify could then compare against the map instead of a 64tass listing, and the `.flo` skeleton ([0079](0079-generate-flo-skeleton.md)) and a quick "what is at this address" lookup could read it too. Decide whether the map is written on every run or only with the flag.
- **Timing.** The other command line flags wait for [0059](0059-convert-to-nim.md); this one probably should too.

Done when: `--verify` reports 0 differences and 0 gaps for `zwark`, `tcmine` and `squirm`, reports a difference and a gap for a small fixture made to have them, and the flag is described in `CLAUDE.md`.
