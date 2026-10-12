---
title: An operand pointing inside an instruction ignores the label there
status: done
labels: bug
---

Self-modifying code writes into an instruction's operand. Deflower labels the target and prints the label as a define after the instruction (issue 0028), but the instruction that writes there still prints a raw address instead of the label.

Seen in fixture `3dgolf`:

```
		lda $707b, x
d0830 = $0830
		sta $ec13, x
d0833 = $0833
		...
		dec $0833
		dec $0830
```

Expected `dec d0833` and `dec d0830`.

The same in `3dgolf_snap`: `bne $314f` while `l314F = $314f` is defined.

And in `squirm`: `reset_everything` does `jsr $2441` while `l2441 = $2441` is defined, inside the `bne` that ends `draw_high_score_screen`.

Cause: `ResultWriter.nameForAddress` asks the area that covers the address for a label, and `InstructionArea.labelFor` only builds one from the label on the instruction's first byte (`label + offset`). Here the instructions starting at `$082e` and `$0831` have no label, so it returns null and the operand prints as a number, even though `$0830` and `$0833` have labels of their own.

Want: a label on the exact address wins; `label + offset` from the instruction's start label is only the fallback. Check whether `DataArea.labelFor` has the same gap for a label on an element inside an array.

Done when: `3dgolf` prints `dec d0833`/`dec d0830`, and a small fixture covers an operand that points at a labelled byte inside an unlabelled instruction.

## Closing note

`InstructionArea.labelFor` now returns a label on the exact address first, and only falls back to `label + offset` from the instruction's start label without one. `InstructionArea.labelAddressFor` does the same, so the cross-references (issue 0076) of such an operand are listed at its own define. `DataArea.labelFor` already put a label on the exact address first, so arrays had no gap.

New fixture `operandlabel` covers an auto label and a `.flo` label on operands of unlabelled instructions, and the `label + offset` fallback; it reassembles to the `.prg`. `3dgolf` now prints `dec d0833`/`dec d0830`, `3dgolf_snap` `bne l314F` and `squirm` `jsr l2441`. Eight expectations changed, in operand names and in cross-references moving to the labels inside instructions; each new one assembles with 64tass to the same bytes as the old one.
