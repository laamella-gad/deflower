package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

import java.io.IOException;
import java.io.Writer;
import java.util.Objects;

import static com.laamella.Printing.*;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.ByteManipulation.word;
import static java.lang.String.format;

class AssemblyFileFormat {
    private final LineEmitter out;
    private Area lastArea = null;
    boolean needsToReOrg = true;

    AssemblyFileFormat(Writer w) {
        this.out = new LineEmitter(w);
    }

    /**
     * Prints a comment (one output line per source line, each prefixed
     * "; "), a label (as "label:"), both, or neither, for the given
     * address. Comment and label share one blank-line separator above
     * them, so a commented label doesn't get a blank line wedged between
     * the comment and the label it belongs to.
     * <p>
     * Exception (issue 0027): when this address merely continues the same
     * contiguous same-type data run as the address before it, skip the
     * blank-line separator and put the label/comment on its own line
     * instead, so a label landing inside a big array doesn't fragment it
     * into separate .BYTE groups.
     * <p>
     * Within that, whether the label's own line glues onto its data or
     * gets its own line (issue 0029) depends on how much data actually
     * follows before the run breaks again: a single value glues (reads
     * fine on one line), several values get their own line so the
     * tabular dump underneath stays readable.
     */
    void printAnnotation(int address, String comment, String label, Area currentArea, Subject subject) throws IOException {
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
        if (continuesRun) {
            if (out.column() != 0) {
                out.newLine();
            }
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
        printCommentLines(comment);
        if (label != null) {
            out.print(label + ":");
            // A label can land on an address that's covered by an area but
            // isn't where that area actually prints anything - the second
            // byte of a WORD/DWORD, an instruction's operand byte - because
            // print(DataArea, ...) and printInstruction() only emit output
            // at an area's own start address. There, nothing follows this
            // label from the area it names, so it must get its own line
            // unconditionally: gluing it to whatever unrelated address's
            // label/comment happens to print right after it is a bug, not
            // a glue. An address with no area at all is unaffected - the
            // next thing printed always starts with its own considerReOrg
            // or print call, which supplies the missing newline itself.
            boolean labelInsideAreaButNotAtItsStart = currentArea != null && currentArea.address != address;
            if (labelInsideAreaButNotAtItsStart) {
                out.newLine();
            } else if (sameKindAsPrevious && !isSingleValueRun(address, (DataArea) currentArea, subject)) {
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
    }

    /**
     * True when printing `block` at `address` produces just one value
     * before the run breaks (the next address has its own label/comment,
     * isn't the same kind of data, or isn't there at all) - the case
     * where gluing the label onto its one data value (issue 0029) reads
     * better than putting the label on its own line.
     */
    private boolean isSingleValueRun(int address, DataArea block, Subject subject) {
        return !subject.continuesRun(block, address + block.size);
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
            DataArea block = (DataArea) subject.peek(address);
            String comment = subject.memory[address].comment;
            String label = subject.memory[address].label;
            printCommentLines(comment);
            if (address != block.address) {
                // A label landing inside a multi-byte element (the second
                // byte of a word): no reservation of its own to hang it on.
                if (label != null) {
                    out.print(label + " = " + asHexWord(address));
                    out.newLine();
                }
                address++;
                continue;
            }
            int end = subject.endOfRun(block);
            int count = (end - address) / block.size;
            if (label != null) {
                out.print(label + ":");
            }
            if (count == 1) {
                out.indent();
                out.print(reservationDirective(block.type) + "\t?");
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

    private static String reservationDirective(DataType type) {
        return switch (type) {
            case BYTE, UNKNOWN, CHAR -> ".byte";
            case WORD -> ".word";
            case DWORD -> ".dword";
            case POINTER -> ".addr";
        };
    }

    private void printCommentLines(String comment) throws IOException {
        if (comment != null) {
            for (String line : comment.split("\n", -1)) {
                out.print("; " + line);
                out.newLine();
            }
        }
    }

    public void print(DataArea block, int address, Subject subject) throws IOException {
        // A multi-byte area (WORD, DWORD, POINTER) owns several consecutive
        // addresses but is one value: print it once, at its first address.
        if (address != block.address) {
            return;
        }
        considerReOrg(address);
        if ((!(lastArea instanceof DataArea)) || block.type != ((DataArea) lastArea).type) {
            out.newLine();
        }
        switch (block.type) {
            case BYTE, UNKNOWN:
                tabularPrint(".byte", asHexByte(subject.byteAt(address)));
                break;
            case CHAR:
                textPrint(block, subject.byteAt(address), subject);
                break;
            case WORD:
                tabularPrint(".word", asHexWord(subject.wordAt(address)));
                break;
            case DWORD:
                tabularPrint(".dword", asHexDword(subject.dwordAt(address)));
                break;
            case POINTER:
                // 64tass's .addr is specifically "a 16-bit address constant"
                // (issue 0036) - more precise than .WORD for a value that's
                // always an address, not an arbitrary 16-bit number.
                tabularPrint(".addr", nameForAddress(subject.wordAt(address), "$%04X", subject));
                break;
        }
        lastArea = block;
    }

    private static final int TEXT_BYTES_PER_LINE = 32;

    // The 64tass text encoding in effect at this point of the output;
    // "none" is 64tass's own default.
    private String encoding = "none";

    // The declared char array the encoding was last chosen for, as an
    // address range, so it's chosen once per array, not once per value.
    private int encodingArrayStart = -1;
    private int encodingArrayEnd = -1;
    private String arrayEncoding = "none";

    /**
     * Prints one CHAR value as an item of a 64tass {@code .text} line
     * (issue 0039), the string counterpart of tabularPrint: consecutive
     * printable characters share one double-quoted literal, anything else
     * becomes a hex item, e.g. {@code .text "AB", $0D, "C"}. Wraps every
     * TEXT_BYTES_PER_LINE values.
     * <p>
     * The value is read as ASCII or as Commodore screen codes, whichever
     * suits its declared array better (issue 0040, {@link #encodingFor}).
     * A line opening under a different encoding than the one in effect
     * first switches it with {@code .enc}, so the output reassembles to the
     * same bytes; an array changing encoding mid-line starts a new line.
     */
    private void textPrint(DataArea block, int value, Subject subject) throws IOException {
        String valueEncoding = encodingFor(block, subject);
        if (out.column() == TEXT_BYTES_PER_LINE || (out.column() != 0 && !valueEncoding.equals(encoding))) {
            out.newLine();
        }
        if (out.column() == 0) {
            if (!valueEncoding.equals(encoding)) {
                out.indent();
                out.print(".enc\t\"" + valueEncoding + "\"");
                out.newLine();
                encoding = valueEncoding;
            }
            out.indent();
            out.print(".text\t");
        }
        int character = characterFor(valueEncoding, value);
        if (character != -1) {
            out.quotedCharacter((char) character);
        } else {
            out.item(asHexByte(value));
        }
    }

    /**
     * The encoding to read the char array `block` belongs to in (the
     * elements one {@code .flo} line declared), chosen once per array by
     * {@link Subject#likelyTextEncoding}. A tie keeps the encoding already
     * in effect, so it doesn't cause a needless {@code .enc} switch.
     */
    private String encodingFor(DataArea block, Subject subject) {
        if (block.address < encodingArrayStart || block.address >= encodingArrayEnd) {
            encodingArrayStart = block.arrayStart();
            encodingArrayEnd = subject.endOfArray(block);
            arrayEncoding = subject.likelyTextEncoding(encodingArrayStart, encodingArrayEnd, encoding);
        }
        return arrayEncoding;
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

    public void printInstruction(InstructionArea block, Subject subject) throws IOException {
        considerReOrg(block.address);
        if (Objects.equals(block, lastArea)) {
            return;
        }
        Instruction instruction = block.instruction;
        int byte1 = subject.memory[block.address + 1].data;
        int byte2 = subject.memory[block.address + 2].data;
        int word = word(byte1, byte2);
        String operand = switch (instruction.addressingMode) {
            case IND_X -> format("(%s, X)", nameForAddress(byte1, "$%02X", subject));
            case IND_Y -> format("(%s), Y", nameForAddress(byte1, "$%02X", subject));
            case RELATIVE -> format("%s", nameForAddress(block.address + toSignedByte(byte1) + 2, "$%04X", subject));
            case INDIRECT -> format("(%s)", nameForAddress(word, "$%04X", subject));
            case ABSOLUTE -> format("%s", nameForAddress(word, "$%04X", subject));
            case ABSOLUTE_X -> format("%s, X", nameForAddress(word, "$%04X", subject));
            case ABSOLUTE_Y -> format("%s, Y", nameForAddress(word, "$%04X", subject));
            case IMMEDIATE -> format("#$%02X", byte1);
            case ZERO_PAGE -> format("%s", nameForAddress(byte1, "$%02X", subject));
            case ZERO_PAGE_X -> format("%s, X", nameForAddress(byte1, "$%02X", subject));
            case ZERO_PAGE_Y -> format("%s, Y", nameForAddress(byte1, "$%02X", subject));
            case JAM, ACCUMULATOR, NONE -> "";
        };
        out.newLine();
        out.indent();
        out.print(instruction.opcode.name());
        out.print(" ");
        out.print(operand);

        lastArea = block;
    }

    private String nameForAddress(int address, String formatWhenNumeric, Subject subject) {
        Area area = subject.memory[address].area;
        if (area == null) {
            // Memory no area covers can still carry a label: a user label,
            // or a jump target whose instruction couldn't be decoded.
            String label = subject.memory[address].label;
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

    void write(Subject subject, Writer w) throws IOException {
        AssemblyFileFormat assemblyFile = new AssemblyFileFormat(w);
        for (int address = 0; address < 0x10000; address++) {

            Area currentArea = subject.peek(address);
            if (currentArea != null && currentArea.isVirtual()) {
                // The loop's own address++ then lands on the first
                // address after the stretch.
                address = assemblyFile.printVirtualStretch(address, subject) - 1;
                continue;
            }

            // Is there a comment or a label here? Print them.
            String comment = subject.memory[address].comment;
            String label = subject.memory[address].label;
            if (comment != null || label != null) {
                assemblyFile.printAnnotation(address, comment, label, currentArea, subject);
            }
            if (currentArea != null) {
                if (currentArea instanceof DataArea) {
                    assemblyFile.print((DataArea) currentArea, address, subject);
                } else if (currentArea instanceof InstructionArea) {
                    InstructionArea instructionBlock = (InstructionArea) currentArea;
                    assemblyFile.printInstruction(instructionBlock, subject);
                }
            } else {
                assemblyFile.needsToReOrg = true;
            }

        }
        assemblyFile.close();
    }
}
