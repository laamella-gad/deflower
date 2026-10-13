---
title: A command line flag that searches an input file's memory for bytes or an address
status: open
priority: medium
labels: enhancement
---

Filling a `.flo` file keeps raising the question "who refers to this address?". The flow analysis only answers it for code it has traced: an address stored as data (a pointer in a table, a vector, an `addr` array) or split into a low-byte table and a high-byte table is invisible until it's declared. Today that takes a throwaway script that loads the image and searches it. With `--dump` ([0097](0097-dump-memory-flag.md)) and `--init` ([0072](0072-inspect-input-file.md)) in place, this is the main thing left that still needs one.

Want: `deflower --find <file> <pattern>`, reading a `.vsf` or `.prg` like `--dump`, and printing every address where the pattern occurs, one line each, with a few bytes of context in `--dump`'s format. The pattern can be:
- a byte sequence: `$a9 $00 $8d`;
- an address, found as a little-endian word (`$c540` finds `40 c5`). Optionally also as an address minus one, as an `rts` dispatch table holds it;
- split tables: the low and the high byte of an address at the same index in two tables, i.e. `lo` at `x + i` and `hi` at `y + i`. This one needs a way to bound the search, e.g. a maximum distance between the tables.

Memory the file doesn't load is never a match. The addresses are printed so they can be pasted into a `.flo` line or a `--dump` range.

To decide:
- whether one flag takes all three forms, or each gets its own syntax;
- whether the split table search is worth it, or whether an address search over both halves is enough for now;
- whether to limit the search to a range, e.g. to skip the ROMs in a snapshot.

Done when: the flag finds a byte sequence and an address in a `.vsf` and a `.prg` fixture, in snippets next to the `dump/` ones, and is described in `CLAUDE.md`.
