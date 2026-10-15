---
title: Load more binaries into memory from the .flo file
status: done
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
- **File types.** `.prg`, raw binaries ([0117](0117-load-raw-binaries.md) loads one as the main file), and maybe a `.vsf` as the base with `.prg` files on top.
- **Overlap.** Two files loading into the same addresses: the later one wins, or it's an error. Overlays and banked parts loaded at different times are the hard case; see [0069](0069-one-label-per-address-ignores-banking.md).
- **Output.** One `.asm` for all parts, named after the `deflower` file, or one per loaded file that includes the others' labels, as in [0058](0058-disassemble-region-to-separate-asm-file.md).
- **Reassembly.** The output no longer reassembles to one `.prg`. Decide what 64tass should produce, and what verify ([0075](0075-verify-flag.md)) compares each part with.
- **Relation to 0065.** Memory no file loads is still zeros the trace shouldn't decode ([0065](0065-trace-stops-at-memory-the-image-does-not-load.md)); with several files, the loaded ranges are the union.

Done when: a small fixture with a `.prg` that calls into a second loaded file traces into it and labels the target, its output assembles with 64tass, and `CLAUDE.md` and `README.md` describe the new line.

## Decisions

Decided 2026-10-15:

- **Syntax: `load <file> [at <address>]`**, one line per file after the `deflower` line. A `.prg` loads at its own address unless `at` overrides it.
- **File types.** The main file is a `.vsf`, `.prg` or `.bin`; a loaded file is a `.prg` or `.bin`. A `.bin` has no load address, so it needs `at`, on the `deflower` line too (`deflower kernal.bin at $e000`). This takes in all of [0117](0117-load-raw-binaries.md): `from <offset>` and `size <n>` read a part of a `.bin`, on both lines, and `--dump`, `--find`, `--strings` and `--init` take the same file options.
- **Overlap: the later file wins, without a warning.** (First a warning over an earlier `.prg` or `.bin`; the user dropped it.)
- **Output**: one `.asm`, named after the `deflower` file, each part under its own `*=`, as the writer already does at gaps. Verify compares every byte with the merged memory, so it needs no change.
- **`load`, `at`, `from` and `size` stay usable as labels** (`$ffd5 banked load` in `c64_kernal.flo`): the grammar takes them as a label where a label may stand.

## Closing note

Done. A `load <file> [at <address>] [from <offset>] [size <n>]` line after the `deflower` line loads one more `.prg` or `.bin` into the run (`DeflowerRun.loads`, `runner.loadFiles`). The files load in order and a later one wins where they overlap, without a warning. The output is still one `.asm`, named after the `deflower` line's file, with each part under its own `*=`; verify needed no change. A `load` line can't be in an included file or a block, and `load`/`at`/`from`/`size` stay usable as labels (the grammar's `name` rule), as `c64_kernal.flo`'s `banked load` needs. The watcher watches the loaded files too. The snippet round trip now reads the `deflower` and `load` lines of `test.flo` itself. Snippets: `short/load.txt`, `loadover.txt`, `loadlabel.txt`, `invalid/load-*.txt`.
