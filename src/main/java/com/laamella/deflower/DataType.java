package com.laamella.deflower;

public enum DataType {
    CHAR(1), BYTE(1), WORD(2), DWORD(4), ADDR(2),
    /**
     * Signed (two's-complement) numbers (issue 0037), printed as 64tass's
     * {@code .char}, {@code .sint} and {@code .dint}.
     */
    SBYTE(1), SWORD(2), SDWORD(4),
    /**
     * A placeholder for memory that isn't understood yet (issue 0031): a
     * {@code .flo} line with no explicit type keyword. Prints exactly like
     * {@link #BYTE}, but {@link Area#isPlaceholder()} marks it as fair
     * game for any later, more specific annotation to silently narrow.
     */
    UNKNOWN(1);

    final int sizeInBytes;

    DataType(int sizeInBytes) {
        this.sizeInBytes = sizeInBytes;
    }
}
