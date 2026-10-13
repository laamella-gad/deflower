---
title: A code entry in leftover code traces into graphics without a warning
status: open
priority: low
labels: enhancement
---

While filling `bigmac`'s gaps, the code at `$c7fb` looked like part of the music player and got a `code` line. It is the remains of a loader, and its first instruction is `jsr $3013`, into the middle of the sprites at `$2b00-$3880`. Deflower decoded the sprite bytes there as code (`beq`, `nop @w $00ff`, `slo ($fb, x)`, `brk`), without a warning, because no area covered them yet. The only hint was two new gaps in the middle of the sprite block in the verify report.

A trace from an entry the user added by guess is weaker than one from a vector or the snapshot PC, and it can reach memory that plainly isn't code:
- it decodes a `brk` or an illegal opcode within a few instructions;
- the bytes look like graphics: mostly `$00`, with patterns repeating at a 3-byte stride (sprites) or within 8-byte cells (characters), or they lie inside the charset or sprite range the snapshot's VIC registers point at, which `--init` already knows.

Want: a warning when a trace reaches such memory, naming the entry it came from, e.g. `warning: $3013: jsr from $c7fb into what looks like sprite data`. The illegal-opcode and `brk` cases already have most of what is needed (`Warning`); the VIC ranges would need `--init`'s facts at analysis time, or a `.flo` line for them.

Related: [0081](0081-flag-unreferenced-code-and-leftovers.md) points out leftovers in gaps; this is the other side, a trace that wanders into data because of one.

Done when: `bigmac` with `$c7fb code` warns about the flow into the sprites at `$3013`.
