package com.laamella.deflower;

import com.laamella.mpu6502.specification.Instruction;

import java.io.*;
import java.nio.file.Path;
import java.util.List;
import java.util.Objects;

import static com.laamella.Printing.*;
import static com.laamella.mpu6502.ByteManipulation.toSignedByte;
import static com.laamella.mpu6502.specification.Opcode.OPCODE_NAME;
import static java.lang.String.format;

class AssemblyFileFormat {
    private final Writer w;
    private Block lastBlock = null;
    boolean needsToReOrg = true;

    AssemblyFileFormat(PrintWriter w) {
        this.w = w;
    }

    void printLabel(String label, int address) throws IOException {
        considerReOrg(address);
        newLine();
        print(label + ":");
        newLine();
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

    public void print(DataBlock block, int address, Subject subject) throws IOException {
        if (block.isSystem) {
            return;
        }
        considerReOrg(address);
        if ((!(lastBlock instanceof DataBlock)) || block.type != ((DataBlock) lastBlock).type) {
            newLine();
        }
        switch (block.type) {
            case BYTE:
                tabularPrint(".BYTE", asHexByte(subject.byteAt(address)));
                break;
        }
        lastBlock = block;
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

    public void printInstruction(InstructionBlock block, Subject subject) throws IOException {
        considerReOrg(block.address);
        if (Objects.equals(block, lastBlock)) {
            return;
        }
        Instruction instruction = block.instruction;
        int byte1 = subject.memory[block.address + 1].data;
        int byte2 = subject.memory[block.address + 2].data;
        String operand = switch (instruction.addressingMode) {
            case IND_X -> format("($%02X, X)", byte1);
            case IND_Y -> format("($%02X), Y", byte1);
            case RELATIVE -> format("$%04X", block.address + toSignedByte(byte1) + 2);
            case INDIRECT -> format("($%02X%02X)", byte2, byte1);
            case ABSOLUTE -> format("$%02X%02X", byte2, byte1);
            case ABSOLUTE_X -> format("$%02X%02X, X", byte2, byte1);
            case ABSOLUTE_Y -> format("$%02X%02X, Y", byte2, byte1);
            case IMMEDIATE -> format("#$%02X", byte1);
            case ZERO_PAGE -> format("$%02X", byte1);
            case ZERO_PAGE_X -> format("$%02X, X", byte1);
            case ZERO_PAGE_Y -> format("$%02X, Y", byte1);
            case JAM, ACCUMULATOR, NONE -> "";
        };
        newLine();
        indent();
        print(instruction.opcode.name());
        print(" ");
        print(operand);

        lastBlock = block;
    }
}

class ResultWriter {

    void write(Subject subject) throws IOException {
        Path asmFile = subject.outputPath.resolve("deflowered.asm");
        try (Writer w = new FileWriter(asmFile.toFile()); BufferedWriter bw = new BufferedWriter(w); PrintWriter pw = new PrintWriter(bw)) {
            AssemblyFileFormat assemblyFile = new AssemblyFileFormat(pw);
            for (int address = 0; address < 0x10000; address++) {

                Block currentBlock = subject.peek(address);

                // Is there a label here? Print it.
                String label = subject.memory[address].label;
                if (label != null) {
                    assemblyFile.printLabel(label, address);
                }
                if (currentBlock != null) {
                    if (currentBlock instanceof DataBlock) {
                        assemblyFile.print((DataBlock) currentBlock, address, subject);
                    } else if (currentBlock instanceof InstructionBlock) {
                        InstructionBlock instructionBlock = (InstructionBlock) currentBlock;
                        assemblyFile.printInstruction(instructionBlock, subject);
                    }
                } else {
                    assemblyFile.needsToReOrg = true;
                }

            }
        }
    }
}
