package com.laamella.deflower;

public enum DataType {
    BYTE(1), WORD(2), DWORD(4), POINTER(2);

    int sizeInBytes;

    DataType(int sizeInBytes) {
        this.sizeInBytes = sizeInBytes;
    }
}
