---
title: --find reports addresses inside code operands and graphics, and repeats lo/hi rows
status: open
priority: low
labels: enhancement
---

Searching `bigmac.vsf` for addresses with `--find`:
- **Operands.** The `addr` and `rta` hits include the operand bytes of instructions: `$0b6e rta` for an address came from the bytes of a `cmp $c5` and its neighbour. Looking for a table that holds an address, a hit inside code is almost never the answer.
- **Graphics.** Sprites and characters hold many byte pairs that read as plausible addresses; searching for `$0c1a` gave two `rta` hits in level data and their copies (`$6bb8`, `$6bdc`, `$b06a`, `$b08e`), none meaningful.
- **lo/hi rows.** The `lo/hi` kind printed the same table pair several times, once per low byte, which pushed the useful hits off the screen.

`--find` reads only the input file, so it can't know what is code. Ideas:
- Take an optional `.flo` file (`--find <file.flo> ...`, or `with <file.flo>`), run the analysis without writing anything, and mark or skip hits in decoded instructions and in declared graphics, saying which area each hit lies in: `$4a10 addr in code (operand of lda at $4a0f)`.
- Collapse the `lo/hi` rows of one table pair into one line.
- Order the hits: data hits first, those inside code last.

Done when: the searches above give the meaningful hits first, the `lo/hi` pair prints once, and a `find/` snippet covers it.
