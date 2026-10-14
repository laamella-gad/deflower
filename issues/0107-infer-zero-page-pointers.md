---
title: Find address setups into zero-page pointers that aren't declared as addr
status: open
priority: medium
labels: enhancement
---

`findAddressSetups` only recognises an address setup when the two bytes it is stored into are declared `addr`. Zero-page pointers are where most of them go, and a new disassembly has none declared. In `bigmac`, `$2465` sets up the pointer to the level data:

```
l2465:
		lda #$4e
		sta $fe
		lda #$1f
		sta $fd
```

so `$4e1f` is the start of the level data, used through `($fd), y`. Nothing labels it, and the 6.4K block `$4d85-$66a0` showed up as one anonymous gap. Finding the start meant grepping the `.asm` for immediates that look like high bytes (`#$4e`) and reading the code around them.

The code tells which zero-page pairs are pointers: an instruction with `(zp), y` or `(zp, x)` addressing uses `zp` and `zp + 1` as one. Want:
- After the trace, every zero-page pair used through indirect addressing counts as an address for `findAddressSetups`, as if it were declared `addr`, unless a `.flo` line says otherwise (a `word`, or a `byte` on either half).
- The setup's order doesn't matter: high byte first, as above, or low byte first. (Check whether the finder already allows both.)
- `--verify` or the map lists the pointers found, so they can be named in the `.flo` file.

Done when: `bigmac` from a fresh skeleton labels `$4e1f` from the setup at `$2465`, with `#<`/`#>` on the immediates, without a `.flo` line for `$fd`.
