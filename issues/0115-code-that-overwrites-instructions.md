---
title: Point out code that overwrites whole instructions, not only their operands
status: open
priority: medium
labels: enhancement
---

[0106](0106-self-modifying-code.md) handles code that writes an instruction's operand bytes: `SelfModificationFinder` flags those instructions, and their operands print as numbers with `; operand set by <routine>`, or by name through a `selfmod` line. A write to an opcode byte is left out, and so is code that writes a whole instruction or routine over other code. The image holds only one version of that code, and that is what deflower decodes and traces.

Two cases:
1. **A patched opcode.** For example, `lda #$60` / `sta patch` turns an instruction into an `rts`, or a `bit`/`jmp` byte toggles a jump on and off. Today the store prints `sta patch`, and the instruction gets the label and a `written by:` cross-reference, which is correct. Nothing says the instruction itself changes, though, and the other version (an `rts`, a taken `jmp`) is never traced.
2. **A routine copied or generated over code.** A loop writes a block of bytes (`sta code, x`) over memory that holds code in the image: a relocated routine, unrolled code built at run time, or an overlay. The listing shows whichever version the snapshot caught, and the other versions only exist as data somewhere else, or nowhere.

Options for 1:
- A comment on the instruction, `; instruction set by <routine>`, like the operand one. The label and the cross-reference stay, since the store really targets the instruction.
- Also list self-modified instructions (operands and opcodes) in `--verify` or the map, which 0106 left out.
- A way to trace the other version, e.g. a `.flo` line giving the opcode the code stores, decoded as a virtual instruction.

Options for 2:
- Detect an indexed store whose base is inside an `InstructionArea` and warn, so the user knows the code there isn't fixed.
- Let the source of a copy be marked as code that runs at another address (a `.logical`-like line), which ties in with relocated code in general.

Done when a disassembly says which instructions other code overwrites, and the chosen ways are documented in `Flo.g4`'s format comment.
