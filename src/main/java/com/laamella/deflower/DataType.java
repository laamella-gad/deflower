package com.laamella.deflower;

public enum DataType {
    /**
     * Text (issue 0094) in Commodore screen codes (64tass's "screen") and
     * in Commodore ASCII (64tass's "none").
     */
    SCREENCODE(1), ASCII(1),
    BYTE(1), WORD(2), LONG(3), DWORD(4), ADDR(2),
    /**
     * A return address (issue 0038): an address minus one, as an rts
     * dispatch table holds it, printed as 64tass's {@code .rta}. The
     * address it returns to is traced as code.
     */
    RTA(2),
    /**
     * Signed (two's-complement) numbers (issue 0037), printed as 64tass's
     * {@code .char}, {@code .sint}, {@code .lint} (issue 0064) and
     * {@code .dint}.
     */
    SBYTE(1), SWORD(2), SLONG(3), SDWORD(4),
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
