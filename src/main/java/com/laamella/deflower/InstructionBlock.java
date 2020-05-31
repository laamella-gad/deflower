package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

public class InstructionBlock extends Block {
    public Instruction instruction;

    InstructionBlock(int address, Instruction instruction) {
        super(address, instruction.addressingMode.totalBytes);
        this.instruction = instruction;
    }
}
