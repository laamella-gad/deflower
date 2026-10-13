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
    // True for a line from an included file (issue 0078): weak, so the
    // including file's own lines win over it.
    final boolean included;
    // The file this line's memory is exported to, like "font.bin" (issue
    // 0022), or null.
    final String export;
    // For a size like "char[until $ff]" (issue 0068): the value of the
    // last element. Null for a fixed size.
    final Integer terminator;
    // For a size like "char[lengthbyte]" (issue 0094): a length byte,
    // then that many elements.
    final boolean lengthByte;
    // A code line's parameter list (issue 0068), or null when it has none.
    final List<Parameter> parameters;
    // True for a code line marked "noreturn" (issue 0068).
    final boolean noReturn;

    Annotation(int address, Integer addressEnd, LineType type, boolean virtual, int amount, String name, List<String> comment, boolean included, String export) {
        this(address, addressEnd, type, virtual, amount, name, comment, included, export, null, false, null, false);
    }

    Annotation(int address, Integer addressEnd, LineType type, boolean virtual, int amount, String name, List<String> comment, boolean included, String export,
               Integer terminator, boolean lengthByte, List<Parameter> parameters, boolean noReturn) {
        this.address = address;
        this.addressEnd = addressEnd;
        this.type = type;
        this.virtual = virtual;
        this.amount = amount;
        this.name = name;
        this.comment = comment;
        this.included = included;
        this.export = export;
        this.terminator = terminator;
        this.lengthByte = lengthByte;
        this.parameters = parameters;
        this.noReturn = noReturn;
    }
}
