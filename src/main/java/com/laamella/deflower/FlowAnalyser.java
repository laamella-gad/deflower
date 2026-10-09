package com.laamella.deflower;

import com.laamella.mpu6502.specification.AddressingMode;
import com.laamella.mpu6502.specification.Instruction;

import static com.laamella.Printing.asHexWord;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.ByteManipulation.word;

class FlowAnalyser {
    void analyseCodeFlows(Subject subject) {
        System.out.println("Starting flow analysis.");

        if (subject.potentialCodeLocations.isEmpty()) {
            System.out.println("No entry points defined, nothing to do.");
        }

        while (!subject.potentialCodeLocations.empty()) {
            int startAddress = subject.potentialCodeLocations.pop();
            analyseCodeFlow(startAddress, subject);
        }
    }

    private void analyseCodeFlow(int startAddress, Subject subject) {
        MemoryLocation memoryLocation = subject.memory[startAddress];
        if (memoryLocation.area != null && !memoryLocation.area.isPlaceholder()) {
            if (memoryLocation.area instanceof DataArea) {
                System.out.println("Jumping into non-code area " + memoryLocation.area.toString());
            }
            return;
        }
        Instruction instruction = Instruction.INSTRUCTION_BY_NR[memoryLocation.data];
        int address = memoryLocation.address;
        if (instruction == null) {
            System.out.println("Jumped into a JAM");
            return;
        }
        if (runsIntoExistingArea(address, instruction, subject)) {
            return;
        }
        InstructionArea instructionBlock = new InstructionArea(address, instruction);
        subject.registerBlock(instructionBlock);
        switch (instruction.opcode) {
            case RTS:
            case BRK:
                break;
            case JSR:
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, false, address);
            case JMP:
                if (instruction.addressingMode == AddressingMode.INDIRECT) {
                    // The operand is a pointer, not the destination: label the
                    // pointer cell as data and follow the address stored there.
                    int pointerAddress = getAbsoluteAddressOperand(address, subject);
                    subject.ensureLabelled(pointerAddress, "POINTER", address);
                    subject.registerBlock(new DataArea(pointerAddress, DataType.POINTER, false, null, 0));
                    subject.addPotentialCodeLocation(subject.wordAt(pointerAddress), true, address);
                } else {
                    subject.addPotentialCodeLocation(getAbsoluteAddressOperand(address, subject), true, address);
                }
                break;
            case BCC:
            case BCS:
            case BEQ:
            case BMI:
            case BNE:
            case BPL:
            case BVC:
            case BVS:
                subject.addPotentialCodeLocation(getRelativeAddressOperand(address, subject), true, address);
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, false, address);
                break;
            case LDA:
                switch (instruction.addressingMode) {
                    case ABSOLUTE ->
                            subject.ensureLabelled(getAbsoluteAddressOperand(address, subject), "DATA", address);
                }
            default:
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, false, address);
        }
    }

    /**
     * Decoding started cleanly at a free address, but a 2- or 3-byte
     * instruction's own length can still run into an address another Area
     * already owns - typically a .flo-declared DataArea (issue 0023). Don't
     * disassemble into it: this is the mirror case of jumping straight into
     * a non-code area, caught the same way.
     */
    private boolean runsIntoExistingArea(int address, Instruction instruction, Subject subject) {
        for (int offset = 1; offset < instruction.addressingMode.totalBytes; offset++) {
            Area existing = subject.memory[address + offset].area;
            if (existing != null && !existing.isPlaceholder()) {
                System.out.println("Instruction at " + asHexWord(address) + " would run into " + existing + ", not disassembling");
                return true;
            }
        }
        return false;
    }

    private Integer getRelativeAddressOperand(int address, Subject subject) {
        int offset = toSignedByte(subject.memory[address + 1].data);
        return address + offset + 2;
    }

    private int getAbsoluteAddressOperand(int address, Subject subject) {
        MemoryLocation lo = subject.memory[address + 1];
        MemoryLocation hi = subject.memory[address + 2];
        return word(lo.data, hi.data);
    }
}
