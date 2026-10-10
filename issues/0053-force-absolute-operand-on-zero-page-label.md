---
title: Absolute operand on a zero-page label reassembles as zero page
status: done
labels: bug
---

When an absolute-mode instruction (`ABSOLUTE`, `ABSOLUTE_X`, `ABSOLUTE_Y`) refers to an address below `$100`, and that address prints as a label, 64tass picks the shorter zero-page form for it. Reassembling then produces different bytes from the original.

Found while doing issue 0015, which labels absolute data references, including ones into zero page. In zwark, `ISC $00FF, X` and `ISC $0000, X` (absolute,X) became `ISC d00FF, X` / `ISC d0000, X`. Since [0054](0054-empty-labels-on-uncovered-memory.md), memory no area covers isn't labelled any more, so those are numeric again, but the numeric case below still applies. A user label on a zero-page `virtual` area hit by an absolute instruction has the same problem.

Fix: in `AssemblyFileFormat.printInstruction`, write such an operand with 64tass's `@w` prefix (`ISC @w d00FF, X`), which forces the 16-bit form.

Done when: an absolute operand below `$100` that prints as a label carries `@w`, and a fixture shows it reassembles to the original bytes.

Not only labels: 64tass shortens a plain numeric absolute operand below `$100` too. zwark's `ISC $0000, X` at `$FFE1` already assembled as 2 bytes before 0015, which put the next label, `lFFE4`, at `$FFE3`. So the fix should cover every absolute-mode operand below `$100`, numeric or label.

## Closing note

`AssemblyFileFormat.printInstruction` now writes every `ABSOLUTE`, `ABSOLUTE_X` and `ABSOLUTE_Y` operand below `$100` with `@w`, label or number alike (`absoluteOperand`). It is added even where the instruction has no zero-page form (`JMP`, `LDA abs,Y`): 64tass accepts `@w` there and assembles the same bytes, so one rule is simpler than a per-opcode table.

New fixture `absolutezeropage`: `LDA @w counter` (a virtual zero-page label), `STA @w $00FF, X` and `LDX @w $0020, Y` (numeric), `LDA @w pair + $1` (inside a zero-page array). The zero-page forms of the same operands sit next to them and print without `@w` (`LDA counter`, `STA $FF, X`, `LDX $20, Y`, `LDA ($30, X)`, `LDA ($40), Y`, `LDA pair + $1`). It assembles to the `.prg`.

zwark's expectation changed in exactly the two lines named above (`ISC @w $00FF, X`, `ISC @w $0000, X`). Checked against the RAM images through a 64tass listing, zwark now reassembles with 0 differing bytes (it had 6 before), and squirm with 0.

47/47 tests green.
