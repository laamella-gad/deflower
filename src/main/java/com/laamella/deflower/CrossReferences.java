package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;
import com.laamella.mpu6502.specification.Opcode;

import java.util.ArrayList;
import java.util.EnumMap;
import java.util.EnumSet;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import static com.laamella.Printing.asHexWord;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.ByteManipulation.word;
import static com.laamella.mpu6502.specification.Opcode.*;

/**
 * Which instructions refer to each label (issue 0076), printed as comment
 * lines above it: "called by: game_loop, l336F". A reference is listed at
 * the label its operand prints, so one into an array is listed at the
 * array's label. The referrer is named by the nearest routine label at or
 * before its instruction, skipping local labels (issue 0084), each once
 * per kind, and a label referring to itself (a loop back to its own
 * start) is left out.
 */
class CrossReferences {
    enum Kind {
        CALL("called by"),
        JUMP("jumped to by"),
        READ("read by"),
        WRITE("written by"),
        MODIFY("modified by");

        final String heading;

        Kind(String heading) {
            this.heading = heading;
        }
    }

    private static final Set<Opcode> WRITES = EnumSet.of(STA, STX, STY, SAX, AHX, SHX, SHY, TAS);
    private static final Set<Opcode> MODIFIES = EnumSet.of(INC, DEC, ASL, LSR, ROL, ROR, SLO, RLA, SRE, RRA, DCP, ISC);

    private final Map<Integer, Map<Kind, Set<String>>> referrersByLabelAddress = new HashMap<>();

    CrossReferences(Subject subject) {
        for (MemoryLocation location : subject.memory) {
            if (location.area instanceof InstructionArea && location.area.address == location.address) {
                add((InstructionArea) location.area, subject);
            }
        }
    }

    /**
     * The comment lines listing the references to the label at `address`,
     * one per kind, or none.
     */
    List<String> linesFor(int address) {
        List<String> lines = new ArrayList<>();
        Map<Kind, Set<String>> referrers = referrersByLabelAddress.get(address);
        if (referrers != null) {
            referrers.forEach((kind, names) -> lines.add(kind.heading + ": " + String.join(", ", names)));
        }
        return lines;
    }

    private void add(InstructionArea area, Subject subject) {
        int target = target(area, subject);
        if (target == -1) {
            return;
        }
        Area targetArea = subject.peek(target);
        int labelAddress = targetArea != null
                ? targetArea.labelAddressFor(target, subject)
                : subject.memory[target].label != null ? target : -1;
        int referrerAddress = referrerAddress(area, subject);
        if (labelAddress == -1 || labelAddress == referrerAddress) {
            return;
        }
        String referrer = referrerAddress != -1 ? subject.memory[referrerAddress].labelName() : asHexWord(area.address);
        referrersByLabelAddress
                .computeIfAbsent(labelAddress, a -> new EnumMap<>(Kind.class))
                .computeIfAbsent(kind(area.instruction), k -> new LinkedHashSet<>())
                .add(referrer);
    }

    /**
     * The address the operand of the instruction in `area` names, or -1
     * for an instruction without one. For an indirect mode that is the
     * pointer, not where it points.
     */
    private static int target(InstructionArea area, Subject subject) {
        int byte1 = subject.byteAt(area.address + 1);
        return switch (area.instruction.addressingMode) {
            case ZERO_PAGE, ZERO_PAGE_X, ZERO_PAGE_Y, IND_X, IND_Y -> byte1;
            case ABSOLUTE, ABSOLUTE_X, ABSOLUTE_Y, INDIRECT -> word(byte1, subject.byteAt(area.address + 2));
            case RELATIVE -> area.address + toSignedByte(byte1) + 2;
            case IMMEDIATE, JAM, ACCUMULATOR, NONE -> -1;
        };
    }

    /**
     * What the instruction does with the address its operand names. An
     * indirect mode only reads the pointer there, whatever the instruction
     * does with the memory it points to.
     */
    private static Kind kind(Instruction instruction) {
        Opcode opcode = instruction.opcode;
        switch (instruction.addressingMode) {
            case IND_X, IND_Y, INDIRECT -> {
                return Kind.READ;
            }
            case RELATIVE -> {
                return Kind.JUMP;
            }
        }
        if (opcode == JSR) {
            return Kind.CALL;
        }
        if (opcode == JMP) {
            return Kind.JUMP;
        }
        if (WRITES.contains(opcode)) {
            return Kind.WRITE;
        }
        if (MODIFIES.contains(opcode)) {
            return Kind.MODIFY;
        }
        return Kind.READ;
    }

    /**
     * The address of the nearest routine label at or before the
     * instruction in `area`, looking back through the instructions right
     * before it, or -1 when that code has none.
     */
    private static int referrerAddress(InstructionArea area, Subject subject) {
        Area current = area;
        while (true) {
            MemoryLocation location = subject.memory[current.address];
            if (location.label != null && !location.label.local) {
                return current.address;
            }
            Area previous = current.address > 0 ? subject.peek(current.address - 1) : null;
            if (!(previous instanceof InstructionArea)) {
                return -1;
            }
            current = previous;
        }
    }
}
