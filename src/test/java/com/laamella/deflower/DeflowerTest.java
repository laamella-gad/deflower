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
import static org.assertj.core.api.Assertions.assertThat;

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

    /**
     * AssemblyFileFormat.print(DataArea, ...) used to only handle BYTE,
     * silently skipping WORD/DWORD/CHAR areas (issue 0002). Covers all three:
     * two WORDs, one DWORD, and three CHARs (printed as one .text
     * string, issue 0039).
     */
    @Test
    void emitsWordDwordAndCharData() throws IOException, URISyntaxException {
        assertDeflowered("datatypes");
    }

    /**
     * registerBlock collects an error when one area overwrites a genuinely
     * different one (Subject.errors), and Deflower refuses to write an
     * (illegal) asm file for a subject that has any (issue 0018).
     * overlap.flo declares a 2-byte word at $C000, then a byte at $C001
     * landing inside it: the second annotation disagrees with the first, so
     * it must be reported (naming both areas and the address) on stderr,
     * and overlap.asm must not be written.
     */
    @Test
    void reportsAreaConflictAndSkipsOutputOnOverlap() throws IOException, URISyntaxException {
        String flowerFile = "overlap/overlap.flo";
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower(flowerFile);
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString())
                .contains("Area conflict at $C001")
                .contains("byte", "word")
                .contains("Errors detected");
        assertThat(isEmpty(outDir(flowerFile))).as("output directory for a subject with an area conflict").isTrue();
    }

    /**
     * Issue 0043: one label defined at two addresses would make the
     * assembler reject the output, or resolve references to the wrong
     * address, so it is reported and no output is written.
     */
    @Test
    void reportsDuplicateLabelAndSkipsOutput() throws IOException, URISyntaxException {
        String flowerFile = "duplicatelabel/duplicatelabel.flo";
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower(flowerFile);
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString())
                .contains("Duplicate label twin at $C001, already defined at $C000")
                .contains("Errors detected");
        assertThat(isEmpty(outDir(flowerFile))).as("output directory for a subject with a duplicate label").isTrue();
    }

    /**
     * Issue 0028: a single address without a type covers no memory, so
     * `virtual` on it would do nothing; it is reported instead.
     */
    @Test
    void reportsVirtualOnPlainAddress() throws IOException, URISyntaxException {
        String flowerFile = "virtualaddress/virtualaddress.flo";
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower(flowerFile);
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString())
                .contains("Virtual address $D020 needs a type or a range")
                .contains("Errors detected");
        assertThat(isEmpty(outDir(flowerFile))).as("output directory for a subject with a virtual plain address").isTrue();
    }

    /**
     * Issue 0014: a .prg whose load address plus length runs past $FFFF is
     * rejected with a message naming the file and load address, instead of
     * an ArrayIndexOutOfBoundsException.
     */
    @Test
    void rejectsPrgRunningPastEndOfMemory() throws IOException, URISyntaxException {
        String flowerFile = "toolong/toolong.flo";
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower(flowerFile);
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString())
                .contains("toolong.prg: 32 bytes loaded at $FFF0 run past $FFFF");
        assertThat(isEmpty(outDir(flowerFile))).as("output directory for an oversized prg").isTrue();
    }

    /**
     * Areas that describe themselves identically (same address, size and
     * kind) are a redundant re-annotation, not a disagreement, so they must
     * not be reported as a conflict.
     */
    @Test
    void doesNotLogIdenticalReRegistration() throws IOException, URISyntaxException {
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower("datatypes/datatypes.flo");
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString()).doesNotContain("Area conflict");
    }

    /**
     * `byte[48] screen` at $400 registers 48 separate one-element
     * DataAreas (issue 0024), so an operand pointing into the middle of
     * the block, e.g. `STA $422` (offset $22), must still resolve against
     * the block's label - "screen + $22" - instead of falling back to a
     * bare hex address just because that particular element has no label
     * of its own.
     */
    @Test
    void resolvesAnOperandInsideALabeledArrayToLabelPlusOffset() throws IOException, URISyntaxException {
        assertDeflowered("blockoffset");
    }

    /**
     * A 3-byte LDA_ABS at $C000 would run into a single-byte DataArea
     * declared at $C002 (its last operand byte), so the entry point must
     * not be disassembled at all (issue 0023) - the mirror case of jumping
     * straight into a non-code area. guard's .BYTE must come through
     * untouched, and nothing gets printed as code at $C000/$C001.
     */
    @Test
    void doesNotDisassembleIntoAnExistingArea() throws IOException, URISyntaxException {
        assertDeflowered("partialoverlap");
    }

    /**
     * A standalone ';'/'#' comment line attaches to the address of the
     * annotation line that follows it (issue 0003): it's printed as a
     * "; ..." line right above the label/data it documents. Consecutive
     * comment lines attach as one multi-line comment.
     */
    @Test
    void carriesCommentsToOutput() throws IOException, URISyntaxException {
        assertDeflowered("comments");
    }

    /**
     * A label landing on an address that merely continues a contiguous
     * same-type data run (issue 0027) must not fragment the run into
     * separate, blank-line-separated .BYTE blocks: the dump keeps running
     * as one block, with each label on its own line right above the data
     * that continues beneath it.
     */
    @Test
    void labelInsideDataRunDoesNotFragmentIt() throws IOException, URISyntaxException {
        assertDeflowered("midblocklabel");
    }

    /**
     * A line with no explicit type keyword is a placeholder (issue 0031):
     * narrowing it later with a more specific annotation - a word, or a
     * code entry point - must not be reported as an area conflict, and
     * must not stop the subject's output from being written. The carved
     * word and the carved code entry (one RTS) both take over cleanly in
     * the middle of what's otherwise still a plain placeholder dump.
     */
    @Test
    void carvingASpecificTypeOutOfAPlaceholderDoesNotConflict() throws IOException, URISyntaxException {
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            assertDeflowered("narrowplaceholder");
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString()).doesNotContain("Area conflict");
    }

    /**
     * Issue 0033: each array element now carries its own label/offset
     * baked in at creation, instead of resolving it by scanning backward
     * through neighboring MemoryLocations for the nearest label. my_array
     * spans $C000-$C00F as an unnamed-per-element placeholder; carving a
     * word (mid_ptr) out of its middle ($C006-$C007, issue 0031's
     * narrowing) must not orphan the elements on either side of the cut -
     * $C005 (before) and $C008 (after) must still resolve to "my_array +
     * $5" / "my_array + $8" respectively, and $C006 itself to "mid_ptr",
     * regardless of what now sits between them.
     */
    @Test
    void arrayElementsOnBothSidesOfACarvedOutMiddleStillResolveToTheArrayLabel() throws IOException, URISyntaxException {
        assertDeflowered("partialarraycarve");
    }

    /**
     * Issues 0045/0046: a `virtual` area's contents are not dumped; it
     * becomes a .virtual reservation keeping its labels, type and size, and
     * code referencing it - including an element inside a virtual array -
     * still resolves by name.
     */
    @Test
    void virtualAreaBecomesVirtualBlockInsteadOfData() throws IOException, URISyntaxException {
        assertDeflowered("virtualarea");
    }

    /**
     * Issue 0028: a label inside a declared array or a word is printed as
     * an address define after it, so the array's dump stays unbroken.
     */
    @Test
    void labelInsideArrayBecomesAddressDefine() throws IOException, URISyntaxException {
        assertDeflowered("arraylabel");
    }

    /**
     * Issue 0039: consecutive CHAR values print as `.text` lines, printable
     * characters sharing a double-quoted literal and anything else
     * (control codes, double quotes, a $00 terminator, a length byte) as
     * hex items, wrapping every 32 values. `.null`/`.ptext` are issue 0047.
     */
    @Test
    void charRunsBecomeTextStrings() throws IOException, URISyntaxException {
        assertDeflowered("strings");
    }

    /**
     * Issue 0040: each declared char array is read as ASCII or as
     * Commodore screen codes, whichever has more uppercase letters in it
     * (a tie keeps the encoding in effect), and the output switches 64tass's
     * `.enc` wherever that changes - including between two adjacent arrays
     * with no label in between.
     */
    @Test
    void charArraysPickAsciiOrScreenCodeEncoding() throws IOException, URISyntaxException {
        assertDeflowered("screencodes");
    }

    /**
     * Issue 0044: an array size can be hex, and can use * and + (with *
     * binding tighter), matching the plain [n] form. 1+2*2 must be 5
     * elements, not 6.
     */
    @Test
    void arraySizeAcceptsHexAndArithmetic() throws IOException, URISyntaxException {
        assertDeflowered("arraysize");
    }

    /**
     * Issue 0044: a size of 0, from [...] or from a range too short to hold
     * one element ($c006-$c007 is one byte: the end is exclusive), is
     * reported as an error, and no output is written for that subject.
     */
    @Test
    void reportsZeroSizeAndSkipsOutput() throws IOException, URISyntaxException {
        String flowerFile = "zerosize/zerosize.flo";
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower(flowerFile);
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString())
                .contains("Zero-size byte at $C000")
                .contains("Zero-size word at $C006")
                .contains("Errors detected");
        assertThat(isEmpty(outDir(flowerFile))).as("output directory for a subject with a zero size").isTrue();
    }

    /**
     * Issue 0044: arithmetic lives only inside [ ]; the top-level n*m and
     * n+m forms are gone.
     */
    @Test
    void rejectsTopLevelMultiplier() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/top-level-multiplier.flo");
    }

    @Test
    void rejectsTopLevelPlus() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/top-level-plus.flo");
    }

    /**
     * Issue 0050: an annotation line has a fixed shape - address or
     * range, then optionally virtual, a type and a label, in that order
     * and each at most once - so anything else is a parse error instead
     * of silently keeping the last value or swallowing a stray word.
     */
    @Test
    void rejectsTwoLabelsOnOneLine() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/two-labels.flo");
    }

    @Test
    void rejectsTwoTypesOnOneLine() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/two-types.flo");
    }

    @Test
    void rejectsTwoAddressesOnOneLine() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/two-addresses.flo");
    }

    @Test
    void rejectsTypeAfterLabel() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/type-after-label.flo");
    }

    @Test
    void rejectsStrayWord() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/stray-word.flo");
    }

    @Test
    void rejectsLineWithoutAddress() throws IOException, URISyntaxException {
        assertFailsToParse("invalid/no-address.flo");
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
     * Issue 0017: the whole .flo file is parsed before any memory image is
     * loaded or annotated, so an annotation line before the first
     * 'deflower' line is reported up front (no NullPointerException, as in
     * issue 0009) and nothing is written.
     */
    @Test
    void rejectsAnnotationBeforeDeflowerLine() throws IOException, URISyntaxException {
        String flowerFile = "invalid/annotation-before-deflower.flo";
        ByteArrayOutputStream capturedErr = new ByteArrayOutputStream();
        PrintStream originalErr = System.err;
        System.setErr(new PrintStream(capturedErr));
        try {
            new Deflower().deflower(flowerFile);
        } finally {
            System.setErr(originalErr);
        }
        assertThat(capturedErr.toString()).contains("Start the file with a 'deflower <file>' line.");
        assertThat(isEmpty(outDir(flowerFile))).as("output directory for an annotation before 'deflower'").isTrue();
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
        assertThat(capturedErr.toString()).contains("Failed to parse");
        assertThat(isEmpty(outDir(flowerFile))).as("output directory for a file that failed to parse").isTrue();
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
