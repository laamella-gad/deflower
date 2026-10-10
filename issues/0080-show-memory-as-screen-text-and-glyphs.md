---
title: Show memory as screen text, character glyphs or sprites while exploring
status: open
priority: low
labels: enhancement
---

Data in C64 programs is often a screen, a character set or sprites. Recognising it from `.byte` lines is slow. For `squirm`, a script had to print memory as screen codes to see that `$1042` is the high score screen and `$138a` the title, and render characters `$43-$5d` as pixels to name them (snake head, points glyphs, player frames).

Want: a way to look at a range in those shapes without declaring it first:
- as text, decoding screen codes (and PETSCII) in rows of 40, reversed characters marked;
- as character glyphs, 8 rows of `#`/`.` per character, using the program's own character set or the ROM one;
- as sprites, 24×21 pixels.

## To decide

- **Where.** A mode of the inspect flag ([0072](0072-inspect-input-file.md)), a separate flag taking a range and a shape, or a comment Deflower adds above data in the output.
- **Relation to 0020.** [0020](0020-pretty-data-formats.md) prints declared charsets and sprites as binary rows in the output. This is for looking before declaring, and may share the rendering.

Done when: the high score screen and the custom characters of `squirm` can be shown in a readable form with one command.
