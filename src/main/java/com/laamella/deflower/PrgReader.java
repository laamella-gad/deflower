package com.laamella.deflower;

import com.laamella.mpu6502.ByteManipulation;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Path;

import static java.nio.file.Files.readAllBytes;

/**
 * Loads a {@code .prg} file (2-byte load address, then the bytes) into a
 * Subject, at its load address.
 */
class PrgReader {
    void read(Path c64File, Subject subject) {
        System.out.println("Reading prg " + c64File);
        try {
            ByteBuffer c64Dump = ByteBuffer.wrap(readAllBytes(c64File));
            int lo = c64Dump.get();
            int hi = c64Dump.get();
            int loadAddress = ByteManipulation.word(lo, hi);
            System.out.println("load address " + loadAddress);
            byte[] b = new byte[c64Dump.remaining()];
            c64Dump.get(b);
            subject.storeAt(loadAddress, b);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
