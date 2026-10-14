package com.laamella.deflower;

import com.laamella.mpu6502.specification.AddressingMode;
import com.laamella.mpu6502.specification.Opcode;

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
    // True when an included virtual area covered this byte but was dropped
    // as unused: still covered, not a gap (issue 0075).
    boolean droppedVirtual = false;
    // The name of what is banked in over the RAM here when a jsr, jmp or
    // branch goes here, and its comment lines (issue 0102), or null.
    Label banked = null;
    List<String> bankedComment = List.of();

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
    final Stack<CodeEntry> potentialCodeLocations = new Stack<>();
    String outputFileName = "deflowered.asm";
    final List<String> errors = new ArrayList<>();
    // Suspect spots, by address; they don't stop the output (issue 0077).
    final List<Warning> warnings = new ArrayList<>();
    // The regions exported to binary files of their own (issue 0022).
    final List<ExportRegion> exports = new ArrayList<>();
    // What the .flo code lines say about calls to their address, by that
    // address (issue 0068).
    final Map<Integer, Routine> routines = new HashMap<>();
    // The parameter names to print after each jsr whose inline data a
    // parameter list declared, by the jsr's address (issue 0068).
    final Map<Integer, String> callComments = new HashMap<>();
    // The jsr each call with inline data returns from, by the address it
    // returns to, after the data (issue 0068).
    final Map<Integer, Integer> callsByReturnAddress = new HashMap<>();
    // The address an address setup (issue 0074) builds, by the address of
    // the immediate load of its low byte, and of its high byte.
    final Map<Integer, Integer> lowByteSetups = new HashMap<>();
    final Map<Integer, Integer> highByteSetups = new HashMap<>();
    // The banked targets (issue 0102) a jsr, jmp, branch or rta goes to.
    final Set<Integer> usedBanked = new TreeSet<>();
    // The instructions that write or modify an instruction's operand
    // (issue 0106), by the address of the instruction they change.
    final Map<Integer, Set<Integer>> operandWriters = new HashMap<>();
    // The label a selfmod line (issue 0106) names, by the address of the
    // instruction, and the address of that label once it is found.
    final Map<Integer, String> selfModNames = new TreeMap<>();
    final Map<Integer, Integer> selfModLabels = new HashMap<>();

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
        if (annotation.banked) {
            annotateBanked(annotation, location);
            return;
        }
        if (annotation.selfMod) {
            // The including file's own lines come first.
            selfModNames.putIfAbsent(address, annotation.name);
            if (location.comment.isEmpty()) {
                location.comment = annotation.comment;
                location.commentIncluded = annotation.included;
            }
            return;
        }
        // An included comment describes the included label, so it only goes
        // where that label does. An included label with the banked name of
        // its address names the same routine in the ROM (issue 0102).
        boolean weakLosesLabel = annotation.included && (location.label != null && !location.label.included
                || insideOwnArea(address)
                || location.banked != null && location.banked.name.equals(annotation.name));
        if (annotation.name != null && (!annotation.included || location.label == null && !weakLosesLabel)) {
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
                potentialCodeLocations.add(new CodeEntry(address, -1, false));
                if (annotation.parameters != null || annotation.noReturn) {
                    // The included lines come last, so they don't replace
                    // what the including file says.
                    routines.putIfAbsent(address, new Routine(
                            annotation.parameters != null ? annotation.parameters : List.of(), annotation.noReturn));
                }
            }
            case SCREENCODE_LINE, ASCII_LINE, BYTE_LINE, WORD_LINE, LONG_LINE, DWORD_LINE, ADDR_LINE, RTA_LINE, SBYTE_LINE, SWORD_LINE, SLONG_LINE, SDWORD_LINE, UNKNOWN_LINE -> {
                int amount = annotation.addressEnd != null
                        ? (annotation.addressEnd - address) / type.dataType.sizeInBytes
                        : annotation.amount;
                if (annotation.addressEnd == null && annotation.terminator != null) {
                    amount = countUntil(address, type.dataType.sizeInBytes, annotation.terminator);
                    if (amount == -1) {
                        errors.add(String.format("No %s ending in $%02x at %s before memory the image doesn't load",
                                type.dataType.name().toLowerCase(), annotation.terminator, asHexWord(address)));
                        return;
                    }
                }
                if (annotation.addressEnd == null && annotation.lengthByte) {
                    if (!isLoaded(address, 1)) {
                        errors.add(String.format("No length byte for %s at %s: memory the image doesn't load",
                                type.dataType.name().toLowerCase(), asHexWord(address)));
                        return;
                    }
                    amount = 1 + byteAt(address);
                }
                if (amount <= 0) {
                    // Issue 0044: an empty array, or a range too short to
                    // hold one element (e.g. $c006-$c007 word: the end is
                    // exclusive), is a mistake, not a no-op.
                    errors.add(String.format("Zero-size %s at %s", type.dataType.name().toLowerCase(), asHexWord(address)));
                    return;
                }
                ExportRegion export = null;
                if (annotation.export != null) {
                    export = exportRegion(annotation.export, address, address + amount * type.dataType.sizeInBytes);
                    if (export == null) {
                        return;
                    }
                }
                int size = type.dataType.sizeInBytes;
                // Issue 0087: an element the image doesn't (fully) load is
                // virtual, so its bytes aren't printed as zeroes.
                List<String> unloaded = new ArrayList<>();
                int unloadedStart = -1;
                for (int i = 0; i < amount; i++) {
                    int elementAddress = address + i * size;
                    boolean loaded = isLoaded(elementAddress, size);
                    if (!loaded && !annotation.virtual && unloadedStart == -1) {
                        unloadedStart = elementAddress;
                    } else if (loaded && unloadedStart != -1) {
                        unloaded.add(asHexWord(unloadedStart) + "-" + asHexWord(elementAddress));
                        unloadedStart = -1;
                    }
                    DataArea area = new DataArea(elementAddress, type.dataType, annotation.virtual || !loaded, annotation.name, i, annotation.included, export, annotation.terminator, annotation.lengthByte);
                    if (!annotation.included || !overlapsOwnArea(area)) {
                        registerArea(area);
                        addReturnAddress(area);
                    }
                }
                if (unloadedStart != -1) {
                    unloaded.add(asHexWord(unloadedStart) + "-" + asHexWord(address + amount * size));
                }
                if (!unloaded.isEmpty() && !annotation.included) {
                    warn(address, String.format("%s%s: the image doesn't load %s, printed as virtual",
                            type.dataType.name().toLowerCase(), annotation.name == null ? "" : " " + annotation.name,
                            String.join(", ", unloaded)));
                }
            }
            default -> throw new RuntimeException("No data type");
        }
    }

    /**
     * Names what is banked in at the address for the flow that goes there
     * (issue 0102). An included one is weak: it loses to a banked line or
     * a code line of the including file at the same address.
     */
    private void annotateBanked(Annotation annotation, MemoryLocation location) {
        if (annotation.included && location.banked != null) {
            return;
        }
        location.banked = new Label(annotation.name, false, annotation.included);
        location.bankedComment = annotation.comment;
    }

    /**
     * Settles the banked names (issue 0102) after all lines are applied.
     * A label of the including file with the same name at the same
     * address, like a virtual KERNAL jump table of its own, already names
     * the routine, so an included banked name gives way. So does one at a
     * code line of the including file, which is an error next to a banked
     * line of its own.
     */
    void checkBankedCodeEntries() {
        for (MemoryLocation location : memory) {
            if (location.banked != null && location.banked.included && location.label != null
                    && !location.label.included && location.label.name.equals(location.banked.name)) {
                location.banked = null;
                location.bankedComment = List.of();
            }
        }
        for (CodeEntry entry : potentialCodeLocations) {
            MemoryLocation location = memory[entry.address];
            if (entry.from != -1 || location.banked == null) {
                continue;
            }
            if (location.banked.included) {
                location.banked = null;
                location.bankedComment = List.of();
            } else {
                errors.add(String.format("Banked %s at %s is also a code entry", location.banked.name, asHexWord(entry.address)));
            }
        }
    }

    /**
     * The target of the jsr, jmp or branch in `area` when a banked line
     * names it (issue 0102), or -1: the flow goes to what is banked in
     * there, not to the RAM.
     */
    int bankedTarget(InstructionArea area) {
        boolean flow = area.instruction.addressingMode == AddressingMode.RELATIVE
                || area.instruction.addressingMode == AddressingMode.ABSOLUTE
                && (area.instruction.opcode == Opcode.JSR || area.instruction.opcode == Opcode.JMP);
        int target = flow ? CrossReferences.target(area, this) : -1;
        return target != -1 && memory[target].banked != null ? target : -1;
    }

    /**
     * Traces where an rta element (issue 0038) returns to, as the start of
     * a routine: an rts dispatch table's entries are its handlers.
     */
    void addReturnAddress(DataArea area) {
        if (area.type == DataType.RTA && !area.isVirtual()) {
            addCallTarget(returnAddressAt(area.address), area.address);
        }
    }

    /**
     * The address an rts returns to through the rta value at `address`.
     */
    int returnAddressAt(int address) {
        return (wordAt(address) + 1) & 0xffff;
    }

    /**
     * The number of `elementSize`-byte elements from `address` on, up to
     * and including the first one that holds `terminator` (issue 0068), or
     * -1 when memory the image doesn't load comes first.
     */
    int countUntil(int address, int elementSize, int terminator) {
        for (int count = 1; isLoaded(address, elementSize); count++) {
            long value = 0;
            for (int i = elementSize - 1; i >= 0; i--) {
                value = value * 256 + byteAt(address + i);
            }
            if (value == terminator) {
                return count;
            }
            address += elementSize;
        }
        return -1;
    }

    /**
     * True when the image loaded all `size` bytes from `address` on.
     */
    private boolean isLoaded(int address, int size) {
        for (int a = address; a < address + size; a++) {
            if (a >= memory.length || !memory[a].loaded) {
                return false;
            }
        }
        return true;
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
     * Reports every label that is defined at more than one address (issue
     * 0043): the assembler would reject it, or code references would
     * resolve to the wrong one. Run after the flow analysis, so the
     * auto-generated labels are checked too.
     */
    void reportDuplicateLabels() {
        Map<String, Integer> firstAddressByLabel = new HashMap<>();
        for (MemoryLocation location : memory) {
            for (Label label : new Label[]{location.label, isPrintedBanked(location.address) ? location.banked : null}) {
                if (label == null) {
                    continue;
                }
                Integer first = firstAddressByLabel.putIfAbsent(label.name, location.address);
                if (first != null) {
                    errors.add(String.format("Duplicate label %s at %s, already defined at %s", label.name, asHexWord(location.address), asHexWord(first)));
                }
            }
        }
    }

    /**
     * True when the banked name at `address` (issue 0102) is printed: one
     * of the .flo file's own, or an included one the flow goes to.
     */
    boolean isPrintedBanked(int address) {
        Label banked = memory[address].banked;
        return banked != null && (!banked.included || usedBanked.contains(address));
    }

    /**
     * True when an area of the including file covers `address` but starts
     * before it, like the high byte of a word: an included name there
     * would replace the word's own name in the operands.
     */
    private boolean insideOwnArea(int address) {
        Area area = memory[address].area;
        return area != null && area.address != address && !(area instanceof DataArea && ((DataArea) area).included);
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
                memory[address].droppedVirtual = true;
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
        for (int built : lowByteSetups.values()) {
            if (bankedValueName(built) != null) {
                usedBanked.add(built);
            }
        }
        for (MemoryLocation location : memory) {
            Area area = location.area;
            if (area instanceof DataArea && ((DataArea) area).type == DataType.ADDR && area.address == location.address
                    && !area.isVirtual() && bankedValueName(wordAt(area.address)) != null) {
                usedBanked.add(wordAt(area.address));
            }
        }
    }

    /**
     * The label on `address` itself, or null, also for "label + offset".
     */
    String exactLabel(int address) {
        Area area = memory[address].area;
        String label = area == null ? memory[address].labelName() : area.labelFor(address, this);
        return label == null || label.contains(" ") ? null : label;
    }

    /**
     * The banked name for an address as a value (issue 0102): an .addr
     * value or what an address setup builds, like the KERNAL's IRQ handler
     * put in the IRQ vector. Null when there is none, or when the RAM has
     * a label on the address itself, which wins.
     */
    String bankedValueName(int address) {
        Label banked = memory[address].banked;
        return banked == null || exactLabel(address) != null ? null : banked.name;
    }

    /**
     * Warns about the untouched_ and unused_ ranges of an --init skeleton
     * that an instruction's operand names (issue 0103): they are virtual,
     * so a wrong one hides what the program uses there.
     */
    void warnUsedSkeletonRanges() {
        Map<Integer, Set<String>> users = new TreeMap<>();
        for (MemoryLocation location : memory) {
            Area area = location.area;
            if (!(area instanceof InstructionArea) || area.address != location.address) {
                continue;
            }
            int target = CrossReferences.target((InstructionArea) area, this);
            if (target == -1 || bankedTarget((InstructionArea) area) != -1 || operandModified(area.address)
                    || selfModLabels.containsKey(area.address)) {
                continue;
            }
            // An included label names what is really there, like a KERNAL
            // routine in the ROM over the RAM.
            Label label = memory[target].label;
            Area targetArea = memory[target].area;
            if (targetArea instanceof DataArea && isSkeletonRange((DataArea) targetArea)
                    && (label == null || !label.included)) {
                users.computeIfAbsent(((DataArea) targetArea).arrayStart(), a -> new LinkedHashSet<>())
                        .add(asHexWord(area.address));
            }
        }
        users.forEach((start, addresses) -> warn(start, String.format("%s is used by %s",
                ((DataArea) memory[start].area).arrayLabel, String.join(", ", addresses))));
    }

    /**
     * True when another instruction writes the operand of the instruction
     * at `address` (issue 0106), so it names nothing.
     */
    boolean operandModified(int address) {
        return operandWriters.containsKey(address);
    }

    private static boolean isSkeletonRange(DataArea area) {
        return area.isVirtual() && !area.included && area.arrayLabel != null
                && (area.arrayLabel.startsWith("untouched_") || area.arrayLabel.startsWith("unused_"));
    }

    private DataArea includedVirtualArea(int address) {
        Area area = memory[address].area;
        return area instanceof DataArea && ((DataArea) area).included && area.isVirtual() ? (DataArea) area : null;
    }

    /**
     * Every address an instruction's operand names, a (not virtual)
     * .addr value holds, an .rta value returns to, and the address an address setup builds when its
     * label would be on that address itself.
     */
    Set<Integer> referencedAddresses() {
        Set<Integer> targets = new HashSet<>();
        for (MemoryLocation location : memory) {
            Area area = location.area;
            if (area == null || area.address != location.address) {
                continue;
            }
            if (area instanceof InstructionArea) {
                int target = CrossReferences.target((InstructionArea) area, this);
                Integer named = selfModLabels.get(area.address);
                if (named != null) {
                    targets.add(named);
                } else if (target != -1 && bankedTarget((InstructionArea) area) == -1 && !operandModified(area.address)) {
                    targets.add(target);
                }
            } else if (area instanceof DataArea && ((DataArea) area).type == DataType.ADDR && !area.isVirtual()) {
                targets.add(wordAt(area.address));
            } else if (area instanceof DataArea && ((DataArea) area).type == DataType.RTA && !area.isVirtual()) {
                targets.add(returnAddressAt(area.address));
            }
        }
        for (int built : lowByteSetups.values()) {
            // Only a label on the address itself prints (issue 0034).
            Area area = peek(built);
            if (area == null || area.labelAddressFor(built, this) == built) {
                targets.add(built);
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

    /**
     * Code to trace at `address`, reached from the instruction at
     * `referencingAddress`. Pushed even onto memory an area covers, so the
     * analyser can warn about a jump into data or into the middle of an
     * instruction (issue 0077); it only decodes free memory and
     * placeholders (issue 0055).
     */
    public void addPotentialCodeLocation(int address, boolean labelIt, int referencingAddress) {
        if (labelIt && memory[address].banked != null) {
            // Something else is banked in there (issue 0102).
            usedBanked.add(address);
            return;
        }
        if (labelIt) {
            ensureLabelled(address, "l", true, referencingAddress);
        }
        potentialCodeLocations.add(new CodeEntry(address, referencingAddress, !labelIt));
    }

    void warn(int address, String text) {
        warnings.add(new Warning(address, text));
    }

    /**
     * A jsr target: code to trace, and the start of a routine, so its
     * label isn't local even when a branch or jmp labelled it first.
     */
    public void addCallTarget(int address, int referencingAddress) {
        addPotentialCodeLocation(address, true, referencingAddress);
        MemoryLocation location = memory[address];
        if (location.banked == null && location.label.local) {
            location.label = new Label(location.label.name, false);
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
    void labelDataReference(int target, int referencingAddress) {
        Area area = peek(target);
        boolean included = area instanceof DataArea && ((DataArea) area).included;
        if (area == null || included || area.labelFor(target, this) != null) {
            return;
        }
        ensureLabelled(target, "d", referencingAddress);
    }

    public void ensureLabelled(int address, String contentHint, int referencedFromAddress) {
        ensureLabelled(address, contentHint, false, referencedFromAddress);
    }

    private void ensureLabelled(int address, String contentHint, boolean local, int referencedFromAddress) {
        MemoryLocation location = memory[address];
        if (location.label == null) {
            location.label = new Label(String.format("%s%04X", contentHint, address), local);
        }
    }
}
