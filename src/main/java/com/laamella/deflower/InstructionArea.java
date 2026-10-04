package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

public class InstructionArea extends Area {
    public Instruction instruction;

    InstructionArea(int address, Instruction instruction) {
        super(address, instruction.addressingMode.totalBytes);
        this.instruction = instruction;
    }

    @Override
    public String labelFor(int address, Subject subject) {
        int offset = address - this.address;
        String label = subject.memory[this.address].label;
        if (label == null) {
            return null;
        }
        if (offset == 0) {
            return label;
        }
        return String.format("%s + %d", label, offset);
    }
}
