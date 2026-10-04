package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

import java.io.*;
import java.nio.file.Path;
import java.util.Objects;

import static com.laamella.Printing.*;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.ByteManipulation.word;
import static java.lang.String.format;

class AssemblyFileFormat {
    private final Writer w;
    private Area lastArea = null;
    boolean needsToReOrg = true;

    AssemblyFileFormat(PrintWriter w) {
        this.w = w;
    }

    void printLabel(String label, int address) throws IOException {
        considerReOrg(address);
        newLine();
        newLine();
        print(label + ":");
    }

    void print(String s) throws IOException {
        w.write(s);
    }

    private void newLine() throws IOException {
        w.write("\n");
        column = 0;
    }

    private void indent() throws IOException {
        print("\t\t");
    }

    private int column = 0;

    public void print(DataArea block, int address, Subject subject) throws IOException {
        if (block.isSystem) {
            return;
        }
        considerReOrg(address);
        if ((!(lastArea instanceof DataArea)) || block.type != ((DataArea) lastArea).type) {
            newLine();
        }
        switch (block.type) {
            case BYTE:
                tabularPrint(".BYTE", asHexByte(subject.byteAt(address)));
                break;
        }
        lastArea = block;
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

    void write(Subject subject) throws IOException {
        Path asmFile = subject.outputPath.resolve("deflowered.asm");
        System.out.println("Writing "+asmFile);
        try (Writer w = new FileWriter(asmFile.toFile()); BufferedWriter bw = new BufferedWriter(w); PrintWriter pw = new PrintWriter(bw)) {
            AssemblyFileFormat assemblyFile = new AssemblyFileFormat(pw);
            for (int address = 0; address < 0x10000; address++) {

                Area currentArea = subject.peek(address);

                // Is there a label here? Print it.
                String label = subject.memory[address].label;
                if (label != null) {
                    assemblyFile.printLabel(label, address);
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
        }
    }
}
