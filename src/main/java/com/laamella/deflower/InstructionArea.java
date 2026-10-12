package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

import java.util.Objects;

public class InstructionArea extends Area {
    public Instruction instruction;

    InstructionArea(int address, Instruction instruction) {
        super(address, instruction.addressingMode.totalBytes);
        this.instruction = instruction;
    }

    @Override
    public String toString() {
        return super.toString() + " " + instruction.opcode.name().toLowerCase();
    }

    @Override
    public boolean equals(Object o) {
        if (!super.equals(o)) return false;
        InstructionArea other = (InstructionArea) o;
        return instruction == other.instruction;
    }

    @Override
    public int hashCode() {
        return Objects.hash(super.hashCode(), instruction);
    }

    @Override
    public String labelFor(int address, Subject subject) {
        int offset = address - this.address;
        String label = subject.memory[this.address].labelName();
        if (label == null) {
            return null;
        }
        if (offset == 0) {
            return label;
        }
        return String.format("%s + %d", label, offset);
    }

    @Override
    public int labelAddressFor(int address, Subject subject) {
        return subject.memory[this.address].label != null ? this.address : -1;
    }
}
