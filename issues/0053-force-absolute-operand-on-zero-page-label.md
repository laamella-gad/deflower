---
title: Absolute operand on a zero-page label reassembles as zero page
status: open
labels: bug
---

When an absolute-mode instruction (`ABSOLUTE`, `ABSOLUTE_X`, `ABSOLUTE_Y`) refers to an address below `$100`, and that address prints as a label, 64tass picks the shorter zero-page form for it. Reassembling then produces different bytes from the original.

Found while doing issue 0015, which labels absolute data references, including ones into zero page. In zwark, `ISC $00FF, X` and `ISC $0000, X` (absolute,X) become `ISC d00FF, X` / `ISC d0000, X`. A user label on a zero-page `virtual` area hit by an absolute instruction has the same problem.

Fix: in `AssemblyFileFormat.printInstruction`, write such an operand with 64tass's `@w` prefix (`ISC @w d00FF, X`), which forces the 16-bit form.

Done when: an absolute operand below `$100` that prints as a label carries `@w`, and a fixture shows it reassembles to the original bytes.
