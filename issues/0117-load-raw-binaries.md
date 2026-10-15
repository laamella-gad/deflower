---
title: Load a raw binary at a given address, skipping a header
status: done
labels: enhancement
---

A `deflower <file>` line loads a `.prg` (the load address is in the file) or a `.vsf`. A raw file, such as a cartridge or ROM dump, an EPROM image, or a file with some other header, can't be loaded at all.

da65 takes the start address and the part of the file to read as options (`STARTADDR`, `INPUTOFFS`, `INPUTSIZE`; [0060](0060-investigate-da65-features.md)). Deflower could do the same on the `deflower` line, e.g. `deflower kernal.bin at $e000` or `deflower game.crt at $8000 from $50 size $2000`.

This matters most for other machines and bare 6502 ROMs ([0098](0098-keep-the-disassembler-generic.md)), and is a piece of [0083](0083-load-more-binaries.md): a ROM image loaded over a snapshot needs this form too. `--dump`, `--find`, `--strings` and `--init` read their input through `MemoryImage` and should take the same raw files.

Done when a raw binary loads at a given address, optionally from an offset and for a size, documented in `README.md`.

## Decisions

- **Done as part of [0083](0083-load-more-binaries.md)** (decided 2026-10-15): `<file>.bin at <address> [from <offset>] [size <n>]` on the `deflower` and `load` lines, and the same options after the file for `--dump`, `--find`, `--strings` and `--init`. `from`/`size` are for `.bin` files only.

## Closing note

Done with issue 0083. The `deflower` and `load` lines take `at <address>` (a `.prg` loads there instead of at its own address; a `.bin` needs it), `from <offset>` and `size <n>` (a `.bin` only: skip that many bytes, take that many). `loaders.imageProblem` checks the options, `imageBytes` reads the bytes. `--init`, `--dump`, `--find` and `--strings` take the same options after the file (`look.takeImage`), and `--init` writes them on the skeleton's `deflower` line. Snippets: `short/loadbin.txt`, `short/invalid/load-*.txt`, `init/bin*.txt`, `dump/bin.txt`, `dump/prg-*.txt`, `find/bin.txt`, on `tests/resources/bin/stub.bin`.
