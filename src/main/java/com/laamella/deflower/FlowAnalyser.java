package com.laamella.deflower;

import com.laamella.mpu6502.specification.AddressingMode;
import com.laamella.mpu6502.specification.Instruction;

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
        if (memoryLocation.area != null) {
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
                    subject.registerBlock(new DataArea(pointerAddress, DataType.POINTER, false));
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
