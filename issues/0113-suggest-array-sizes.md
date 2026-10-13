---
title: Suggest array sizes from the loops that index them
status: open
priority: low
labels: enhancement
---

Every array in `bigmac` was sized by reading the loops over it:
- `cpx #$28` after `sta $080c, x`: 40 bytes, one per screen column;
- `ldx #$00` ... `sta $097e, x` / `inx` / `cpx #$78`: 120 bytes cleared, twelve arrays of 10;
- `ldx #$04` ... `lda $c5fb, x` / `dex` / `bne`: 4 bytes at `$c5fc`.

The same instructions also tell where an array starts: the base of an indexed operand, less the lowest index (`$c5fb + 1`).

Want: deflower notices these patterns and offers the result, as a comment above the array's label or in the map, e.g. `; indexed by $3c60 with x 0-$77: 120 bytes` or a ready-to-paste `$097e byte[120]`:
- a loop that counts an index register up from a constant to a `cpx`/`cpy` constant, or down from a constant to 0 (`dex`/`bne`, `dey`/`bpl`), with an indexed access on that register inside it;
- the access's base and the counted range give the array.

Only as a suggestion, never as an area: a loop can cover several arrays at once, or part of one.

Done when: `bigmac` with no `.flo` lines for the arrays gets a correct size suggestion for `$080c`, `$097e` and `$c5fc`, and a short snippet covers the up and down loops.
