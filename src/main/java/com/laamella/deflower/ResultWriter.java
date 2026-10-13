package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

import java.io.IOException;
import java.io.Writer;
import java.util.ArrayList;
import java.util.List;
import java.util.Objects;

import static com.laamella.Printing.*;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.ByteManipulation.word;
import static java.lang.String.format;

class AssemblyFileFormat {
    private final LineEmitter out;
    private final CrossReferences crossReferences;
    private Area lastArea = null;
    boolean needsToReOrg = true;

    AssemblyFileFormat(Writer w, CrossReferences crossReferences) {
        this.out = new LineEmitter(w);
        this.crossReferences = crossReferences;
    }

    /**
     * Prints a comment (one output line per source line, each prefixed
     * "; ", followed by the label's cross-references), a label (as
     * "label:"), both, or neither, for the given address. Comment and
     * label share one blank-line separator above them, so a commented
     * label doesn't get a blank line wedged between the comment and the
     * label it belongs to.
     * <p>
     * Exception (issue 0027): when this address merely continues the same
     * contiguous same-type data run as the address before it, skip the
     * blank-line separator and put the label/comment on its own line
     * instead. (A label inside one array doesn't get here at all: it is
     * printed as an address define after the array, issue 0028.)
     * <p>
     * Within that, whether the label's own line glues onto its data or
     * gets its own line (issue 0029) depends on how much data actually
     * follows before the run breaks again: a single value glues (reads
     * fine on one line), several values get their own line so the
     * tabular dump underneath stays readable.
     */
    void printAnnotation(int address, String label, Area currentArea, Subject subject) throws IOException {
        boolean afterOrigin = needsToReOrg;
        considerReOrg(address);
        // Same kind of data as whatever was printed right before this
        // address: print(DataArea, ...) below won't insert its own
        // newline for that case (it only breaks on a kind change), so
        // this method is the one responsible for any line break between
        // the label and its data.
        boolean sameKindAsPrevious = currentArea instanceof DataArea
                && lastArea instanceof DataArea
                && ((DataArea) lastArea).type == ((DataArea) currentArea).type;
        boolean continuesRun = sameKindAsPrevious && lastArea.lastOccupiedAddress == address - 1;
        // Issue 0073: execution falls through from the instruction before
        // into the code at this label, so no blank line suggests a break
        // in the flow. A label on data keeps its blank line.
        boolean fallsThrough = !afterOrigin && currentArea instanceof InstructionArea
                && lastArea instanceof InstructionArea && !((InstructionArea) lastArea).endsFlow();
        if (continuesRun || fallsThrough) {
            out.finishLine();
        } else {
            // finishLine() closes whatever line is still dangling (if
            // any); newLine() adds the actual blank-line separator. When
            // the previous line was already cleanly closed (e.g. by the
            // forced newline below, for a label with nothing of its own
            // to print), finishLine() skips emitting a second, needless
            // blank line.
            out.finishLine();
            out.newLine();
        }
        printCommentLines(address, subject);
        if (label != null) {
            out.print(label + ":");
            if (sameKindAsPrevious && !isSingleValueRun(address, (DataArea) currentArea, subject)) {
                // Issue 0029: among same-kind labels, glue a single value
                // onto the label's line; several values get their own line
                // so the tabular dump underneath stays readable. A label
                // that starts a genuinely new kind of area always gets its
                // own line - print(DataArea, ...)'s own kind-change check
                // already does that, so doing it again here would double
                // the newline.
                out.newLine();
            }
        }
        if (lastArea instanceof InstructionArea) {
            // The instruction after this label isn't right after a flow
            // end anymore: printInstruction needs no blank line of its own.
            lastArea = null;
        }
    }

    /**
     * True when printing `area` at `address` produces just one value
     * before the run breaks (the next address has its own label/comment,
     * isn't the same kind of data, or isn't there at all) - the case
     * where gluing the label onto its one data value (issue 0029) reads
     * better than putting the label on its own line.
     */
    private boolean isSingleValueRun(int address, DataArea area, Subject subject) {
        return !subject.continuesArray(area, address + area.size);
    }

    /**
     * Prints the labels at `addresses` as address defines (issue 0028),
     * each after its comment lines. The last define's line is left open,
     * like any other printed content, for whatever prints next to close;
     * forgetting the last area makes the next data start a fresh line.
     */
    void printDefines(List<Integer> addresses, Subject subject) throws IOException {
        if (!addresses.isEmpty()) {
            lastArea = null;
        }
        for (int address : addresses) {
            out.finishLine();
            printCommentLines(address, subject);
            String label = subject.memory[address].labelName();
            if (label != null) {
                out.print(label + " = " + asHexWord(address));
            }
        }
    }

    /**
     * Prints a stretch of consecutive virtual areas (issue 0046) as one
     * 64tass {@code .virtual} block: memory the code uses but whose
     * contents aren't part of the program. Nothing is emitted for it, but
     * its labels, type and size survive as reservations - {@code .byte ?}
     * for a single value, {@code .fill n} for a run of same-type elements -
     * so references like {@code screen_ram + $50} still assemble.
     *
     * @return the first address after the stretch
     */
    int printVirtualStretch(int start, Subject subject) throws IOException {
        out.finishLine();
        out.newLine();
        out.print(".virtual " + asHexWord(start));
        out.newLine();
        int address = start;
        while (address < subject.memory.length && subject.isVirtualAt(address)) {
            DataArea area = (DataArea) subject.peek(address);
            String label = subject.memory[address].labelName();
            printCommentLines(address, subject);
            if (address != area.address) {
                // A label landing inside a multi-byte element (the second
                // byte of a word): no reservation of its own to hang it on.
                if (label != null) {
                    out.print(label + " = " + asHexWord(address));
                    out.newLine();
                }
                address++;
                continue;
            }
            int end = subject.endOfRun(area);
            int count = (end - address) / area.size;
            if (label != null) {
                out.print(label + ":");
            }
            if (count == 1) {
                out.indent();
                out.print(reservationDirective(area.type) + "\t?");
            } else {
                if (label != null) {
                    out.newLine();
                }
                out.indent();
                out.print(".fill\t" + (end - address));
            }
            out.newLine();
            address = subject.firstAnnotatedAddressInside(address, end);
        }
        out.print(".endv");
        out.newLine();
        needsToReOrg = true;
        lastArea = null;
        return address;
    }

    /**
     * Prints a region exported to a binary file (issue 0022) as a 64tass
     * {@code .binary} line, skipping a .prg file's load address, after the
     * label and comment at its start. The
     * labels inside it become address defines after it.
     *
     * @return the first address after the region
     */
    int printExport(ExportRegion export, Subject subject) throws IOException {
        considerReOrg(export.start);
        out.finishLine();
        out.newLine();
        printCommentLines(export.start, subject);
        String label = subject.memory[export.start].labelName();
        if (label != null) {
            out.print(label + ":");
            out.newLine();
        }
        out.indent();
        out.print(".binary\t\"" + export.fileName + "\"" + (export.headerSize() != 0 ? ", " + export.headerSize() : ""));
        lastArea = null;
        List<Integer> inside = new ArrayList<>();
        for (int address = export.start + 1; address < export.end; address++) {
            if (subject.isAnnotated(address)) {
                inside.add(address);
            }
        }
        printDefines(inside, subject);
        return export.end;
    }

    private static String reservationDirective(DataType type) {
        return switch (type) {
            case BYTE, UNKNOWN, SCREENCODE, ASCII -> ".byte";
            case WORD -> ".word";
            case LONG -> ".long";
            case DWORD -> ".dword";
            case ADDR -> ".addr";
            case RTA -> ".rta";
            case SBYTE -> ".char";
            case SWORD -> ".sint";
            case SLONG -> ".lint";
            case SDWORD -> ".dint";
        };
    }

    /**
     * Prints the comment at `address` and the cross-references to its
     * label (issue 0076), one "; " line each.
     */
    private void printCommentLines(int address, Subject subject) throws IOException {
        List<String> lines = new ArrayList<>(subject.memory[address].comment);
        lines.addAll(crossReferences.linesFor(address));
        for (String line : lines) {
            out.print("; " + line);
            out.newLine();
        }
    }

    public void print(DataArea area, int address, Subject subject) throws IOException {
        // A multi-byte area (WORD, LONG, DWORD, ADDR, ...) owns several consecutive
        // addresses but is one value: print it once, at its first address.
        if (address != area.address) {
            return;
        }
        considerReOrg(address);
        if ((!(lastArea instanceof DataArea)) || area.type != ((DataArea) lastArea).type) {
            out.newLine();
        }
        switch (area.type) {
            case BYTE, UNKNOWN:
                tabularPrint(".byte", asHexByte(subject.byteAt(address)));
                break;
            case SCREENCODE, ASCII:
                textPrint(area, subject.byteAt(address), subject);
                break;
            case WORD:
                tabularPrint(".word", asHexWord(subject.wordAt(address)));
                break;
            case LONG:
                tabularPrint(".long", asHexLong(subject.longAt(address)));
                break;
            case DWORD:
                tabularPrint(".dword", asHexDword(subject.dwordAt(address)));
                break;
            case ADDR:
                // 64tass's .addr is specifically "a 16-bit address constant"
                // (issue 0036) - more precise than .WORD for a value that's
                // always an address, not an arbitrary 16-bit number.
                tabularPrint(".addr", nameForAddress(subject.wordAt(address), "$%04x", subject));
                break;
            case RTA:
                // 64tass stores the label minus one (issue 0038).
                tabularPrint(".rta", nameForAddress(subject.returnAddressAt(address), "$%04x", subject));
                break;
            case SBYTE:
                tabularPrint(".char", Integer.toString((byte) subject.byteAt(address)));
                break;
            case SWORD:
                tabularPrint(".sint", Integer.toString((short) subject.wordAt(address)));
                break;
            case SLONG:
                // Sign-extend the 24-bit value.
                tabularPrint(".lint", Integer.toString(subject.longAt(address) << 8 >> 8));
                break;
            case SDWORD:
                tabularPrint(".dint", Integer.toString(subject.dwordAt(address)));
                break;
        }
        lastArea = area;
    }

    private static final int TEXT_BYTES_PER_LINE = 32;

    // The 64tass text encoding in effect at this point of the output;
    // "none" is 64tass's own default.
    private String encoding = "none";

    // The text array being printed (the elements one .flo line
    // declared), as an address range.
    private int textArrayStart = -1;
    private int textArrayEnd = -1;

    // The directive of the .text, .null or .ptext line being printed.
    private String textDirective = ".text";
    // True right after a .ptext line was opened on its length byte, which
    // prints nothing: the next character goes onto that same line.
    private boolean ptextOpened = false;

    /**
     * Prints one text value as an item of a 64tass {@code .text} line
     * (issue 0039), the string counterpart of tabularPrint: consecutive
     * printable characters share one double-quoted literal, anything else
     * becomes a hex item, e.g. {@code .text "AB", $0D, "C"}. Wraps every
     * TEXT_BYTES_PER_LINE values.
     * <p>
     * A screencode value is read as a Commodore screen code, an ascii one
     * as Commodore ASCII (issue 0094). A line opening under a different
     * encoding than the one in effect first switches it with {@code .enc},
     * so the output reassembles to the same bytes; the next array in
     * another encoding starts a new line.
     * <p>
     * An array sized by [until $00] ends in a {@code .null} line, and one
     * sized by [lengthbyte] is a {@code .ptext} ({@link #textDirectiveFor});
     * the terminator and the length byte then print as nothing.
     */
    private void textPrint(DataArea area, int value, Subject subject) throws IOException {
        boolean newArray = area.address < textArrayStart || area.address >= textArrayEnd;
        if (newArray) {
            textArrayStart = area.arrayStart();
            textArrayEnd = subject.endOfArray(area);
        }
        String valueEncoding = area.type == DataType.SCREENCODE ? "screen" : "none";
        boolean continuesPtext = ptextOpened;
        ptextOpened = false;
        // A .ptext string can't be split, so it makes one long line. A
        // .null or .ptext line holds one array, which then opens its own.
        boolean wraps = !textDirective.equals(".ptext");
        boolean ownLine = newArray && (!textDirective.equals(".text") || area.lengthByte || Integer.valueOf(0).equals(area.terminator));
        if ((wraps && out.column() == TEXT_BYTES_PER_LINE) || (out.column() != 0 && (ownLine || !valueEncoding.equals(encoding)))) {
            out.newLine();
        }
        if (out.column() == 0 && !continuesPtext) {
            if (!valueEncoding.equals(encoding)) {
                out.indent();
                out.print(".enc\t\"" + valueEncoding + "\"");
                out.newLine();
                encoding = valueEncoding;
            }
            textDirective = textDirectiveFor(area, subject);
            out.indent();
            out.print(textDirective + "\t");
            if (textDirective.equals(".ptext")) {
                if (textArrayEnd == area.address + 1) {
                    out.print("\"\"");
                    out.newLine();
                    return;
                }
                ptextOpened = true;
                return;
            }
        }
        if (textDirective.equals(".null") && area.address == textArrayEnd - 1) {
            return;
        }
        int character = characterFor(valueEncoding, value);
        if (character != -1) {
            out.quotedCharacter((char) character);
        } else {
            out.item(asHexByte(value));
        }
    }

    /**
     * The directive for a line of the current text array opening at
     * `area` (issue 0094): {@code .ptext} at the start of an array sized
     * by [lengthbyte], however long; {@code .null} for the line that ends
     * an array sized by [until $00], when the rest of the array fits on
     * the line; else {@code .text}. A comment inside the rest of the array
     * would break the line, so it rules both out.
     */
    private String textDirectiveFor(DataArea area, Subject subject) {
        int address = area.address;
        for (int inside = address + 1; inside < textArrayEnd; inside++) {
            if (!subject.memory[inside].comment.isEmpty() && subject.memory[inside].label == null) {
                return ".text";
            }
        }
        if (area.lengthByte) {
            return address == textArrayStart ? ".ptext" : ".text";
        }
        if (Integer.valueOf(0).equals(area.terminator) && textArrayEnd - textArrayStart >= 2) {
            return textArrayEnd - 1 - address <= TEXT_BYTES_PER_LINE ? ".null" : ".text";
        }
        return ".text";
    }

    /**
     * The character `value` is written as in a string under 64tass's
     * `encoding` in its default raw mode (no {@code --ascii}), or -1 when
     * there is none and it must be printed as hex. "none" is the identity;
     * "screen" maps screen codes $00-$1F to "@A-Z[\]^_", $20-$3F to
     * themselves and $40-$5E to "`a-z{|}~" (checked against 64tass 1.59).
     * Reverse video ($80-$FF), $5F-$7F and the double quote, which would
     * end the literal, have none.
     */
    private static int characterFor(String encoding, int value) {
        int character = value;
        if (encoding.equals("screen")) {
            if (value <= 0x1F) {
                character = value + 0x40;
            } else if (value >= 0x40 && value <= 0x5E) {
                character = value + 0x20;
            } else if (value > 0x3F) {
                return -1;
            }
        }
        return character >= 0x20 && character <= 0x7E && character != '"' ? character : -1;
    }

    void close() throws IOException {
        out.close();
    }

    private void considerReOrg(int address) throws IOException {
        if (needsToReOrg) {
            out.newLine();
            out.print("*=" + asHexWord(address));
            needsToReOrg = false;
        }
    }

    private void tabularPrint(String command, String data) throws IOException {
        if (out.column() == 16) {
            out.newLine();
        }

        if (out.column() == 0) {
            out.indent();
            out.print(command + "\t");
        }
        out.item(data);
    }

    public void printInstruction(InstructionArea area, Subject subject) throws IOException {
        boolean afterOrigin = needsToReOrg;
        considerReOrg(area.address);
        if (Objects.equals(area, lastArea)) {
            return;
        }
        if (!afterOrigin && lastArea instanceof InstructionArea && ((InstructionArea) lastArea).endsFlow()) {
            // Issue 0073: code right after a jmp, rts, rti or brk is only
            // reached some other way, so set it apart like a label there.
            out.finishLine();
            out.newLine();
        }
        Instruction instruction = area.instruction;
        int byte1 = subject.memory[area.address + 1].data;
        int byte2 = subject.memory[area.address + 2].data;
        int word = word(byte1, byte2);
        String operand = switch (instruction.addressingMode) {
            case IND_X -> format("(%s, x)", nameForAddress(byte1, "$%02x", subject));
            case IND_Y -> format("(%s), y", nameForAddress(byte1, "$%02x", subject));
            case RELATIVE -> format("%s", nameForAddress(area.address + toSignedByte(byte1) + 2, "$%04x", subject));
            case INDIRECT -> format("(%s)", nameForAddress(word, "$%04x", subject));
            case ABSOLUTE -> format("%s", nameForAbsoluteAddress(word, subject));
            case ABSOLUTE_X -> format("%s, x", nameForAbsoluteAddress(word, subject));
            case ABSOLUTE_Y -> format("%s, y", nameForAbsoluteAddress(word, subject));
            case IMMEDIATE -> format("#%s", nameForImmediate(area.address, byte1, subject));
            case ZERO_PAGE -> format("%s", nameForAddress(byte1, "$%02x", subject));
            case ZERO_PAGE_X -> format("%s, x", nameForAddress(byte1, "$%02x", subject));
            case ZERO_PAGE_Y -> format("%s, y", nameForAddress(byte1, "$%02x", subject));
            case JAM, ACCUMULATOR, NONE -> "";
        };
        // A comment or label right above has already closed its line.
        out.finishLine();
        out.indent();
        out.print(instruction.opcode.name().toLowerCase());
        out.print(" ");
        out.print(operand);
        String callComment = subject.callComments.get(area.address);
        if (callComment != null) {
            // The names of the inline data after this jsr (issue 0068).
            out.print("\t; " + callComment);
        }

        lastArea = area;
    }

    /**
     * An immediate operand. The low or high byte of an address an address
     * setup builds (issue 0074) is named `<label` or `>label` (issue
     * 0034), but only for a label on that address itself: 64tass reads
     * `<label + 1` as the low byte of the sum, mpu6502 as the low byte of
     * the label plus one.
     */
    private String nameForImmediate(int address, int value, Subject subject) {
        Integer low = subject.lowByteSetups.get(address);
        Integer high = subject.highByteSetups.get(address);
        Integer built = low != null ? low : high;
        if (built != null) {
            String label = exactLabel(built, subject);
            if (label != null) {
                return (low != null ? "<" : ">") + label;
            }
        }
        return format("$%02x", value);
    }

    /**
     * The label on `address` itself, or null, also for "label + offset".
     */
    private String exactLabel(int address, Subject subject) {
        Area area = subject.memory[address].area;
        String label = area == null ? subject.memory[address].labelName() : area.labelFor(address, subject);
        return label == null || label.contains(" ") ? null : label;
    }

    /**
     * An absolute-mode operand. Below $100, 64tass would pick the shorter
     * zero-page form, label or number alike, so `@w` forces the 16-bit
     * one (issue 0053).
     */
    private String nameForAbsoluteAddress(int address, Subject subject) {
        String name = nameForAddress(address, "$%04x", subject);
        return address < 0x100 ? "@w " + name : name;
    }

    private String nameForAddress(int address, String formatWhenNumeric, Subject subject) {
        Area area = subject.memory[address].area;
        if (area == null) {
            // Memory no area covers can still carry a label: a user label,
            // or a jump target whose instruction couldn't be decoded.
            String label = subject.memory[address].labelName();
            return label != null ? label : String.format(formatWhenNumeric, address);
        }
        String label = area.labelFor(address, subject);
        if (label == null) {
            return String.format(formatWhenNumeric, address);
        }
        return label;
    }
}

class ResultWriter {

    /**
     * Labels that would interrupt what is being printed become address
     * defines instead (issue 0028): a label inside a declared array,
     * inside a multi-byte element or on an instruction's operand byte is
     * printed as {@code label = $XXXX} after the array or instruction, so
     * its dump stays unbroken and the label still gets its exact address. A label
     * on memory no area covers is printed as a define in place, instead
     * of an origin block with nothing in it.
     */
    void write(Subject subject, Writer w) throws IOException {
        AssemblyFileFormat assemblyFile = new AssemblyFileFormat(w, new CrossReferences(subject));
        List<Integer> deferred = new ArrayList<>();
        for (int address = 0; address < 0x10000; address++) {

            Area currentArea = subject.peek(address);
            if (!continuesPrevious(currentArea, address, subject)) {
                assemblyFile.printDefines(deferred, subject);
                deferred.clear();
            }

            if (currentArea != null && currentArea.isVirtual()) {
                // The loop's own address++ then lands on the first
                // address after the stretch.
                address = assemblyFile.printVirtualStretch(address, subject) - 1;
                continue;
            }

            if (currentArea instanceof DataArea && ((DataArea) currentArea).export != null) {
                address = assemblyFile.printExport(((DataArea) currentArea).export, subject) - 1;
                continue;
            }

            // Is there a comment or a label here? Print them.
            if (subject.isAnnotated(address)) {
                if (currentArea == null) {
                    assemblyFile.printDefines(List.of(address), subject);
                } else if (continuesPrevious(currentArea, address, subject)) {
                    deferred.add(address);
                } else {
                    assemblyFile.printAnnotation(address, subject.memory[address].labelName(), currentArea, subject);
                }
            }
            if (currentArea != null) {
                if (currentArea instanceof DataArea) {
                    assemblyFile.print((DataArea) currentArea, address, subject);
                } else if (currentArea instanceof InstructionArea) {
                    InstructionArea instructionArea = (InstructionArea) currentArea;
                    assemblyFile.printInstruction(instructionArea, subject);
                }
            } else {
                assemblyFile.needsToReOrg = true;
            }

        }
        assemblyFile.printDefines(deferred, subject);
        assemblyFile.close();
    }

    /**
     * True when `address` carries on what the address before it printed:
     * it lies inside the same area (a multi-byte element, an instruction's
     * operand), or starts the next element of the same array.
     */
    private static boolean continuesPrevious(Area area, int address, Subject subject) {
        if (area == null || address == 0) {
            return false;
        }
        Area previous = subject.peek(address - 1);
        if (area == previous) {
            return true;
        }
        return previous instanceof DataArea && subject.continuesArray((DataArea) previous, address);
    }
}
