package com.laamella.deflower;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Arrays;

/**
 * The 64K a {@code .vsf} or {@code .prg} file loads, as values 0-255, with
 * -1 for memory it doesn't load. For the tools that look at an input file
 * without a {@code .flo} file: {@code --init} and {@code --dump}.
 */
final class MemoryImage {
    private MemoryImage() {
    }

    static int[] read(Path file) throws IOException {
        if (file.getFileName().toString().toLowerCase().endsWith(".prg")) {
            return fromPrg(file);
        }
        return fromRam(ViceSnapshotReader.memory(ViceSnapshotReader.readFile(file)).ram);
    }

    /**
     * A .prg: the load address, then the bytes. Bytes past $ffff are dropped.
     */
    static int[] fromPrg(Path file) throws IOException {
        byte[] prg = Files.readAllBytes(file);
        if (prg.length < 2) {
            throw new IllegalArgumentException(file.getFileName() + " has no load address.");
        }
        int load = loadAddress(prg);
        int[] memory = new int[0x10000];
        Arrays.fill(memory, -1);
        for (int i = 2; i < prg.length && load + i - 2 < memory.length; i++) {
            memory[load + i - 2] = prg[i] & 0xff;
        }
        return memory;
    }

    static int loadAddress(byte[] prg) {
        return (prg[0] & 0xff) | (prg[1] & 0xff) << 8;
    }

    static int[] fromRam(byte[] ram) {
        int[] memory = new int[0x10000];
        for (int i = 0; i < memory.length; i++) {
            memory[i] = ram[i] & 0xff;
        }
        return memory;
    }
}
