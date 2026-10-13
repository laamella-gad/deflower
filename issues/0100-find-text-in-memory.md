---
title: A command line flag that lists the stretches of memory that look like text
status: open
priority: low
labels: enhancement
---

`--dump` ([0097](0097-dump-memory-flag.md)) shows the bytes of a range as PETSCII and as screen codes, so text stands out, but only in a range already chosen. Finding the strings of a program still means dumping all of it and reading, or writing a script that scans the image.

Want: `deflower --strings <file>`, reading a `.vsf` or `.prg` like `--dump`, and listing every run of at least N characters that reads as text in either encoding, using the same character mapping as `--dump`'s columns. One line per run: the range (end exclusive, pastable into a `.flo` line), the encoding, and the text. Hints worth printing when they apply: a terminator right after the run (`$00`, `$ff`) or a length byte right before it, so the line can be typed as `ascii[until $00]` or `screencode[lengthbyte]`.

Nothing is declared; this only points at candidates. The `.flo` file stays the place where text is typed, and nothing about text is guessed in the disassembly itself.

To decide:
- the minimum length, and whether punctuation and digits alone count (they make many false hits in tables);
- whether reversed screen codes count, as they do in `--dump`;
- whether runs inside areas a `.flo` file already covers should be skipped, which needs a `.flo` file instead of an input file.

Related: [0080](0080-show-memory-as-screen-text-and-glyphs.md) shows a chosen range as screen text, glyphs or sprites.

Done when: the flag lists the title and the other strings of a fixture (e.g. 1nvader's `1nvader +1 by faay d/excess` at `$c0f8`) in a snippet, and is described in `CLAUDE.md`.
