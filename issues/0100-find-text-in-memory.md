---
title: A command line flag that lists the stretches of memory that look like text
status: done
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

## Closing note

`deflower --strings <file> [<start>-<end>] [min <n>]` lists the stretches that read as text (`TextFinder`), with `--dump`'s characters, as PETSCII (`ascii`) and as screen codes (`screencode`). Bytes that read in both encodings give a line for each.

The agreed rule, at least 4 characters with at least half of them letters, gave hundreds of hits per snapshot, nearly all bytes of code, tables and graphics. Three filters cut them down: the letters share one case apart from a capital at the start of a word, at least half the characters are different (character sets and sprites repeat a few), and `@` doesn't count (it's the zero byte in screen codes). The default minimum is 6 characters besides spaces, with `min <n>` to change it per run. Hits per snapshot (1nvader, 2krace, 3dgolf, squirm) at a minimum of 4 / 6: 191/31/590/121 against 69/8/321/60. Real text survives at 6: 1nvader's title, `can't kill you? (y/n)`, `highscore`, and 3dgolf's messages. 3dgolf stays noisy, as much of its data is bytes below $40, which all read as screen codes.

Spaces at either end are left out. A stretch followed by $00 or $ff prints as `$addr <type>[until $xx]`, one preceded by its length as `$addr <type>[lengthbyte]`, else as `$start-$end <type>`, then the text in quotes, so the line can be pasted into a `.flo` file. Reversed screen codes don't count, as `screencode` can't print them. Skipping memory a `.flo` file already covers was left out: the flag reads an input file, not a `.flo` file. `strings/` snippets cover a snapshot range, a lower minimum, `[until $ff]`, `[lengthbyte]`, a crunched `.prg` and two bad argument lists.
