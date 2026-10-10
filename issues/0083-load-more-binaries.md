---
title: Load more binaries into memory from the .flo file
status: open
priority: medium
labels: enhancement
---

A `deflower <file>` line loads exactly one image, a `.prg` or a `.vsf`. Many programs are more than one file: a loader and the parts it loads, code and separate data files, or a BASIC program that loads machine code. Today their parts can only be disassembled one by one, each as its own run, so references between them print as raw addresses and the trace can't follow a call into another part.

Seen in fixture `tcmine`: the machine code at `$c000` uses the level data at `$4000`, the enemy table at `$2580`, the jump table at `$8407` and the music at `$8500`/`$8b84`, which are all loaded separately. `tcmine.flo` can only declare them as `virtual` and explain that in a comment.

It also helps snapshots: a ROM image (BASIC, KERNAL, character ROM) could be loaded over the RAM, which is part of [0066](0066-snapshot-rom-areas-are-not-in-the-image.md), and a `.prg` loaded on top of a snapshot.

Want: a line after `deflower <file>` that loads another file into the same memory image, e.g.

```
deflower tcmine.prg
load levels.prg
load music.bin $8500
```

The parts then form one image: the trace follows calls between them, data gets labels, and the output has every part with its own `*=` origin.

## To decide

- **Syntax.** A new `load` line, or more files on the `deflower` line. Where each file goes: a `.prg` has its load address in its first two bytes; a raw binary needs an address on the line, and a `.prg` might need an override.
- **File types.** `.prg`, raw binaries, and maybe a `.vsf` as the base with `.prg` files on top.
- **Overlap.** Two files loading into the same addresses: the later one wins, or it's an error. Overlays and banked parts loaded at different times are the hard case; see [0069](0069-one-label-per-address-ignores-banking.md).
- **Output.** One `.asm` for all parts, named after the `deflower` file, or one per loaded file that includes the others' labels, as in [0058](0058-disassemble-region-to-separate-asm-file.md).
- **Reassembly.** The output no longer reassembles to one `.prg`. Decide what 64tass should produce, and what verify ([0075](0075-verify-flag.md)) compares each part with.
- **Relation to 0065.** Memory no file loads is still zeros the trace shouldn't decode ([0065](0065-trace-stops-at-memory-the-image-does-not-load.md)); with several files, the loaded ranges are the union.

Done when: a small fixture with a `.prg` that calls into a second loaded file traces into it and labels the target, its `expected.asm` assembles with 64tass, and `CLAUDE.md` and the format comment in `Flo.g4` describe the new line.
