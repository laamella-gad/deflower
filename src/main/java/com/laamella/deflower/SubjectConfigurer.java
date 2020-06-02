package com.laamella.deflower;

import com.laamella.vicevcf.C64MemModule;
import com.laamella.vicevcf.C64MemModuleHandler;
import com.laamella.vicevcf.ViceVcfFile;
import com.laamella.vicevcf.ViceVcfFileReader;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Objects;
import java.util.Optional;

import static com.laamella.Assert.assertState;
import static com.laamella.deflower.DataType.*;
import static com.laamella.deflower.SubjectConfigurer.LineType.*;
import static java.nio.file.Files.readAllBytes;
import static java.nio.file.Files.readAllLines;

class SubjectConfigurer {
    enum LineType {
        BYTE_BLOCK(BYTE), CODE_ENTRY(null), WORD_BLOCK(WORD), DWORD_BLOCK(DWORD);
        DataType dataType;

        LineType(DataType dataType) {
            this.dataType = dataType;
        }
    }

    Subject configure(String flowerFile) throws URISyntaxException, IOException {
        Path path = Paths.get(Deflower.class.getResource("/" + flowerFile).toURI()).toAbsolutePath();
        Subject subject = new Subject(path.getParent());
        for (String line : readAllLines(path)) {
            parseLine(line, subject);
        }
        return subject;
    }

    private void parseLine(String line, Subject subject) throws IOException {
        line = line.trim();
        if (line.isEmpty() || line.startsWith(";")) {
            return;
        }
        String[] parts = line.split("\\s");
        if (parts[0].toLowerCase().equals("deflower")) {
            Path snapshotName = subject.basePath.resolve(parts[1]);
            System.out.println("Reading snapshot " + snapshotName);
            subject.memory = convertToIntArray(readSnapshot(snapshotName));
            return;
        }
        Integer address = null;
        Integer addressEnd = null;
        LineType type = BYTE_BLOCK;
        boolean isSystem = false;
        int amount = 1;
        String name = null;
        for (String part : parts) {
            String lower = part.toLowerCase();
            if (lower.equals("byte")) {
                type = BYTE_BLOCK;
            } else if (lower.equals("code")) {
                type = CODE_ENTRY;
            } else if (lower.equals("word")) {
                type = WORD_BLOCK;
            } else if (lower.equals("dword")) {
                type = DWORD_BLOCK;
            } else if (part.contains("-")) {
                String[] range = part.split("-");
                address = parseNumber(range[0]).orElse(null);
                addressEnd = parseNumber(range[1]).orElse(null);
            } else if (lower.equals("system")) {
                isSystem = true;
            } else {
                Optional<Integer> nr = parseNumber(part);
                if (nr.isPresent()) {
                    if (address == null) {
                        address = nr.get();
                    } else {
                        amount = nr.get();
                    }
                } else {
                    name = part;
                }
            }
        }
        assertState(address != null, "Require an address: %s", line);
        if (name != null) {
            subject.memory[address].label = name;
        }
        switch (type) {
            case CODE_ENTRY:
                subject.potentialCodeLocations.add(address);
                System.out.format("Will disassemble from %X\n", address);
                break;
            case BYTE_BLOCK:
            case WORD_BLOCK:
            case DWORD_BLOCK:
                System.out.format("Marking block of %d %s at %X \"%s\"\n", amount, type.dataType.name().toLowerCase(), address, name);
                if (addressEnd != null) {
                    amount = (addressEnd - address) / type.dataType.sizeInBytes;
                }
                for (int i = 0; i < amount; i++) {
                    subject.registerBlock(new DataBlock(address + i * type.dataType.sizeInBytes, type.dataType, isSystem));
                }
                break;
        }
    }

    private MemoryLocation[] convertToIntArray(byte[] bytes) {
        MemoryLocation[] ints = new MemoryLocation[bytes.length];
        for (int i = 0; i < bytes.length; i++) {
            ints[i] = new MemoryLocation(i, bytes[i] & 0xff);
        }
        return ints;
    }

    private Optional<Integer> parseNumber(String part) {
        try {
            return Optional.of(Integer.parseInt(part, 16));
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }

    private byte[] readSnapshot(Path c64File) throws IOException {
        ByteBuffer c64Dump = ByteBuffer.wrap(readAllBytes(c64File));
        ViceVcfFile vcfFile = new ViceVcfFileReader().read(c64Dump, new C64MemModuleHandler());
        System.out.println(vcfFile);

        if (!Objects.equals(vcfFile.header.machineName, "C64")) {
            throw new IllegalArgumentException("Only C64 dumps supported.");
        }
        return vcfFile.modules.stream()
                .filter(C64MemModule.class::isInstance)
                .map(C64MemModule.class::cast)
                .map(module -> module.ram)
                .findAny()
                .orElseThrow(() -> new IllegalArgumentException("No C64MEM found."));
    }
}
