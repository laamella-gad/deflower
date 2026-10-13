package com.laamella.deflower;

import com.laamella.mpu6502.specification.AddressingMode;
import com.laamella.mpu6502.specification.Instruction;
import com.laamella.mpu6502.specification.Opcode;

import static com.laamella.Printing.asHexWord;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.ByteManipulation.word;

class FlowAnalyser {
    void analyseCodeFlows(Subject subject) {
        while (!subject.potentialCodeLocations.empty()) {
            analyseCodeFlow(subject.potentialCodeLocations.pop(), subject);
        }
    }

    private void analyseCodeFlow(CodeEntry entry, Subject subject) {
        int startAddress = entry.address;
        MemoryLocation memoryLocation = subject.memory[startAddress];
        Area area = memoryLocation.area;
        if (area != null && !area.isPlaceholder()) {
            // Issue 0077: a virtual area, like a KERNAL routine, is code
            // that isn't in the image, so calling it is fine.
            if (area instanceof DataArea && !area.isVirtual()) {
                warnFlow(entry, subject, "data", "is data");
            } else if (area instanceof InstructionArea && area.address != startAddress) {
                String instruction = "the instruction at " + asHexWord(area.address);
                warnFlow(entry, subject, "the middle of " + instruction, "is inside " + instruction);
            }
            return;
        }
        if (!memoryLocation.loaded) {
            // Issue 0065: what is there at run time isn't in the image,
            // so there is nothing to decode. The target keeps its label;
            // one from the .flo file says the user knows what is there.
            if (memoryLocation.label == null || memoryLocation.label.auto) {
                warnFlow(entry, subject, "memory the image doesn't load", "is memory the image doesn't load");
            }
            return;
        }
        Instruction instruction = Instruction.INSTRUCTION_BY_NR[memoryLocation.data];
        int address = memoryLocation.address;
        if (instruction == null) {
            subject.warn(address, String.format("jam ($%02x), not decoded", memoryLocation.data));
            return;
        }
        if (runsIntoExistingArea(address, instruction, subject)) {
            return;
        }
        InstructionArea instructionArea = new InstructionArea(address, instruction);
        subject.registerArea(instructionArea);
        switch (instruction.opcode) {
            case RTS:
            case RTI:
            case BRK:
                break;
            case JSR:
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, false, address);
                subject.addCallTarget(getAbsoluteAddressOperand(address, subject), address);
                break;
            case JMP:
                if (instruction.addressingMode == AddressingMode.INDIRECT) {
                    // The operand is where the destination address is stored,
                    // not the destination: mark that location as an addr and follow
                    // the address stored there. A pointer a .flo line already
                    // declared, like a virtual KERNAL vector, keeps its area, and
                    // one the image doesn't load holds no address to follow.
                    int addrLocation = getAbsoluteAddressOperand(address, subject);
                    subject.ensureLabelled(addrLocation, "a", address);
                    Area existing = subject.peek(addrLocation);
                    if (existing == null || existing.isPlaceholder()) {
                        subject.registerArea(new DataArea(addrLocation, DataType.ADDR, false, null, 0));
                    }
                    if (subject.memory[addrLocation].loaded && subject.memory[(addrLocation + 1) & 0xffff].loaded) {
                        subject.addPotentialCodeLocation(subject.wordAt(addrLocation), true, address);
                    }
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
            default:
                // Every control-flow instruction has its own case above, so
                // an absolute operand here is a data reference.
                switch (instruction.addressingMode) {
                    case ABSOLUTE, ABSOLUTE_X, ABSOLUTE_Y ->
                            labelDataReference(getAbsoluteAddressOperand(address, subject), address, subject);
                }
                subject.addPotentialCodeLocation(address + instruction.addressingMode.totalBytes, false, address);
        }
    }

    /**
     * Warns about flow into memory that isn't code to decode (issue 0077),
     * at the instruction the flow comes from, or at a .flo code entry.
     */
    private void warnFlow(CodeEntry entry, Subject subject, String into, String entryProblem) {
        String target = asHexWord(entry.address);
        String label = subject.memory[entry.address].labelName();
        if (label == null && subject.memory[entry.address].area != null) {
            label = subject.memory[entry.address].area.labelFor(entry.address, subject);
        }
        if (label != null) {
            target += " (" + label + ")";
        }
        if (entry.from == -1) {
            subject.warn(entry.address, "code entry " + entryProblem);
            return;
        }
        Instruction from = ((InstructionArea) subject.memory[entry.from].area).instruction;
        String mnemonic = from.opcode.name().toLowerCase();
        if (entry.fallsThrough && from.opcode == Opcode.JSR) {
            // Often a routine that reads inline data after its jsr (0068).
            subject.warn(entry.from, mnemonic + " returns into " + into + " at " + target);
        } else if (entry.fallsThrough) {
            subject.warn(entry.from, "falls through into " + into + " at " + target);
        } else {
            subject.warn(entry.from, mnemonic + " " + target + " goes into " + into);
        }
    }

    /**
     * Labels the data `target` refers to, unless it can already be named:
     * an address inside a labelled array or instruction resolves as
     * "label + offset", and a label of its own would replace that. Memory
     * no area covers (I/O, vectors, outside the image) stays numeric: a
     * label there would only print as an empty origin block (issue 0054).
     * Neither does memory an included file covers without a name (issue
     * 0078): that area only stops the tracing, and is dropped before the
     * output is written.
     */
    private void labelDataReference(int target, int referencingAddress, Subject subject) {
        Area area = subject.peek(target);
        if (area == null || isIncluded(area) || area.labelFor(target, subject) != null) {
            return;
        }
        subject.ensureLabelled(target, "d", referencingAddress);
    }

    /**
     * Decoding started cleanly at a free address, but a 2- or 3-byte
     * instruction's own length can still run into an address another Area
     * already owns - typically a .flo-declared DataArea (issue 0023). Don't
     * disassemble into it: this is the mirror case of jumping straight into
     * a non-code area, caught the same way. Running past the end of the
     * memory the image loads (issue 0065) is refused too.
     */
    private boolean runsIntoExistingArea(int address, Instruction instruction, Subject subject) {
        for (int offset = 1; offset < instruction.addressingMode.totalBytes; offset++) {
            if (address + offset > 0xFFFF || !subject.memory[address + offset].loaded) {
                subject.warn(address, "the instruction runs past the image, not decoded");
                return true;
            }
            Area existing = subject.memory[address + offset].area;
            if (existing != null && !existing.isPlaceholder()) {
                String what = existing instanceof InstructionArea
                        ? "the instruction at " + asHexWord(existing.address)
                        : "data at " + asHexWord(address + offset);
                subject.warn(address, "the instruction runs into " + what + ", not decoded");
                return true;
            }
        }
        return false;
    }

    private static boolean isIncluded(Area area) {
        return area instanceof DataArea && ((DataArea) area).included;
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
