package com.laamella.deflower;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.file.Files;

import static com.laamella.snippets_test_junit5.core.Snipsertions.snipsert;

class DeflowerTest {
    @Test
    void deflowerSquirm() throws IOException, URISyntaxException {
        assertDeflowered("squirm/squirm.flo", "squirm");
    }

    @Test
    void deflowerTCMine() throws IOException, URISyntaxException {
        assertDeflowered("tcmine/tcmine.flo", "tcmine");
    }

    @Test
    void deflowerZwark() throws IOException, URISyntaxException {
        assertDeflowered("zwark/zwark.flo", "zwark");
    }

    /**
     * Runs the pipeline and compares the generated assembly with the versioned
     * expectation in src/test/resources/<fixture>/expected.asm. If the file
     * doesn't exist yet, it's created from the actual output and the test
     * fails so the new expectation gets reviewed before it's trusted.
     */
    private void assertDeflowered(String flowerFile, String fixture) throws IOException, URISyntaxException {
        Subject subject = new Deflower().deflower(flowerFile);
        String actual = Files.readString(subject.outputPath.resolve("deflowered.asm"));
        snipsert(actual, "src/test/resources/" + fixture + "/expected.asm");
    }
}
