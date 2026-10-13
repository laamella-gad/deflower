package com.laamella.deflower;

import java.util.ArrayList;
import java.util.List;

/**
 * What covers each part of memory, one line per piece, written to
 * out/&lt;binary&gt;.map on every run (issue 0075). Ranges are $start-$end
 * with the end exclusive, as in a .flo file:
 * <pre>
 * $c000-$c007 code entry
 * $c007-$c009 word table
 * $c009-$c00d virtual word[2] table + $2
 * $c00d-$c010 gap
 * </pre>
 * Code runs split at every routine label (not at local ones), arrays are
 * one line, and a gap is loaded memory no area covers. Memory the image
 * doesn't load and no area covers isn't listed, and neither are the
 * included virtual areas the output leaves out as unused.
 */
final class MemoryMap {
    private MemoryMap() {
    }

    static List<String> lines(Subject subject) {
        MemoryLocation[] memory = subject.memory;
        List<String> lines = new ArrayList<>();
        int address = 0;
        while (address < memory.length) {
            Area area = memory[address].area;
            int start = address;
            if (area instanceof InstructionArea) {
                address = area.address + area.size;
                while (address < memory.length
                        && memory[address].area instanceof InstructionArea
                        && memory[address].area.address == address
                        && !startsRoutine(memory[address])) {
                    address += memory[address].area.size;
                }
                lines.add(range(start, address) + " code" + label(memory[start].labelName()));
            } else if (area instanceof DataArea) {
                DataArea first = (DataArea) area;
                DataArea last = first;
                int count = 1;
                address = first.address + first.size;
                while (address < memory.length
                        && memory[address].area instanceof DataArea
                        && memory[address].area.address == address
                        && last.isInSameArray(memory[address].area, last.indexInArray + 1)
                        && memory[address].area.isVirtual() == first.isVirtual()
                        && ((DataArea) memory[address].area).export == first.export) {
                    last = (DataArea) memory[address].area;
                    count++;
                    address += last.size;
                }
                lines.add(range(first.address, address) + describe(first, count) + label(first.labelFor(first.address, subject)));
            } else if (area != null) {
                address = area.address + area.size;
            } else {
                while (address < memory.length && memory[address].area == null && isGap(memory[address]) == isGap(memory[start])) {
                    address++;
                }
                if (isGap(memory[start])) {
                    lines.add(range(start, address) + " gap");
                }
            }
        }
        return lines;
    }

    /**
     * The gaps: loaded memory no area covers, as {start, end} with the end
     * exclusive.
     */
    static List<int[]> gaps(Subject subject) {
        MemoryLocation[] memory = subject.memory;
        List<int[]> gaps = new ArrayList<>();
        int address = 0;
        while (address < memory.length) {
            if (isGap(memory[address])) {
                int start = address;
                while (address < memory.length && isGap(memory[address])) {
                    address++;
                }
                gaps.add(new int[]{start, address});
            } else {
                address++;
            }
        }
        return gaps;
    }

    /**
     * Loaded memory that no area covers. An included virtual area dropped
     * as unused still covers its memory.
     */
    static boolean isGap(MemoryLocation location) {
        return location.loaded && location.area == null && !location.droppedVirtual;
    }

    static String range(int start, int end) {
        return String.format("$%04x-$%04x", start, end);
    }

    private static boolean startsRoutine(MemoryLocation location) {
        return location.label != null && !location.label.local;
    }

    private static String describe(DataArea area, int count) {
        String type = area.type == DataType.UNKNOWN ? "untyped" : area.type.name().toLowerCase();
        return (area.isVirtual() ? " virtual " : " ") + type
                + (count > 1 ? "[" + count + "]" : "")
                + (area.export != null ? " export " + area.export.fileName : "");
    }

    private static String label(String name) {
        return name != null ? " " + name : "";
    }
}
