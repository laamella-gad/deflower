package com.laamella.deflower;

import java.util.ArrayList;
import java.util.List;

import static com.laamella.Printing.asHexWord;

/**
 * The data a routine's parameter list (issue 0068) says follows each jsr
 * to it.
 */
final class InlineData {
    private InlineData() {
    }

    /**
     * Registers the data a routine's parameter list (issue 0068) says
     * follows the jsr at `jsrAddress`, from `start` on, and returns where
     * the call returns to: after that data. Data a .flo line already
     * declared there wins, and the call returns after it. Returns -1, with
     * a warning, when the data doesn't fit: no terminator before memory the
     * image doesn't load, or running into an area.
     */
    static int register(int jsrAddress, int start, Routine routine, Subject subject) {
        if (routine.parameters.isEmpty()) {
            return start;
        }
        Area existing = start < subject.memory.length ? subject.peek(start) : null;
        if (existing instanceof DataArea && !existing.isPlaceholder() && !existing.isVirtual()) {
            int end = start;
            while (end < subject.memory.length && subject.peek(end) instanceof DataArea
                    && !subject.peek(end).isPlaceholder() && !subject.peek(end).isVirtual()) {
                end++;
            }
            return end;
        }
        List<DataArea> areas = new ArrayList<>();
        List<String> names = new ArrayList<>();
        int address = start;
        for (Parameter parameter : routine.parameters) {
            String what = parameter.name != null ? parameter.name : parameter.type.name().toLowerCase();
            int amount = parameter.amount;
            if (parameter.terminator != null) {
                amount = subject.countUntil(address, parameter.type.sizeInBytes, parameter.terminator);
                if (amount == -1) {
                    subject.warn(jsrAddress, String.format("no $%02x ends %s after the jsr before memory the image doesn't load", parameter.terminator, what));
                    return -1;
                }
            }
            if (parameter.lengthByte) {
                if (address >= subject.memory.length || !subject.memory[address].loaded) {
                    subject.warn(jsrAddress, "the data after the jsr runs past the image");
                    return -1;
                }
                amount = 1 + subject.byteAt(address);
            }
            for (int i = 0; i < amount; i++) {
                areas.add(new DataArea(address, parameter.type, false, null, i, false, null, parameter.terminator, parameter.lengthByte));
                address += parameter.type.sizeInBytes;
            }
            if (parameter.name != null) {
                names.add(parameter.name);
            }
        }
        for (int a = start; a < address; a++) {
            if (a >= subject.memory.length || !subject.memory[a].loaded) {
                subject.warn(jsrAddress, "the data after the jsr runs past the image");
                return -1;
            }
            Area area = subject.peek(a);
            if (area != null && !area.isPlaceholder()) {
                subject.warn(jsrAddress, "the data after the jsr runs into " + (area instanceof InstructionArea
                        ? "the instruction at " + asHexWord(area.address)
                        : "data at " + asHexWord(a)));
                return -1;
            }
        }
        areas.forEach(subject::registerArea);
        if (!names.isEmpty()) {
            subject.callComments.put(jsrAddress, String.join(", ", names));
        }
        return address;
    }
}
