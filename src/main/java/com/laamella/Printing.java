package com.laamella;

import static com.laamella.Assert.*;

public class Printing {
    public static String asAddress(int address) {
        assertState(address >= 0 && address <= 0x10000, "Invalid address %d", address);
        return String.format("$%04X", address);
    }

    public static String asHexByte(int value) {
        assertState(value >= 0 && value <= 0x100, "Invalid byte %d", value);
        return String.format("$%02X", value);
    }

    public static String asHexWord(int value) {
        assertState(value >= 0 && value <= 0x10000, "Invalid word %d", value);
        return String.format("$%04X", value);
    }

    public static String asHexDword(int value) {
        assertState(value >= 0 && value <= 0xFFFFFFFF, "Invalid dword %d", value);
        return String.format("$%08X", value);
    }
}
