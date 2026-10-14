---
title: Load a raw binary at a given address, skipping a header
status: open
priority: medium
labels: enhancement
---

A `deflower <file>` line loads a `.prg` (the load address is in the file) or a `.vsf`. A raw file, such as a cartridge or ROM dump, an EPROM image, or a file with some other header, can't be loaded at all.

da65 takes the start address and the part of the file to read as options (`STARTADDR`, `INPUTOFFS`, `INPUTSIZE`; [0060](0060-investigate-da65-features.md)). Deflower could do the same on the `deflower` line, e.g. `deflower kernal.bin at $e000` or `deflower game.crt at $8000 from $50 size $2000`.

This matters most for other machines and bare 6502 ROMs ([0098](0098-keep-the-disassembler-generic.md)), and is a piece of [0083](0083-load-more-binaries.md): a ROM image loaded over a snapshot needs this form too. `--dump`, `--find`, `--strings` and `--init` read their input through `MemoryImage` and should take the same raw files.

Done when a raw binary loads at a given address, optionally from an offset and for a size, documented in `docs/flo-format.md`.
