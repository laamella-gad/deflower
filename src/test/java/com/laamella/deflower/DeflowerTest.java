package com.laamella.deflower;

import com.laamella.mpu6502.Segment;
import com.laamella.mpu6502.assembler.SourceParser;
import com.laamella.snippets_test_junit5.core.BasePath;
import com.laamella.snippets_test_junit5.core.SnippetFileFormat;
import com.laamella.snippets_test_junit5.core.SnippetTestFactory;
import org.junit.jupiter.api.DynamicTest;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestFactory;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.io.UncheckedIOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;
import java.util.stream.Collectors;
import java.util.stream.Stream;

import static com.laamella.snippets_test_junit5.core.TestCaseFilenameFilter.filesWithExtension;
import static java.nio.charset.StandardCharsets.UTF_8;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.fail;

/**
 * Runs the snippet files in {@code src/test/snippets} (issue 0062). Every
 * snippet has three expectations: what Deflower printed (stdout and stderr
 * together), the generated {@code .asm} files, and the other files in
 * {@code out/}: the memory maps as text and the exported binaries as hex
 * dumps. Deflower runs with verify on (issue 0075), so the printed part
 * ends with each run's verify report.
 * <p>
 * A short snippet ({@code short/}) holds its whole test: assembly source,
 * assembled into {@code test.prg}, then the {@code .flo} file, written as
 * {@code test.flo}. More input parts are more files, each starting with a
 * {@code ; file: <name>} line; a {@code .prg} one is assembled. Every
 * generated {@code .asm} must reassemble to the bytes of the {@code .prg}
 * with its name, unless the assembly has a {@code ; no round trip} line.
 * <p>
 * A large snippet ({@code large/}) names a {@code .flo} file on the test
 * classpath, for programs too big to keep as source in a snippet.
 * <p>
 * An init snippet ({@code init/}) names a {@code .vsf} or {@code .prg}
 * file on the test classpath, and expects the {@code .flo} skeleton that
 * {@code --init} writes for it (issue 0072).
 * <p>
 * A dump snippet ({@code dump/}) names such a file and a range, and expects
 * what {@code --dump} prints for it, or its error (issue 0097). Find and
 * strings snippets ({@code find/}, {@code strings/}) name such a file and
 * the arguments of {@code --find} (issue 0099) or {@code --strings} (issue
 * 0100), and expect what it prints, or its error.
 */
class DeflowerTest {
    private static final SnippetFileFormat FORMAT = new SnippetFileFormat(
            ">>>", "<<<\n", "===\n", "^^^\n", "~~~\n", "vvv\n");
    private static final String FILE_HEADER = "; file: ";
    // In a snippet's assembly, skips the round trip, for a snippet that
    // shows what verify reports when the output doesn't reassemble.
    private static final String NO_ROUND_TRIP = "; no round trip";

    @TestFactory
    Stream<DynamicTest> shortSnippets() throws IOException {
        return new SnippetTestFactory(FORMAT, snippets("short"), filesWithExtension("txt"), DeflowerTest::runShort).stream();
    }

    @TestFactory
    Stream<DynamicTest> largeSnippets() throws IOException {
        return new SnippetTestFactory(FORMAT, snippets("large"), filesWithExtension("txt"), DeflowerTest::runLarge).stream();
    }

    @TestFactory
    Stream<DynamicTest> initSnippets() throws IOException {
        return new SnippetTestFactory(FORMAT, snippets("init"), filesWithExtension("txt"), DeflowerTest::runInit).stream();
    }

    @TestFactory
    Stream<DynamicTest> dumpSnippets() throws IOException {
        return new SnippetTestFactory(FORMAT, snippets("dump"), filesWithExtension("txt"), DeflowerTest::runDump).stream();
    }

    @TestFactory
    Stream<DynamicTest> findSnippets() throws IOException {
        return new SnippetTestFactory(FORMAT, snippets("find"), filesWithExtension("txt"), DeflowerTest::runFind).stream();
    }

    @TestFactory
    Stream<DynamicTest> stringsSnippets() throws IOException {
        return new SnippetTestFactory(FORMAT, snippets("strings"), filesWithExtension("txt"), DeflowerTest::runStrings).stream();
    }

    /**
     * A snippet can't hold a file without a trailing newline, since every
     * part ends in one (issue 0088).
     */
    @Test
    void acceptsLastLineWithoutNewline() throws IOException {
        String source = "*=$c000\nstart:\n\t\tlda data\n\t\trts\ndata:\n\t\t.byte\t$01\n";
        for (String lastLine : List.of("$c004 byte data", "; a comment")) {
            String flo = "deflower test.prg\n$c000 code start\n" + lastLine;
            assertThat(runShort(List.of(source, flo)))
                    .as("last line: " + lastLine)
                    .isEqualTo(runShort(List.of(source, flo + "\n")));
        }
    }

    private static BasePath snippets(String kind) {
        return BasePath.fromMavenModuleRoot(DeflowerTest.class).inSubDirectory("src/test/snippets/" + kind);
    }

    private static List<String> runShort(List<String> parts) throws IOException {
        assertThat(parts).as("input parts: assembly, then the .flo file").hasSizeGreaterThanOrEqualTo(2);
        Path dir = Files.createTempDirectory("deflower");
        try {
            if (!parts.get(0).isBlank()) {
                writeFile(dir, "test.prg", parts.get(0));
            }
            Files.writeString(dir.resolve("test.flo"), parts.get(1));
            for (String part : parts.subList(2, parts.size())) {
                assertThat(part).as("extra input part").startsWith(FILE_HEADER);
                int endOfHeader = part.indexOf('\n');
                writeFile(dir, part.substring(FILE_HEADER.length(), endOfHeader).trim(), part.substring(endOfHeader + 1));
            }
            List<String> outputs = deflower(dir.resolve("test.flo"));
            if (!parts.get(0).contains(NO_ROUND_TRIP)) {
                assertReassembles(dir);
            }
            return outputs;
        } finally {
            deleteRecursively(dir);
        }
    }

    private static List<String> runLarge(List<String> parts) throws IOException, URISyntaxException {
        assertThat(parts).as("input: one .flo path on the test classpath").hasSize(1);
        String flowerFile = parts.get(0).trim();
        return deflower(Paths.get(DeflowerTest.class.getResource("/" + flowerFile).toURI()));
    }

    private static List<String> runInit(List<String> parts) throws IOException, URISyntaxException {
        assertThat(parts).as("input: one .vsf or .prg path on the test classpath").hasSize(1);
        Path file = Paths.get(DeflowerTest.class.getResource("/" + parts.get(0).trim()).toURI());
        return List.of(String.join("\n", new Initializer().skeleton(file)) + "\n");
    }

    private static List<String> runDump(List<String> parts) throws IOException, URISyntaxException {
        return look("--dump", parts);
    }

    private static List<String> runFind(List<String> parts) throws IOException, URISyntaxException {
        return look("--find", parts);
    }

    private static List<String> runStrings(List<String> parts) throws IOException, URISyntaxException {
        return look("--strings", parts);
    }

    /**
     * Runs a tool that looks at an input file, on the file the snippet names
     * on the test classpath and the arguments after it.
     */
    private static List<String> look(String flag, List<String> parts) throws IOException, URISyntaxException {
        assertThat(parts).as("input: a .vsf or .prg path on the test classpath, then the arguments").hasSize(1);
        List<String> input = Arrays.asList(parts.get(0).trim().split(" +"));
        Path file = Paths.get(DeflowerTest.class.getResource("/" + input.get(0)).toURI());
        try {
            return List.of(String.join("\n", Deflower.look(flag, file, input.subList(1, input.size()))) + "\n");
        } catch (IllegalArgumentException e) {
            return List.of(e.getMessage() + "\n");
        }
    }

    /**
     * Writes a file for a short snippet: a .prg is assembled from the text,
     * anything else is written as it is.
     */
    private static void writeFile(Path dir, String name, String text) throws IOException {
        Path file = dir.resolve(name);
        if (name.endsWith(".prg")) {
            Files.write(file, prg(SourceParser.assemble(text, fileName -> null)));
        } else {
            Files.writeString(file, text);
        }
    }

    /**
     * The segments as one .prg: the load address, then everything from the
     * lowest to the highest byte, with zeroes in the gaps.
     */
    private static byte[] prg(List<Segment> segments) {
        int start = segments.stream().mapToInt(s -> s.loadAddress).min().orElse(0);
        int end = segments.stream().mapToInt(s -> s.loadAddress + s.data.length).max().orElse(0);
        byte[] prg = new byte[2 + end - start];
        prg[0] = (byte) start;
        prg[1] = (byte) (start >> 8);
        for (Segment segment : segments) {
            for (int i = 0; i < segment.data.length; i++) {
                prg[2 + segment.loadAddress - start + i] = (byte) segment.data[i];
            }
        }
        return prg;
    }

    /**
     * Runs Deflower on the .flo file and returns the three outputs.
     */
    private static List<String> deflower(Path flowerFile) throws IOException {
        ByteArrayOutputStream printed = new ByteArrayOutputStream();
        PrintStream originalOut = System.out;
        PrintStream originalErr = System.err;
        PrintStream capture = new PrintStream(printed, true, UTF_8);
        System.setOut(capture);
        System.setErr(capture);
        try {
            new Deflower(true).deflower(flowerFile);
        } finally {
            System.setOut(originalOut);
            System.setErr(originalErr);
        }
        Path out = flowerFile.getParent().resolve("out");
        List<Path> asmFiles = outFiles(out, true);
        StringBuilder asm = new StringBuilder();
        for (Path file : asmFiles) {
            if (asmFiles.size() > 1) {
                asm.append("--- ").append(file.getFileName()).append('\n');
            }
            asm.append(Files.readString(file));
        }
        StringBuilder binaries = new StringBuilder();
        for (Path file : outFiles(out, false)) {
            binaries.append("--- ").append(file.getFileName()).append('\n')
                    .append(file.toString().endsWith(".map") ? Files.readString(file) : hexDump(Files.readAllBytes(file)));
        }
        return List.of(endLine(printed.toString(UTF_8)), endLine(asm.toString()), binaries.toString());
    }

    /**
     * Ends the text with a newline, so the snippet separator after it
     * starts a line of its own.
     */
    private static String endLine(String text) {
        return text.isEmpty() || text.endsWith("\n") ? text : text + "\n";
    }

    private static List<Path> outFiles(Path out, boolean asm) throws IOException {
        if (!Files.exists(out)) {
            return List.of();
        }
        try (Stream<Path> files = Files.list(out)) {
            return files
                    .filter(file -> file.toString().endsWith(".asm") == asm)
                    .sorted()
                    .collect(Collectors.toList());
        }
    }

    private static String hexDump(byte[] bytes) {
        StringBuilder dump = new StringBuilder();
        for (int line = 0; line < bytes.length; line += 16) {
            dump.append(String.format("%04x:", line));
            for (int i = line; i < Math.min(line + 16, bytes.length); i++) {
                dump.append(String.format(" %02x", bytes[i] & 0xff));
            }
            dump.append('\n');
        }
        return dump.toString();
    }

    /**
     * Every byte an out/X.asm assembles to lies inside X.prg and equals the
     * byte there. Bytes the .asm leaves out, like memory the tracer never
     * reached, aren't checked.
     */
    private static void assertReassembles(Path dir) throws IOException {
        Path out = dir.resolve("out");
        for (Path asmFile : outFiles(out, true)) {
            String baseName = asmFile.getFileName().toString().replaceFirst("\\.asm$", "");
            Path prgFile = dir.resolve(baseName + ".prg");
            if (!Files.exists(prgFile)) {
                continue;
            }
            byte[] prg = Files.readAllBytes(prgFile);
            int load = (prg[0] & 0xff) | (prg[1] & 0xff) << 8;
            List<Segment> segments;
            try {
                segments = SourceParser.assemble(Files.readString(asmFile), fileName -> {
                    try {
                        return Files.readAllBytes(out.resolve(fileName));
                    } catch (IOException e) {
                        throw new UncheckedIOException(e);
                    }
                });
            } catch (RuntimeException e) {
                throw new AssertionError(asmFile.getFileName() + " doesn't reassemble: " + e.getMessage(), e);
            }
            List<String> differences = new ArrayList<>();
            for (Segment segment : segments) {
                for (int i = 0; i < segment.data.length; i++) {
                    int address = segment.loadAddress + i;
                    int offset = 2 + address - load;
                    if (offset < 2 || offset >= prg.length) {
                        differences.add(String.format("$%04x: %02x, outside %s", address, segment.data[i], prgFile.getFileName()));
                    } else if ((prg[offset] & 0xff) != segment.data[i]) {
                        differences.add(String.format("$%04x: %02x, should be %02x", address, segment.data[i], prg[offset] & 0xff));
                    }
                }
            }
            if (!differences.isEmpty()) {
                String shown = String.join("\n", differences.subList(0, Math.min(10, differences.size())));
                String more = differences.size() > 10 ? String.format("%n... %d more", differences.size() - 10) : "";
                fail("%s doesn't reassemble to %s:%n%s%s", asmFile.getFileName(), prgFile.getFileName(), shown, more);
            }
        }
    }

    private static void deleteRecursively(Path dir) throws IOException {
        try (Stream<Path> files = Files.walk(dir)) {
            for (Path file : files.sorted(Comparator.reverseOrder()).collect(Collectors.toList())) {
                Files.delete(file);
            }
        }
    }
}
