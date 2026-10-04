package com.laamella.deflower;

import java.io.IOException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.*;

import static com.laamella.Printing.asHexWord;
import static java.nio.file.FileVisitResult.CONTINUE;
import static java.nio.file.Files.*;

class MemoryLocation {
    final int address;
    final int data;
    Area area = null;
    String label = null;

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

    Subject(Path basePath) throws IOException {
        this.basePath = basePath;
        this.outputPath = basePath.resolve("out");
        recreateDirectory(outputPath);
    }

    void storeAt(int startAddress, byte[] bytes) {
        for (int i = 0; i < bytes.length; i++) {
            System.out.println(""+(startAddress+i)+" "+(bytes[i] & 0xff));
            memory[startAddress+i] = new MemoryLocation(startAddress + i, bytes[i] & 0xff);
        }
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

    void registerBlock(Area area) {
        for (int a = 0; a < area.size; a++) {
            memory[a + area.address].area = area;
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
