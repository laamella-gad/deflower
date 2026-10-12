package com.laamella.deflower;

import java.util.List;

/**
 * One annotation line of a {@code .flo} file, as parsed: what to mark at
 * which address. Applied to memory by {@link Subject#annotate}.
 */
final class Annotation {
    final int address;
    // The (exclusive) end of a memory range like "$2800-$2ff9", or null
    // when the line gives a single address.
    final Integer addressEnd;
    final LineType type;
    final boolean virtual;
    // The number of elements: an array size like "byte[8]" or
    // "byte[40*21]". Ignored when addressEnd is given.
    final int amount;
    final String name;
    // The standalone comment lines right above this line, if any.
    final List<String> comment;

    Annotation(int address, Integer addressEnd, LineType type, boolean virtual, int amount, String name, List<String> comment) {
        this.address = address;
        this.addressEnd = addressEnd;
        this.type = type;
        this.virtual = virtual;
        this.amount = amount;
        this.name = name;
        this.comment = comment;
    }
}
