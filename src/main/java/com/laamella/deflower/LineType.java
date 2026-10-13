package com.laamella.deflower;

import static com.laamella.deflower.DataType.*;

enum LineType {
    SCREENCODE_LINE(SCREENCODE), ASCII_LINE(ASCII), BYTE_LINE(BYTE), CODE_LINE(null), WORD_LINE(WORD), LONG_LINE(LONG), DWORD_LINE(DWORD), ADDR_LINE(ADDR),
    SBYTE_LINE(SBYTE), SWORD_LINE(SWORD), SLONG_LINE(SLONG), SDWORD_LINE(SDWORD),
    /**
     * The default when a line has no explicit type keyword (issue
     * 0031) - a placeholder for memory that isn't understood yet,
     * printed as plain bytes but freely narrowable by any later,
     * more specific annotation.
     */
    UNKNOWN_LINE(UNKNOWN);
    final DataType dataType;

    LineType(DataType dataType) {
        this.dataType = dataType;
    }
}
