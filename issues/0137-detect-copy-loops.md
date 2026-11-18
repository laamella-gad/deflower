---
title: Detect copy loops and suggest where the block runs
status: open
priority: low
labels: enhancement
---

A block copied to the address it runs at is easy to spot in the code, but only once the copy loop has been read. In The Write Stuff 128 (`~/dev/c64-productivity/tws128`):

```
l377F:  ldy #$75
l3781:  lda $378b, y
        sta l0111, y
        dey
        bpl l3781
```

and a zero-terminated one at `$258b` (`lda $25e3, y` / `beq` / `sta $0270, y` / `iny` / `bpl`). Both targets are then called from all over the program.

Want: when the traced code holds a loop with `lda src, x|y` and `sta dst, x|y` on the same index, `dst` outside the image or code is called at `dst`, print a hint with the line to paste:

```
hint: $377f copies $378b-$3801 to $0111-$0187: load <file> $378b-$3801 at $0111
```

The length comes from the index's start value and the loop's end test (`dey`/`bpl` from `#$75`: `$76` bytes; `beq` on the byte loaded: up to the terminator). The `load` line needs [0133](0133-code-that-runs-at-another-address.md); could start as part of `--init` or as its own `--hints`.
