package com.laamella.deflower;

import org.junit.jupiter.api.Test;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

import static com.laamella.snippets_test_junit5.core.Snipsertions.snipsert;
import static org.junit.jupiter.api.Assertions.assertTrue;

class DeflowerTest {
    @Test
    void deflowerSquirm() throws IOException, URISyntaxException {
        assertDeflowered("squirm");
    }

    @Test
    void deflowerTCMine() throws IOException, URISyntaxException {
        assertDeflowered("tcmine");
    }

    @Test
    void deflowerZwark() throws IOException, URISyntaxException {
        assertDeflowered("zwark");
    }

    /**
     * Every 'deflower' line starts a fresh decompilation run (issue 0010):
     * its own memory, its own flow analysis, its own output file named after
     * the binary it loads. multi.flo loads a.prg then b.prg, each with its
     * own code entry and (for b.prg) its own extra data annotation, and the
     * two runs must not leak labels, data areas or memory into each other.
     */
    @Test
    void secondDeflowerLineStartsAFreshIndependentRun() throws IOException, URISyntaxException {
        String flowerFile = "multi/multi.flo";
        new Deflower().deflower(flowerFile);
        Path out = outDir(flowerFile);
        String a = Files.readString(out.resolve("a.asm"));
        String b = Files.readString(out.resolve("b.asm"));

        snipsert(a, "src/test/resources/multi/expected-a.asm");
        snipsert(b, "src/test/resources/multi/expected-b.asm");
    }

    /**
     * JMP (indirect)'s operand is a pointer, not the destination (issue
     * 0011): the fixture's entry does JMP ($C010), where $C010-$C011 holds
     * $C020, the real target. The analyser must follow $C020 (and decode
     * the LDA/RTS there), not try to decode the pointer bytes as code.
     */
    @Test
    void followsIndirectJmpTarget() throws IOException, URISyntaxException {
        assertDeflowered("indirectjmp");
    }

    @Test
    void rejectsUnrecognizedTokens() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/garbage-tokens.flo");
    }

    @Test
    void rejectsMissingTrailingNewline() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/missing-trailing-newline.flo");
    }

    /**
     * deflower() catches a parse failure, logs it to stderr, and returns
     * without writing any output (issue 0021) rather than throwing, so a
     * malformed .flo file is checked by its effects: an error logged to
     * stderr, and nothing written to its output directory.
     */
    private void assertFailsToParse(String flowerFile) throws IOException, URISyntaxException {
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower(flowerFile);
        } finally {
            System.setErr(originalErr);
        }
        assertTrue(capturedErr.toString().contains("Failed to parse"), "Unexpected stderr: " + capturedErr);
        assertTrue(isEmpty(outDir(flowerFile)), "Should not have written output for a file that failed to parse");
    }

    /**
     * Runs the pipeline on src/test/resources/<fixture>/<fixture>.flo and
     * compares the generated assembly with the versioned expectation at
     * src/test/resources/<fixture>/expected.asm. If the expectation file
     * doesn't exist yet, it's created from the actual output and the test
     * fails so the new expectation gets reviewed before it's trusted.
     *
     * Each fixture's .flo has a single 'deflower' line for a binary named
     * after the fixture itself, so its output is named <fixture>.asm (every
     * 'deflower' line's run is named after the binary it loads).
     */
    private void assertDeflowered(String fixture) throws IOException, URISyntaxException {
        String flowerFile = fixture + "/" + fixture + ".flo";
        new Deflower().deflower(flowerFile);
        String actual = Files.readString(outDir(flowerFile).resolve(fixture + ".asm"));
        snipsert(actual, "src/test/resources/" + fixture + "/expected.asm");
    }

    private Path outDir(String flowerFile) throws URISyntaxException {
        Path floPath = Paths.get(DeflowerTest.class.getResource("/" + flowerFile).toURI());
        return floPath.getParent().resolve("out");
    }

    private boolean isEmpty(Path dir) throws IOException {
        return !Files.exists(dir) || Files.list(dir).findAny().isEmpty();
    }
}
