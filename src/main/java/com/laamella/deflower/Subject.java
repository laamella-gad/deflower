package com.laamella.deflower;

import java.nio.file.Path;
import java.util.*;

import static com.laamella.Printing.asHexWord;

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
    String outputFileName = "deflowered.asm";

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
