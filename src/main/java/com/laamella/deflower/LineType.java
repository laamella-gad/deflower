package com.laamella.deflower;

import static com.laamella.deflower.DataType.*;

enum LineType {
    CHAR_BLOCK(CHAR), BYTE_BLOCK(BYTE), CODE_ENTRY(null), WORD_BLOCK(WORD), DWORD_BLOCK(DWORD), ADDR_BLOCK(POINTER),
    /**
     * The default when a line has no explicit type keyword (issue
     * 0031) - a placeholder for memory that isn't understood yet,
     * printed as plain bytes but freely narrowable by any later,
     * more specific annotation.
     */
    UNKNOWN_BLOCK(UNKNOWN);
    final DataType dataType;

    LineType(DataType dataType) {
        this.dataType = dataType;
    }
}
