---
title: Read labels from an assembler include file
status: open
priority: low
labels: enhancement
---

Labels come from `.flo` files only. Existing symbol lists, such as a KERNAL or hardware equate file, the symbols of a game's original source, or a VICE monitor label file, have to be rewritten as `.flo` lines first.

da65's `ASMINC` reads `name = value` lines from an assembler include file and skips the rest ([0060](0060-investigate-da65-features.md)). Deflower could accept the same through `include`: a file that isn't a `.flo` file (`.inc`, `.s`, `.asm`, VICE's `.lbl` with `al C:1234 .name`) yields one label line per symbol, as weak as any included line.

Open: which formats; whether a value below `$100` or a value that isn't an address (a constant like `screen_width = 40`) becomes a label at all; and how to name a symbol that isn't a valid deflower label.

Done when at least the `name = $xxxx` form can be included, documented in `Flo.g4`'s format comment.
