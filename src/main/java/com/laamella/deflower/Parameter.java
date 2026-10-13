package com.laamella.deflower;

/**
 * One parameter in a routine's parameter list (issue 0068): data that
 * follows each jsr to the routine, like {@code char[until $ff] text}.
 */
final class Parameter {
    final DataType type;
    // The number of elements, when the size is fixed.
    final int amount;
    // The value of the last element, for a size like "until $ff": the
    // data runs up to and including the first element that equals it.
    // Null for a fixed size.
    final Integer terminator;
    // True for a size like "char[lengthbyte]" (issue 0094): a length
    // byte, then that many elements.
    final boolean lengthByte;
    // Null when the parameter has no name.
    final String name;

    Parameter(DataType type, int amount, Integer terminator, boolean lengthByte, String name) {
        this.type = type;
        this.amount = amount;
        this.terminator = terminator;
        this.lengthByte = lengthByte;
        this.name = name;
    }
}
