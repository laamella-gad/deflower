package com.laamella.deflower;

/**
 * Memory a {@code .flo} line exports to a binary file of its own (issue
 * 0022): written to {@code out/<name>}, and included in the generated
 * assembly with {@code .binary} instead of being printed as data. A
 * {@code .prg} file starts with the region's start address as its load
 * address.
 */
final class ExportRegion {
    final String fileName;
    final int start;
    // Exclusive.
    final int end;

    ExportRegion(String fileName, int start, int end) {
        this.fileName = fileName;
        this.start = start;
        this.end = end;
    }

    /**
     * The size of the load address header in front of the bytes: 2 for a
     * {@code .prg} file, 0 for a plain binary.
     */
    int headerSize() {
        return fileName.endsWith(".prg") ? 2 : 0;
    }
}
