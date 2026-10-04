package com.laamella.deflower;

public enum DataType {
    CHAR(1), BYTE(1), WORD(2), DWORD(4), POINTER(2);

    final int sizeInBytes;

    DataType(int sizeInBytes) {
        this.sizeInBytes = sizeInBytes;
    }
}
