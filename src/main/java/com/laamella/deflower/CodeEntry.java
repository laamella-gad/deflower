package com.laamella.deflower;

/**
 * An address to trace from, and where the flow came from (issue 0077):
 * the instruction that jumps, branches or calls there, or falls through to
 * it, or -1 for a .flo code line.
 */
final class CodeEntry {
    final int address;
    final int from;
    final boolean fallsThrough;

    CodeEntry(int address, int from, boolean fallsThrough) {
        this.address = address;
        this.from = from;
        this.fallsThrough = fallsThrough;
    }
}
