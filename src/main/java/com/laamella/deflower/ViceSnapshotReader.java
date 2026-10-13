package com.laamella.deflower;

import com.laamella.vicevcf.C64MemModule;
import com.laamella.vicevcf.C64MemModuleHandler;
import com.laamella.vicevcf.CiaModuleHandler;
import com.laamella.vicevcf.MainCpuModuleHandler;
import com.laamella.vicevcf.VicIIModuleHandler;
import com.laamella.vicevcf.ViceVcfFile;
import com.laamella.vicevcf.ViceVcfFileReader;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.nio.file.Path;
import java.util.Set;

import static java.nio.file.Files.readAllBytes;

/**
 * Loads the 64K RAM of a VICE snapshot ({@code .vsf}) into a Subject.
 */
class ViceSnapshotReader {
    private static final Set<String> supportedMachines = Set.of("C64", "C64SC");

    void read(Path c64File, Subject subject) {
        subject.storeAt(0, memory(readFile(c64File)).ram, subject.basePath.relativize(c64File));
    }

    /**
     * Reads the snapshot, with the modules Deflower knows: memory, CPU,
     * VIC-II and CIAs.
     */
    static ViceVcfFile readFile(Path c64File) {
        try {
            ByteBuffer c64Dump = ByteBuffer.wrap(readAllBytes(c64File));
            ViceVcfFile vcfFile = new ViceVcfFileReader().read(c64Dump, new C64MemModuleHandler(),
                    new MainCpuModuleHandler(), new VicIIModuleHandler(), new CiaModuleHandler());
            if (!supportedMachines.contains(vcfFile.header.machineName)) {
                throw new IllegalArgumentException("Only C64 dumps supported.");
            }
            return vcfFile;
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    static C64MemModule memory(ViceVcfFile vcfFile) {
        return vcfFile.module("C64MEM", C64MemModule.class)
                .orElseThrow(() -> new IllegalArgumentException("No C64MEM found."));
    }
}
