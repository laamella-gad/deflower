package com.laamella.deflower;

import com.laamella.vicevcf.C64MemModule;
import com.laamella.vicevcf.C64MemModuleHandler;
import com.laamella.vicevcf.ViceVcfFile;
import com.laamella.vicevcf.ViceVcfFileReader;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Path;
import java.util.HashSet;
import java.util.Set;

import static java.nio.file.Files.readAllBytes;

/**
 * Loads the 64K RAM of a VICE snapshot ({@code .vsf}) into a Subject.
 */
class ViceSnapshotReader {
    private static final Set<String> supportedMachines = new HashSet<>();

    static {
        supportedMachines.add("C64");
        supportedMachines.add("C64SC");
    }

    void read(Path c64File, Subject subject) {
        System.out.println("Reading snapshot " + c64File);
        try {
            ByteBuffer c64Dump = ByteBuffer.wrap(readAllBytes(c64File));
            ViceVcfFile vcfFile = new ViceVcfFileReader().read(c64Dump, new C64MemModuleHandler());
            System.out.println(vcfFile);

            if (!supportedMachines.contains(vcfFile.header.machineName)) {
                throw new IllegalArgumentException("Only C64 dumps supported.");
            }
            subject.storeAt(0, vcfFile.modules.stream()
                    .filter(C64MemModule.class::isInstance)
                    .map(C64MemModule.class::cast)
                    .map(module -> module.ram)
                    .findAny()
                    .orElseThrow(() -> new IllegalArgumentException("No C64MEM found.")), c64File);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
