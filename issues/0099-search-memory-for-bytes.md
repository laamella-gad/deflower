---
title: A command line flag that searches an input file's memory for bytes or an address
status: done
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

## Closing note

`deflower --find <file> <pattern> [in <start>-<end>]` searches the memory `MemoryImage` reads (`Finder`). One flag takes both forms, by shape: one number above 255, or one hex number with 3 or 4 digits, is an address; anything else is a byte sequence. A byte above $ff in a sequence is an error.

An address is found three ways, each hit a line with its address, kind and the 8 bytes from there:
- `addr`: the little-endian word;
- `rta`: the address minus one;
- `lo/hi`: the low byte at `x` and the high byte at `x + d`, for `d` from 2 to 256. Without more evidence nearly any low byte has the high byte somewhere within 256 bytes, so a neighbouring pair at the same distance (`x - 1` or `x + 1`) must have a high byte within 1 of this one, as entries of one table do. A high byte table often repeats a byte, which then matches at every distance in the run, so the line lists the high byte addresses as ranges: 2krace's `pattern_lo` entry at `$1379` gives `high byte at $1382-$1388`, which holds the real `$1384`.

The optional `in <range>` limits the search, both bytes of a hit inside it. `Deflower.look` now parses the arguments of `--dump`, `--find` and `--strings` for `main` and the tests. `find/` snippets cover an address with split tables, 3dgolf's bitmap row tables, an `rta`, a byte sequence in a snapshot and in a `.prg`, a decimal address and three bad patterns.
