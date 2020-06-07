package com.laamella.deflower;

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
//        System.out.format("%04X %s\n", address, instruction);
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
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, true);
            case JMP:
                subject.addPotentialCodeLocation(getAbsoluteAddressOperand(address, subject), true);
                break;
            case BCC:
            case BCS:
            case BEQ:
            case BMI:
            case BNE:
            case BPL:
            case BVC:
            case BVS:
                subject.addPotentialCodeLocation(getRelativeAddressOperand(address, subject), true);
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, false);
                break;
            case LDA:
                subject.ensureLabelled(getAbsoluteAddressOperand(address, subject), "DATA");
            default:
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, false);
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
