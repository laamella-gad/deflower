---
title: Detect copy loops and suggest where the block runs
status: done
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

## Closing note

`finders.findCopyLoops`: an `lda`/`sta` pair on the same index, stepped by `inx`/`dex`/`iny`/`dey` (maybe with a `cpx`/`cpy #`), a branch or `jmp` back to after an immediate load of the index, and optionally a `beq` for a zero-terminated copy. When the target isn't loaded and a `jsr`/`jmp` goes into it, the run prints `hint: $0822 copies $0876-$0945 to $00f7-$01c6: load 3dgolf.prg $0876-$0945 at $00f7` after the warnings; the `load` part only when a `.prg` loaded at its own address holds the block. 3dgolf and 3dgolfpic gained that hint; pasting it traces the code at `$00f7` and verifies with 0 differ. Snippet `short/copy_loop_hint.txt`; README "The output".
