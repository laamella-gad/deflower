package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

import java.io.*;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.Objects;

import static java.nio.file.FileVisitResult.CONTINUE;
import static java.nio.file.Files.*;

import static com.laamella.Printing.*;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.ByteManipulation.word;
import static java.lang.String.format;

class AssemblyFileFormat {
    private final Writer w;
    private Area lastArea = null;
    boolean needsToReOrg = true;
    // True right after a newLine() - i.e. nothing has been written on the
    // current line yet - false once any text is printed. Distinct from
    // `column`, which only tracks position within a tabular .BYTE/.WORD
    // dump: this tracks whether the line as a whole still needs closing.
    private boolean atLineStart = true;

    AssemblyFileFormat(PrintWriter w) {
        this.w = w;
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
            if (column != 0) {
                newLine();
            }
        } else {
            // One newLine() closes whatever line is still dangling (if
            // any - atLineStart tracks that precisely, since column only
            // tracks tabular .BYTE/.WORD position, not label/comment
            // text); the other adds the actual blank-line separator. When
            // the previous line was already cleanly closed (e.g. by the
            // forced newline below, for a label with nothing of its own
            // to print), skip the first one instead of emitting a second,
            // needless blank line.
            if (!atLineStart) {
                newLine();
            }
            newLine();
        }
        if (comment != null) {
            for (String line : comment.split("\n", -1)) {
                print("; " + line);
                newLine();
            }
        }
        if (label != null) {
            print(label + ":");
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
                newLine();
            } else if (sameKindAsPrevious && !isSingleValueRun(address, (DataArea) currentArea, subject)) {
                // Issue 0029: among same-kind labels, glue a single value
                // onto the label's line; several values get their own line
                // so the tabular dump underneath stays readable. A label
                // that starts a genuinely new kind of area always gets its
                // own line - print(DataArea, ...)'s own kind-change check
                // already does that, so doing it again here would double
                // the newline.
                newLine();
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
        int next = address + block.size;
        if (next >= subject.memory.length) {
            return true;
        }
        if (subject.memory[next].label != null || subject.memory[next].comment != null) {
            return true;
        }
        Area nextArea = subject.peek(next);
        if (!(nextArea instanceof DataArea) || nextArea.address != next) {
            return true;
        }
        DataArea nextBlock = (DataArea) nextArea;
        return nextBlock.type != block.type || nextBlock.isVirtual();
    }

    void print(String s) throws IOException {
        w.write(s);
        atLineStart = false;
    }

    private void newLine() throws IOException {
        closeQuotes();
        w.write("\n");
        column = 0;
        atLineStart = true;
    }

    private void indent() throws IOException {
        print("\t\t");
    }

    private int column = 0;

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
        if (!atLineStart) {
            newLine();
        }
        newLine();
        print(".virtual " + asHexWord(start));
        newLine();
        int address = start;
        while (address < subject.memory.length && isVirtualAt(address, subject)) {
            DataArea block = (DataArea) subject.peek(address);
            String comment = subject.memory[address].comment;
            String label = subject.memory[address].label;
            printCommentLines(comment);
            if (address != block.address) {
                // A label landing inside a multi-byte element (the second
                // byte of a word): no reservation of its own to hang it on.
                if (label != null) {
                    print(label + " = " + asHexWord(address));
                    newLine();
                }
                address++;
                continue;
            }
            int end = endOfVirtualRun(block, subject);
            int count = (end - address) / block.size;
            if (label != null) {
                print(label + ":");
            }
            if (count == 1) {
                indent();
                print(reservationDirective(block.type) + "\t?");
            } else {
                if (label != null) {
                    newLine();
                }
                indent();
                print(".fill\t" + (end - address));
            }
            newLine();
            address = firstAnnotatedAddressInside(address, end, subject);
        }
        print(".endv");
        newLine();
        needsToReOrg = true;
        lastArea = null;
        return address;
    }

    private static boolean isVirtualAt(int address, Subject subject) {
        Area area = subject.peek(address);
        return area != null && area.isVirtual();
    }

    /**
     * The (exclusive) end of the run of same-type virtual elements starting
     * at `first`: it stops before an element that differs or carries its own
     * label/comment, and after an element with a label/comment somewhere
     * inside it, so that annotation can still be printed.
     */
    private static int endOfVirtualRun(DataArea first, Subject subject) {
        int end = first.address + first.size;
        while (!annotatedInside(end - first.size, end, subject) && end < subject.memory.length) {
            Area next = subject.peek(end);
            if (!(next instanceof DataArea) || !next.isVirtual() || next.address != end
                    || ((DataArea) next).type != first.type
                    || subject.memory[end].label != null || subject.memory[end].comment != null) {
                break;
            }
            end += first.size;
        }
        return end;
    }

    private static boolean annotatedInside(int elementStart, int elementEnd, Subject subject) {
        return firstAnnotatedAddressInside(elementStart, elementEnd, subject) != elementEnd;
    }

    /**
     * The first address after `start` and before `end` with a label or
     * comment, or `end` when there is none.
     */
    private static int firstAnnotatedAddressInside(int start, int end, Subject subject) {
        for (int address = start + 1; address < end; address++) {
            if (subject.memory[address].label != null || subject.memory[address].comment != null) {
                return address;
            }
        }
        return end;
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
                print("; " + line);
                newLine();
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
            newLine();
        }
        switch (block.type) {
            case BYTE, UNKNOWN:
                tabularPrint(".byte", asHexByte(subject.byteAt(address)));
                break;
            case CHAR:
                textPrint(subject.byteAt(address));
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

    // True while a double-quoted literal is open on the current .text
    // line; newLine() closes it.
    private boolean inQuotes = false;

    /**
     * Prints one CHAR value as an item of a 64tass {@code .text} line
     * (issue 0039), the string counterpart of tabularPrint: consecutive
     * printable characters share one double-quoted literal, anything else
     * (control codes, the double quote itself) becomes a hex item, e.g.
     * {@code .text "AB", $0D, "C"}. Wraps every TEXT_BYTES_PER_LINE values.
     */
    private void textPrint(int value) throws IOException {
        if (column == TEXT_BYTES_PER_LINE) {
            newLine();
        }
        if (column == 0) {
            indent();
            print(".text\t");
        }
        boolean printable = value >= 0x20 && value <= 0x7E && value != '"';
        if (printable) {
            if (!inQuotes) {
                if (column != 0) {
                    print(", ");
                }
                print("\"");
                inQuotes = true;
            }
            print(String.valueOf((char) value));
        } else {
            closeQuotes();
            if (column != 0) {
                print(", ");
            }
            print(asHexByte(value));
        }
        column++;
    }

    private void closeQuotes() throws IOException {
        if (inQuotes) {
            print("\"");
            inQuotes = false;
        }
    }

    /**
     * Finishes the output: closes a string literal still open on the last
     * line.
     */
    void close() throws IOException {
        closeQuotes();
    }

    private void considerReOrg(int address) throws IOException {
        if (needsToReOrg) {
            newLine();
            print("*=" + asHexWord(address));
            needsToReOrg = false;
        }
    }

    private void tabularPrint(String command, String data) throws IOException {
        if (column == 16) {
            newLine();
        }

        if (column == 0) {
            indent();
            print(command);
            print("\t");
        } else {
            print(", ");
        }
        print(data);
        column++;
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
        newLine();
        indent();
        print(instruction.opcode.name());
        print(" ");
        print(operand);

        lastArea = block;
    }

    private String nameForAddress(int address, String formatWhenNumeric, Subject subject) {
        Area area = subject.memory[address].area;
        if (area == null) {
            return String.format(formatWhenNumeric, address);
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
     * Clears and recreates the shared output directory. Called once per
     * .flo file, before any of its (possibly several) Subjects are written,
     * so that one deflower line's run doesn't delete another's output.
     */
    void prepareOutputDirectory(Path basePath) throws IOException {
        recreateDirectory(basePath.resolve("out"));
    }

    private void recreateDirectory(Path directory) throws IOException {
        if (Files.exists(directory)) {
            walkFileTree(directory, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    delete(file);
                    return CONTINUE;
                }

                @Override
                public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                    delete(dir);
                    return CONTINUE;
                }
            });
        }
        createDirectories(directory);
    }

    void write(Subject subject) throws IOException {
        Path asmFile = subject.outputPath.resolve(subject.outputFileName);
        System.out.println("Writing "+asmFile);
        try (Writer w = new FileWriter(asmFile.toFile()); BufferedWriter bw = new BufferedWriter(w); PrintWriter pw = new PrintWriter(bw)) {
            AssemblyFileFormat assemblyFile = new AssemblyFileFormat(pw);
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
}
