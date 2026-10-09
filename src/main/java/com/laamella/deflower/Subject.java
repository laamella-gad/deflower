package com.laamella.deflower;

import java.nio.file.Path;
import java.util.*;

import static com.laamella.Printing.asHexWord;

class MemoryLocation {
    final int address;
    final int data;
    Area area = null;
    String label = null;
    String comment = null;

    MemoryLocation(int address, int data) {
        this.address = address;
        this.data = data;
    }
}

class Subject {
    final Path outputPath;
    MemoryLocation[] memory;
    final Path basePath;
    final Stack<Integer> potentialCodeLocations = new Stack<>();
    String outputFileName = "deflowered.asm";
    final List<String> errors = new ArrayList<>();

    Subject(Path basePath) {
        this.basePath = basePath;
        this.outputPath = basePath.resolve("out");
        this.memory = new MemoryLocation[0x10000];
        for (int i = 0; i < memory.length; i++) {
            memory[i] = new MemoryLocation(i, 0);
        }
    }

    void storeAt(int startAddress, byte[] bytes) {
        for (int i = 0; i < bytes.length; i++) {
            memory[startAddress+i] = new MemoryLocation(startAddress + i, bytes[i] & 0xff);
        }
    }

    Area peek(int address) {
        return memory[address].area;
    }

    int byteAt(int address) {
        return memory[address].data;
    }

    int wordAt(int address) {
        return byteAt(address) + 256 * byteAt(address + 1);
    }

    int dwordAt(int address) {
        return wordAt(address) + 256 * 256 * wordAt(address + 2);
    }

    /**
     * Applies one {@code .flo} annotation line: its label and comment go
     * onto its address, a code entry becomes a place to start the flow
     * analysis from, and a data line registers one DataArea per element.
     */
    void annotate(Annotation annotation) {
        int address = annotation.address;
        if (annotation.name != null) {
            memory[address].label = annotation.name;
        }
        if (annotation.comment != null) {
            memory[address].comment = annotation.comment;
        }
        LineType type = annotation.type;
        switch (type) {
            case CODE_ENTRY -> {
                potentialCodeLocations.add(address);
                System.out.format("Will disassemble from %X\n", address);
            }
            case CHAR_BLOCK, BYTE_BLOCK, WORD_BLOCK, DWORD_BLOCK, UNKNOWN_BLOCK -> {
                int amount = annotation.addressEnd != null
                        ? (annotation.addressEnd - address) / type.dataType.sizeInBytes
                        : annotation.amount;
                if (amount <= 0) {
                    // Issue 0044: an empty array, or a range too short to
                    // hold one element (e.g. $c006-$c007 word: the end is
                    // exclusive), is a mistake, not a no-op.
                    errors.add(String.format("Zero-size %s at %s", type.dataType.name().toLowerCase(), asHexWord(address)));
                    return;
                }
                System.out.format("Marking block of %d %s at %X \"%s\"\n", amount, type.dataType.name().toLowerCase(), address, annotation.name);
                for (int i = 0; i < amount; i++) {
                    registerBlock(new DataArea(address + i * type.dataType.sizeInBytes, type.dataType, annotation.virtual, annotation.name, i));
                }
            }
            default -> throw new RuntimeException("No data type");
        }
    }

    boolean isVirtualAt(int address) {
        Area area = peek(address);
        return area != null && area.isVirtual();
    }

    /**
     * True when a label or comment is attached to `address`.
     */
    boolean isAnnotated(int address) {
        return memory[address].label != null || memory[address].comment != null;
    }

    /**
     * The first address after `start` and before `end` with a label or
     * comment, or `end` when there is none.
     */
    int firstAnnotatedAddressInside(int start, int end) {
        for (int address = start + 1; address < end; address++) {
            if (isAnnotated(address)) {
                return address;
            }
        }
        return end;
    }

    /**
     * True when the run of data `block` is part of carries on at `address`:
     * an element of the same type, virtual or not like `block`, starts
     * there, and no label or comment interrupts the run.
     */
    boolean continuesRun(DataArea block, int address) {
        if (address >= memory.length || isAnnotated(address)) {
            return false;
        }
        Area area = peek(address);
        return area instanceof DataArea
                && area.address == address
                && ((DataArea) area).type == block.type
                && area.isVirtual() == block.isVirtual();
    }

    /**
     * The (exclusive) end of the run of same-type elements starting at
     * `first`: it stops before an element that differs or carries its own
     * label/comment, and after an element with a label/comment somewhere
     * inside it, so that annotation can still be printed.
     */
    int endOfRun(DataArea first) {
        int end = first.address + first.size;
        while (firstAnnotatedAddressInside(end - first.size, end) == end && continuesRun(first, end)) {
            end += first.size;
        }
        return end;
    }

    /**
     * The (exclusive) end of the array `element` belongs to: the elements
     * one {@code .flo} line declared.
     */
    int endOfArray(DataArea element) {
        int end = element.arrayStart();
        for (int index = 0; end < memory.length && element.isInSameArray(peek(end), index); index++) {
            end += element.size;
        }
        return end;
    }

    /**
     * The 64tass encoding the text at `start` (inclusive) to `end`
     * (exclusive) is most likely written in. Counts the bytes that are
     * uppercase letters in each: $41-$5A under "none" (ASCII), $01-$1A
     * under "screen" (Commodore screen codes). More wins; a tie (e.g.
     * digits, reverse video) returns `onTie`. Only uppercase counts,
     * because ASCII uppercase is also screen-code lowercase, and a stray
     * $00 terminator or length byte would otherwise tip plain ASCII text
     * over to "screen".
     */
    String likelyTextEncoding(int start, int end, String onTie) {
        int none = 0;
        int screen = 0;
        for (int address = start; address < end; address++) {
            int value = byteAt(address);
            if (value >= 0x41 && value <= 0x5A) {
                none++;
            }
            if (value >= 0x01 && value <= 0x1A) {
                screen++;
            }
        }
        return screen > none ? "screen" : none > screen ? "none" : onTie;
    }

    /**
     * Reports every label that is defined at more than one address (issue
     * 0043): the assembler would reject it, or code references would
     * resolve to the wrong one. Run after the flow analysis, so the
     * auto-generated labels are checked too.
     */
    void reportDuplicateLabels() {
        Map<String, Integer> firstAddressByLabel = new HashMap<>();
        for (MemoryLocation location : memory) {
            if (location.label == null) {
                continue;
            }
            Integer first = firstAddressByLabel.putIfAbsent(location.label, location.address);
            if (first != null) {
                errors.add(String.format("Duplicate label %s at %s, already defined at %s", location.label, asHexWord(location.address), asHexWord(first)));
            }
        }
    }

    void registerBlock(Area area) {
        for (int a = 0; a < area.size; a++) {
            int address = a + area.address;
            Area existing = memory[address].area;
            if (existing != null && !existing.equals(area) && !existing.isPlaceholder()) {
                errors.add(String.format("Area conflict at %s: %s overwrites %s", asHexWord(address), area, existing));
            }
            memory[address].area = area;
        }
    }

    public void addPotentialCodeLocation(int address, boolean labelIt, int referencingAddress) {
        MemoryLocation location = memory[address];
        if (labelIt) {
            ensureLabelled(address, "CODE", referencingAddress);
        }
        if (location.area == null) {
            potentialCodeLocations.add(address);
        }
    }

    public void ensureLabelled(int address, String contentHint, int referencedFromAddress) {
        MemoryLocation location = memory[address];
        if (location.label == null) {
            location.label = String.format("_%04X_%s", address, contentHint);
            System.out.println("Unnamed target: " + location.label + " from address " + asHexWord(referencedFromAddress));
        }
    }
}
