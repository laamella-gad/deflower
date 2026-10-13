---
title: Say what is known about each gap in the verify report
status: open
priority: medium
labels: enhancement
---

The verify report lists gaps as bare ranges (`gap $4944-$496a`). To decide what each one is, I had to dump it, grep the `.asm` for what comes before it, and grep again for instructions whose operands point into it. For `bigmac` that was 30-odd gaps, several times over. Most of them had an obvious answer once the context was known:
- `$4944-$496a`, `$6721-$673b`, `$67bf-$67c6`: the gap follows a `jmp`/`rts`, and its bytes decode as instructions up to another `rts`/`jmp`. Dead code, left from patching.
- `$c5fc-$c600`: four bytes read by `lda $c5fb, x` with x from 4 down to 1. A table.
- `$c7f2-$c7fb`: zeroes after an `rts`. Padding.
- `$0fff-$1026`: right before `player_text`, and read by nothing.
- the sprite tables at `$097e`: `sta $0988, y`, `lda $099c, x`, ... at offsets 10 apart.

Want: each gap line followed by what the run knows, short enough to scan:

```
gap $4944-$496a  after jmp $66a0 at $4941; decodes to rts at $4969; no references
gap $c5fc-$c600  read by $c5ef (lda $c5fb, x)
gap $c7f2-$c7fb  9 zeroes after rts at $c7f1
```

- what ends before it (a flow end, an array, a text);
- references into it: operands, indexed bases just below it, address setups;
- whether it decodes cleanly as code, and to what;
- a run of one byte value (padding).

Maybe also a ready-to-paste `.flo` line as a suggestion, where the answer is clear (`$4944 code`, `$c7f2-$c7fb byte`), which would take care of the many tiny gaps that each needed a line by hand.

Related: [0081](0081-flag-unreferenced-code-and-leftovers.md) guesses at leftovers in gaps; [0070](0070-preview-gap-as-code.md) previews a gap as code. This issue is about putting the facts next to the gap where they are needed.

Done when: `--verify` on a `.flo` file with gaps prints the context for each, covered by a short snippet with a dead-code gap, a referenced table gap and a padding gap.
