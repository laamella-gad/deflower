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
import static org.junit.jupiter.api.Assertions.assertFalse;
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
     * stderr, and no deflowered.asm written.
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
        assertFalse(Files.exists(outputFile(flowerFile)), "Should not have written output for a file that failed to parse");
    }

    /**
     * Runs the pipeline on src/test/resources/<fixture>/<fixture>.flo and
     * compares the generated assembly with the versioned expectation at
     * src/test/resources/<fixture>/expected.asm. If the expectation file
     * doesn't exist yet, it's created from the actual output and the test
     * fails so the new expectation gets reviewed before it's trusted.
     */
    private void assertDeflowered(String fixture) throws IOException, URISyntaxException {
        String flowerFile = fixture + "/" + fixture + ".flo";
        new Deflower().deflower(flowerFile);
        String actual = Files.readString(outputFile(flowerFile));
        snipsert(actual, "src/test/resources/" + fixture + "/expected.asm");
    }

    private Path outputFile(String flowerFile) throws URISyntaxException {
        Path floPath = Paths.get(DeflowerTest.class.getResource("/" + flowerFile).toURI());
        return floPath.getParent().resolve("out").resolve("deflowered.asm");
    }
}
