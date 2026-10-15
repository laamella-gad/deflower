---
title: mpu6502's two opcode tables disagree on the accumulator mode of asl, rol, lsr and ror
status: done
labels: cleanup
---

mpu6502 has two opcode tables, and the Nim port in `mpu6502/src/mpu6502/specification.nim` keeps both as they are in Java:
- the per-opcode arrays (`Opcode.ADDRESSING_MODE` in Java, `addressingMode` in Nim), which the assembler and the emulator use;
- the instructions (`Instruction.INSTRUCTION_BY_NR`, `instructionByNr`), which deflower decodes with.

For `asl`, `rol`, `lsr` and `ror` on the accumulator ($0a, $2a, $4a, $6a), the arrays say `NONE` and the instructions say `ACCUMULATOR`. All other modes agree (checked with `mpu6502/tests/opcodes.txt`, which the Java tables printed). The 12 jamming opcodes are `JAM` in the arrays and have no instruction, which is meant.

Nothing goes wrong today:
- deflower prints both modes the same way, with no operand (`ResultWriter`, `case JAM, ACCUMULATOR, NONE -> ""`);
- `SourceParser` works around it, so both `asl` and `asl a` assemble. The code says so: "The opcode table has asl, lsr, rol and ror on the accumulator as NONE".

Still, two tables that disagree are a trap for whoever uses the other one next, e.g. the emulator for [0096](0096-run-the-code.md).

Options:
- Make the arrays say `Accumulator` too. The workaround in the parser then goes, and `mpu6502/tests/opcodes.txt` changes for those 4 lines.
- Better: one table. Derive the arrays from the instructions, or the other way round, so they can't drift apart.

Fix it in both versions: the Java mpu6502 (`~/IdeaProjects/Mpu6502`, `Opcode.ADDRESSING_MODE`, the workaround in `SourceParser.parseInstruction` and the emulator's uses of the arrays) and the Nim one in `mpu6502/`, so they stay the same. Deflower itself uses the Nim one only, since [0059](0059-convert-to-nim.md). Its tests must still pass unchanged.

Done when both mpu6502 versions have one source for each opcode's addressing mode, the accumulator ones say `Accumulator`, and `mpu6502/tests/opcodes.txt` is printed again from the fixed Java tables.

## Closing note

Done, with one table in each version. The per-opcode arrays are the source: in Nim, `instructions` is built from `opcodeRows` (the name too, e.g. `NOP_ZP_04`), and a comparison showed the built table equal to the old literal one, apart from the 4 fixed modes. In Java, each `Instruction` constant only gives its number and reads the rest from the `Opcode` arrays. $0a, $2a, $4a and $6a now have mode `Accumulator` in both, and the parser workaround is gone from both `SourceParser`s. `mpu6502/tests/opcodes.txt` is printed again from the Java tables; only those 4 lines changed. The Java tests pass (the emulator's included), and deflower's tests pass unchanged.
