package com.laamella.deflower;

import com.laamella.mpu6502.specification.AddressingMode;
import com.laamella.mpu6502.specification.Instruction;
import com.laamella.mpu6502.specification.Opcode;

import static com.laamella.mpu6502.ByteManipulation.word;

/**
 * Looks through the decoded code, after the flow analysis, for address
 * setups (issue 0074).
 */
class AddressSetupFinder {
    /**
     * Finds the code that stores the two halves of a constant address
     * (issue 0074): four instructions in a row, each half an immediate
     * load and a store of the same register, the halves in either order,
     * stored to the two bytes of an addr. A label on the second,
     * third or fourth instruction ends the match, since the code can be
     * entered there, and an instruction is part of one match at most. The
     * built address is labelled like a data reference, and the writer
     * prints the immediates as `#<label` and `#>label` (issue 0034).
     * All matches are found before any label is added, so a new label
     * doesn't end another match.
     */
    void find(Subject subject) {
        for (int address = 0; address < subject.memory.length; address++) {
            int[] starts = new int[4];
            int next = address;
            int i = 0;
            for (; i < 4 && next < subject.memory.length; i++) {
                Area area = subject.memory[next].area;
                if (!(area instanceof InstructionArea) || area.address != next
                        || (i > 0 && subject.memory[next].label != null)) {
                    break;
                }
                starts[i] = next;
                next += area.size;
            }
            if (i < 4) {
                continue;
            }
            int store1 = storedImmediate(starts[0], starts[1], subject);
            int store2 = storedImmediate(starts[2], starts[3], subject);
            if (store1 == -1 || store2 == -1) {
                continue;
            }
            if (!isAddressVariable(Math.min(store1, store2), subject)) {
                continue;
            }
            int low;
            int high;
            if (store2 == store1 + 1) {
                low = starts[0];
                high = starts[2];
            } else if (store1 == store2 + 1) {
                low = starts[2];
                high = starts[0];
            } else {
                continue;
            }
            int built = word(subject.memory[low + 1].data, subject.memory[high + 1].data);
            subject.lowByteSetups.put(low, built);
            subject.highByteSetups.put(high, built);
            // The loop's own address++ then lands on the next instruction.
            address = next - 1;
        }
        subject.lowByteSetups.forEach((low, built) -> subject.labelDataReference(built, low));
    }

    /**
     * True when an addr element starts at `address`: the only memory an
     * address setup stores to, since two adjacent bytes, even a word, can
     * just as well hold two colors, two characters or a number.
     */
    private static boolean isAddressVariable(int address, Subject subject) {
        Area area = subject.peek(address);
        return area instanceof DataArea && area.address == address && ((DataArea) area).type == DataType.ADDR;
    }

    /**
     * Where the store at `store` puts the value the immediate load at
     * `load` gave its register, or -1 when they aren't such a pair.
     */
    private static int storedImmediate(int load, int store, Subject subject) {
        Instruction loadInstruction = ((InstructionArea) subject.memory[load].area).instruction;
        Instruction storeInstruction = ((InstructionArea) subject.memory[store].area).instruction;
        if (loadInstruction.addressingMode != AddressingMode.IMMEDIATE) {
            return -1;
        }
        Opcode matchingStore = switch (loadInstruction.opcode) {
            case LDA -> Opcode.STA;
            case LDX -> Opcode.STX;
            case LDY -> Opcode.STY;
            default -> null;
        };
        if (storeInstruction.opcode != matchingStore) {
            return -1;
        }
        return switch (storeInstruction.addressingMode) {
            case ZERO_PAGE -> subject.memory[store + 1].data;
            case ABSOLUTE -> word(subject.memory[store + 1].data, subject.memory[store + 2].data);
            default -> -1;
        };
    }
}
