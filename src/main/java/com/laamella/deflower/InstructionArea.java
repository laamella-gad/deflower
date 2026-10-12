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

    /**
     * True when execution can't fall through to the next instruction:
     * jmp, rts, rti and brk (issue 0073).
     */
    boolean endsFlow() {
        switch (instruction.opcode) {
            case JMP, RTS, RTI, BRK:
                return true;
            default:
                return false;
        }
    }

    /**
     * A label on `address` itself, such as one on an operand that
     * self-modifying code writes to, wins over "label + offset" from the
     * label on the instruction's first byte (issue 0067).
     */
    @Override
    public String labelFor(int address, Subject subject) {
        String directLabel = subject.memory[address].labelName();
        if (directLabel != null) {
            return directLabel;
        }
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
        if (subject.memory[address].label != null) {
            return address;
        }
        return subject.memory[this.address].label != null ? this.address : -1;
    }
}
