package com.laamella;

import static com.laamella.Assert.*;

public class Printing {
    public static String asAddress(int address) {
        assertState(address >= 0 && address <= 0xFFFF, "Invalid address %d", address);
        return String.format("$%04X", address);
    }

    public static String asHexByte(int value) {
        assertState(value >= 0 && value <= 0xFF, "Invalid byte %d", value);
        return String.format("$%02X", value);
    }

    public static String asHexWord(int value) {
        assertState(value >= 0 && value <= 0xFFFF, "Invalid word %d", value);
        return String.format("$%04X", value);
    }

    public static String asHexDword(int value) {
        assertState(value >= 0 && value <= 0xFFFFFFFFL, "Invalid dword %d", value);
        return String.format("$%08X", value);
    }
}
