package com.laamella.vicevcf;

import java.io.IOException;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import static com.laamella.ByteBufferAccess.*;
import static java.lang.String.format;
import static java.nio.charset.StandardCharsets.US_ASCII;

public class ViceVcfFileReader {

    public ViceVcfFile read(ByteBuffer vcfFileContents, ModuleHandler... moduleHandlers) throws IOException {
        Header header = readHeader(vcfFileContents);
        List<Module> modules = new ArrayList<>();
        while (vcfFileContents.hasRemaining()) {
            modules.add(readModule(vcfFileContents, moduleHandlers));
        }
        return new ViceVcfFile(header, modules);
    }

    private Module readModule(ByteBuffer vcfFileContents, ModuleHandler[] moduleHandlers) {
        String moduleType = readPaddedString(vcfFileContents, 16, 0);
        Version version = new Version(vcfFileContents.get(), vcfFileContents.get());
        int size = readDword(vcfFileContents) - 22;
        byte[] content = getByteArray(vcfFileContents, size);
        System.out.printf("Found %s %s block of size %d.%n", moduleType, version, size);

        for (ModuleHandler moduleHandler : moduleHandlers) {
            Module module = moduleHandler.handle(moduleType, version, content);
            if (module != null) {
                return module;
            }
        }
        return new UnhandledModule(moduleType, version, content);
    }

    private Header readHeader(ByteBuffer vcfFileContents) throws IOException {
        byte[] expectedFormat = "VICE Snapshot File\032".getBytes(US_ASCII);
        byte[] header = getByteArray(vcfFileContents, expectedFormat.length);
        if (!Arrays.equals(expectedFormat, header)) {
            throw new IOException("Not a VICE snapshot file");
        }

        Version version = new Version(vcfFileContents.get(), vcfFileContents.get());
        byte[] machineNameBytes = getByteArray(vcfFileContents, 16);
        String machineName = paddedString(machineNameBytes, 0);
        System.out.printf("Vice dump found, format %s %s.%n", machineName, version);

        // VICE snapshot format 2.0+ has a "VICE Version" block here. Older
        // snapshots (format 1.x, as produced by e.g. VICE 1.x) go straight
        // into the first module, so what we just read is that module's
        // header and has to be put back.
        byte[] expectedViceVersionHeader = "VICE Version\032".getBytes(US_ASCII);
        byte[] viceVersionHeader = getByteArray(vcfFileContents, expectedViceVersionHeader.length);
        if (Arrays.equals(expectedViceVersionHeader, viceVersionHeader)) {
            int viceVersion = readDword(vcfFileContents);
            int viceSubversionRevisionNumber = readDword(vcfFileContents);
            System.out.printf("Vice version %s, SVN revision %s.%n", viceVersion, viceSubversionRevisionNumber);
        } else {
            vcfFileContents.position(vcfFileContents.position() - expectedViceVersionHeader.length);
        }

        return new Header(machineName, version);
    }
}
