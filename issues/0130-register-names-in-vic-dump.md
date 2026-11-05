---
title: Show register names in the VIC dump
status: open
priority: low
labels: enhancement
---

`--dump <file.vsf> vic` prints the 64 VIC registers as plain hex, 16 a line (`look.dumpRegisters`). To read them you have to know the register map: `$d011` control 1, `$d018` memory pointers, `$d020` border colour and so on. `--init` decodes some of them into `;` comments, but the dump itself doesn't say what a register is.

Wanted: the dump names the registers.

Open design points (ask the user before coding):
- Layout: one line per register (address, value, name; 64 lines), or the current 16-a-line rows with a name legend, or names only for registers that hold something other than 0.
- Whether to decode bits too (`$d011`: bit 7 raster 8, bit 6 ECM, bit 5 bitmap, bit 4 display enable, bit 3 25 rows, bits 0-2 y scroll; `$d018`: screen and charset/bitmap addresses), as `--init` already does for the screen, charset and mode.
- Sharing: the names and decoding could come from one table that `initializer` also uses, instead of a second copy.
- Whether the unused registers `$d02f-$d03f` are listed.

Done when:
- `--dump <file.vsf> vic` prints a name with each register, in the layout decided.
- `README.md` (the `--dump` section) and `src/deflower/help.txt` describe it.
- `tests/snippets/dump/vic.txt` is updated, and the layout is covered by a snippet.
