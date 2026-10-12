package com.laamella.deflower;

import java.nio.file.Path;
import java.util.*;

import static com.laamella.Assert.assertState;
import static com.laamella.Printing.asHexWord;

class MemoryLocation {
    final int address;
    final int data;
    // True when the image put this byte here; memory it doesn't load is
    // unknown, not zero (issue 0065).
    final boolean loaded;
    Area area = null;
    Label label = null;
    // The comment lines from the .flo file, if any.
    List<String> comment = List.of();
    // True when the comment came from an included file (issue 0078).
    boolean commentIncluded = false;

    MemoryLocation(int address, int data, boolean loaded) {
        this.address = address;
        this.data = data;
        this.loaded = loaded;
    }

    /**
     * The label's name, or null when there is no label here.
     */
    String labelName() {
        return label != null ? label.name : null;
    }
}

class Subject {
    final Path outputPath;
    MemoryLocation[] memory;
    final Path basePath;
    final Stack<Integer> potentialCodeLocations = new Stack<>();
    String outputFileName = "deflowered.asm";
    final List<String> errors = new ArrayList<>();
    // The regions exported to binary files of their own (issue 0022).
    final List<ExportRegion> exports = new ArrayList<>();

    Subject(Path basePath) {
        this.basePath = basePath;
        this.outputPath = basePath.resolve("out");
        this.memory = new MemoryLocation[0x10000];
        for (int i = 0; i < memory.length; i++) {
            memory[i] = new MemoryLocation(i, 0, false);
        }
    }

    /**
     * Copies `bytes`, read from `source`, into memory from `startAddress`
     * on. Rejects an image that runs past $FFFF (issue 0014).
     */
    void storeAt(int startAddress, byte[] bytes, Path source) {
        assertState(startAddress + bytes.length <= memory.length,
                "%s: %d bytes loaded at %s run past $ffff", source, bytes.length, asHexWord(startAddress));
        for (int i = 0; i < bytes.length; i++) {
            memory[startAddress+i] = new MemoryLocation(startAddress + i, bytes[i] & 0xff, true);
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

    int longAt(int address) {
        return wordAt(address) + 256 * 256 * byteAt(address + 2);
    }

    int dwordAt(int address) {
        return wordAt(address) + 256 * 256 * wordAt(address + 2);
    }

    /**
     * Applies one {@code .flo} annotation line: its label and comment go
     * onto its address, a code entry becomes a place to start the flow
     * analysis from, and a data line registers one DataArea per element.
     * <p>
     * An included line (issue 0078) is weak, and must be applied after
     * the including file's own lines: its label and comment only go where
     * there are none yet, and an element that overlaps an area of the
     * including file is dropped.
     */
    void annotate(Annotation annotation) {
        int address = annotation.address;
        MemoryLocation location = memory[address];
        // An included comment describes the included label, so it only goes
        // where that label does.
        boolean weakLosesLabel = annotation.included && location.label != null && !location.label.included;
        if (annotation.name != null && (!annotation.included || location.label == null)) {
            location.label = new Label(annotation.name, false, annotation.included);
        }
        if (!annotation.comment.isEmpty() && !weakLosesLabel && (!annotation.included || location.comment.isEmpty())) {
            location.comment = annotation.comment;
            location.commentIncluded = annotation.included;
        }
        LineType type = annotation.type;
        if (type == LineType.UNKNOWN_LINE && annotation.addressEnd == null) {
            // No type and no size: just a label or comment for an address
            // (issue 0028), which can sit inside an area another line
            // declared, like a high score on the screen.
            if (annotation.virtual) {
                errors.add(String.format("Virtual address %s needs a type or a range", asHexWord(address)));
            }
            return;
        }
        switch (type) {
            case CODE_LINE -> {
                potentialCodeLocations.add(address);
                System.out.format("Will disassemble from %X\n", address);
            }
            case CHAR_LINE, BYTE_LINE, WORD_LINE, LONG_LINE, DWORD_LINE, ADDR_LINE, SBYTE_LINE, SWORD_LINE, SLONG_LINE, SDWORD_LINE, UNKNOWN_LINE -> {
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
                System.out.format("Marking area of %d %s at %X \"%s\"\n", amount, type.dataType.name().toLowerCase(), address, annotation.name);
                ExportRegion export = null;
                if (annotation.export != null) {
                    export = exportRegion(annotation.export, address, address + amount * type.dataType.sizeInBytes);
                    if (export == null) {
                        return;
                    }
                }
                for (int i = 0; i < amount; i++) {
                    DataArea area = new DataArea(address + i * type.dataType.sizeInBytes, type.dataType, annotation.virtual, annotation.name, i, annotation.included, export);
                    if (!annotation.included || !overlapsOwnArea(area)) {
                        registerArea(area);
                    }
                }
            }
            default -> throw new RuntimeException("No data type");
        }
    }

    /**
     * Registers the region from `start` to `end` (exclusive) for export to
     * `fileName` (issue 0022), or reports why it can't be: the file must
     * hold bytes the image loaded.
     */
    private ExportRegion exportRegion(String fileName, int start, int end) {
        if (end > memory.length) {
            errors.add(String.format("Exported %s at %s runs past $ffff", fileName, asHexWord(start)));
            return null;
        }
        for (int address = start; address < end; address++) {
            if (!memory[address].loaded) {
                errors.add(String.format("Exported %s at %s holds memory the image doesn't load, at %s", fileName, asHexWord(start), asHexWord(address)));
                return null;
            }
        }
        ExportRegion export = new ExportRegion(fileName, start, end);
        exports.add(export);
        return export;
    }

    /**
     * The contents of `export`'s file: the bytes as the image loaded them,
     * after the start address for a .prg file.
     */
    byte[] bytesOf(ExportRegion export) {
        int header = export.headerSize();
        byte[] bytes = new byte[header + export.end - export.start];
        if (header == 2) {
            bytes[0] = (byte) export.start;
            bytes[1] = (byte) (export.start >> 8);
        }
        for (int i = header; i < bytes.length; i++) {
            bytes[i] = (byte) byteAt(export.start + i - header);
        }
        return bytes;
    }

    boolean isVirtualAt(int address) {
        Area area = peek(address);
        return area != null && area.isVirtual();
    }

    /**
     * True when a label or comment is attached to `address`.
     */
    boolean isAnnotated(int address) {
        return memory[address].label != null || !memory[address].comment.isEmpty();
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
     * True when the run of data `area` is part of carries on at `address`:
     * an element of the same type, virtual or not like `area`, starts
     * there, and no label or comment interrupts the run.
     */
    boolean continuesRun(DataArea area, int address) {
        if (address >= memory.length || isAnnotated(address)) {
            return false;
        }
        Area next = peek(address);
        return next instanceof DataArea
                && next.address == address
                && ((DataArea) next).type == area.type
                && next.isVirtual() == area.isVirtual();
    }

    /**
     * True when the next element of the array `area` belongs to starts
     * at `address`. A label there doesn't interrupt the array's dump: it
     * is printed as an address define after the array (issue 0028). A
     * comment without a label still does.
     */
    boolean continuesArray(DataArea area, int address) {
        if (address >= memory.length || (!memory[address].comment.isEmpty() && memory[address].label == null)) {
            return false;
        }
        Area next = peek(address);
        return next != null
                && next.address == address
                && next.isVirtual() == area.isVirtual()
                && area.isInSameArray(next, area.indexInArray + 1);
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
            Integer first = firstAddressByLabel.putIfAbsent(location.label.name, location.address);
            if (first != null) {
                errors.add(String.format("Duplicate label %s at %s, already defined at %s", location.label.name, asHexWord(location.address), asHexWord(first)));
            }
        }
    }

    /**
     * True when part of `area` is already covered by an area that isn't
     * from an included file.
     */
    private boolean overlapsOwnArea(Area area) {
        for (int a = area.address; a < area.address + area.size && a < memory.length; a++) {
            Area existing = memory[a].area;
            if (existing != null && !(existing instanceof DataArea && ((DataArea) existing).included)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Drops what included files declared but nothing uses (issue 0078),
     * after the flow analysis: a virtual array without a name or that no
     * instruction operand or .addr value points into, and a label no
     * operand or .addr value prints. An included comment goes with its
     * label. Included areas still stopped the tracing before this.
     */
    void dropUnusedIncludes() {
        Set<Integer> targets = referencedAddresses();
        Set<Integer> usedArrays = new HashSet<>();
        for (int target : targets) {
            DataArea area = includedVirtualArea(target);
            if (area != null && area.arrayLabel != null) {
                usedArrays.add(area.arrayStart());
            }
        }
        for (int address = 0; address < memory.length; address++) {
            DataArea area = includedVirtualArea(address);
            if (area != null && !usedArrays.contains(area.arrayStart())) {
                memory[address].area = null;
            }
        }
        Set<Integer> labelAddresses = new HashSet<>();
        for (int target : targets) {
            Area area = peek(target);
            labelAddresses.add(area != null ? area.labelAddressFor(target, this) : target);
        }
        for (MemoryLocation location : memory) {
            Area area = location.area;
            boolean onIncludedArea = area instanceof DataArea && ((DataArea) area).included && !area.isVirtual();
            if (location.label != null && location.label.included && !onIncludedArea && !labelAddresses.contains(location.address)) {
                location.label = null;
            }
            if (location.commentIncluded && (location.label == null || !location.label.included) && !onIncludedArea) {
                location.comment = List.of();
                location.commentIncluded = false;
            }
        }
    }

    private DataArea includedVirtualArea(int address) {
        Area area = memory[address].area;
        return area instanceof DataArea && ((DataArea) area).included && area.isVirtual() ? (DataArea) area : null;
    }

    /**
     * Every address an instruction's operand names or a (not virtual)
     * .addr value holds.
     */
    private Set<Integer> referencedAddresses() {
        Set<Integer> targets = new HashSet<>();
        for (MemoryLocation location : memory) {
            Area area = location.area;
            if (area == null || area.address != location.address) {
                continue;
            }
            if (area instanceof InstructionArea) {
                int target = CrossReferences.target((InstructionArea) area, this);
                if (target != -1) {
                    targets.add(target);
                }
            } else if (area instanceof DataArea && ((DataArea) area).type == DataType.ADDR && !area.isVirtual()) {
                targets.add(wordAt(area.address));
            }
        }
        return targets;
    }

    void registerArea(Area area) {
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
            ensureLabelled(address, "l", true, referencingAddress);
        }
        // A placeholder may still turn out to be code (issue 0055).
        if (location.area == null || location.area.isPlaceholder()) {
            potentialCodeLocations.add(address);
        }
    }

    /**
     * A jsr target: code to trace, and the start of a routine, so its
     * label isn't local even when a branch or jmp labelled it first.
     */
    public void addCallTarget(int address, int referencingAddress) {
        addPotentialCodeLocation(address, true, referencingAddress);
        MemoryLocation location = memory[address];
        if (location.label.local) {
            location.label = new Label(location.label.name, false);
        }
    }

    public void ensureLabelled(int address, String contentHint, int referencedFromAddress) {
        ensureLabelled(address, contentHint, false, referencedFromAddress);
    }

    private void ensureLabelled(int address, String contentHint, boolean local, int referencedFromAddress) {
        MemoryLocation location = memory[address];
        if (location.label == null) {
            location.label = new Label(String.format("%s%04X", contentHint, address), local);
            System.out.println("Unnamed target: " + location.label.name + " from address " + asHexWord(referencedFromAddress));
        }
    }
}
