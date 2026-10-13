package com.laamella.deflower;

import com.laamella.mpu6502.Segment;
import com.laamella.mpu6502.assembler.SourceParser;

import java.io.IOException;
import java.io.UncheckedIOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

/**
 * Checks a written .asm against the image it came from (issue 0075): it
 * reassembles the file with mpu6502's assembler and compares every byte it
 * emits with the loaded memory, and lists the gaps, the loaded memory no
 * area covers. Prints one summary line, then one line per difference (the
 * first few) and per gap:
 * <pre>
 * Verify out/test.asm: 13 bytes emitted, 1 differ, 48 virtual, 1 gap
 * differ $c001 expected $07 got $08
 * gap $c00d-$c010
 * </pre>
 */
final class Verifier {
    private static final int SHOWN_DIFFERENCES = 10;

    /**
     * True when every emitted byte equals the image and there are no gaps.
     */
    boolean verify(Subject subject, Path asmFile) throws IOException {
        String name = "Verify " + subject.basePath.relativize(asmFile);
        List<Segment> segments;
        try {
            segments = SourceParser.assemble(Files.readString(asmFile), fileName -> {
                try {
                    return Files.readAllBytes(subject.outputPath.resolve(fileName));
                } catch (IOException e) {
                    throw new UncheckedIOException(e);
                }
            });
        } catch (RuntimeException e) {
            System.out.println(name + ": doesn't reassemble: " + e.getMessage());
            return false;
        }
        int emitted = 0;
        List<String> differences = new ArrayList<>();
        for (Segment segment : segments) {
            for (int i = 0; i < segment.data.length; i++) {
                int address = segment.loadAddress + i;
                emitted++;
                if (address > 0xffff || !subject.memory[address].loaded) {
                    differences.add(String.format("differ $%04x expected nothing got $%02x", address, segment.data[i]));
                } else if (subject.memory[address].data != segment.data[i]) {
                    differences.add(String.format("differ $%04x expected $%02x got $%02x", address, subject.memory[address].data, segment.data[i]));
                }
            }
        }
        int virtual = 0;
        for (MemoryLocation location : subject.memory) {
            if (location.area != null ? location.area.isVirtual() : location.droppedVirtual) {
                virtual++;
            }
        }
        List<int[]> gaps = MemoryMap.gaps(subject);
        System.out.format("%s: %d bytes emitted, %d differ, %d virtual, %d %s%n",
                name, emitted, differences.size(), virtual, gaps.size(), gaps.size() == 1 ? "gap" : "gaps");
        differences.stream().limit(SHOWN_DIFFERENCES).forEach(System.out::println);
        if (differences.size() > SHOWN_DIFFERENCES) {
            System.out.format("... %d more differ%n", differences.size() - SHOWN_DIFFERENCES);
        }
        for (int[] gap : gaps) {
            System.out.println("gap " + MemoryMap.range(gap[0], gap[1]));
        }
        return differences.isEmpty() && gaps.isEmpty();
    }
}
