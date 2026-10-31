---
title: Dump the VIC registers and the colour RAM from a snapshot
status: open
priority: low
labels: enhancement
---

A `.vsf` snapshot has a `VIC-II` module with the 64 registers, and the colour RAM (`$d800-$dbff`, 1024 nibbles). `vicevcf` reads only the registers (`mkVicII`, module 1.3, `registers`), and `--init` turns a few of them into `;` comments (video bank, mode, screen, charset, sprites, interrupts). The colour RAM is not read, and `--dump` can't show either: it only prints the 64K RAM image, where `$d000-$dfff` is the RAM under the I/O area, not what the VIC holds.

Wanted: look at the VIC state from the command line, to see the colours of a screen or the exact register values behind `--init`'s comments.

Open design points (ask the user before coding, see `decide-design-before-implementing`):
- Where it lives: `--dump <file.vsf> vic` / `colour`, a range `$d000-$d040` / `$d800-$dc00` that reads the module instead of the RAM when the snapshot is banked to I/O, or new flags. Reuse of `look.dump`'s layout (hex, 16 a line) is preferred.
- Whether `--init` also lists the registers and a colour summary (background/border, screen colours) as `;` comments.
- Whether a `.flo` file can use the colour RAM at all (`include` data, `export`); probably not, as the output is the program's memory.
- Other chips (SID, CIA) as the same kind of dump later, or not.

Done when:
- `vicevcf` reads the colour RAM from the `VIC-II` module (the offset in VICE's `vicii-snapshot.c` for the 1.3 layout; older versions say they're unknown, as for the registers) and keeps it next to `registers`.
- The command line can print the 64 registers (hex, with names such as `$d018 memory pointers`) and the colour RAM (16 a line, nibbles) of a snapshot; a file without the module, or with another version, gives an error.
- `README.md` and `src/deflower/help.txt` describe it.
- Dump snippets in `tests/snippets/dump/` cover the registers and the colour RAM, and an error one covers a `.prg`/`.bin` or a snapshot without the module.
