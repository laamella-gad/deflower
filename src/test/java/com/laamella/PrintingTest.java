package com.laamella;

import org.junit.jupiter.api.Test;

import static com.laamella.Printing.asAddress;
import static com.laamella.Printing.asHexByte;
import static com.laamella.Printing.asHexDword;
import static com.laamella.Printing.asHexWord;
import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertThrows;

class PrintingTest {
    @Test
    void asAddressFormatsValidValues() {
        assertEquals("$0000", asAddress(0));
        assertEquals("$00FF", asAddress(0xFF));
        assertEquals("$FFFF", asAddress(0xFFFF));
    }

    @Test
    void asAddressAdmitsOneAboveRange() {
        // Bug (issue 0012): the bounds check is `<= 0x10000`, one past the last valid address.
        assertEquals("$10000", asAddress(0x10000));
    }

    @Test
    void asAddressRejectsNegativeValues() {
        assertThrows(IllegalStateException.class, () -> asAddress(-1));
    }

    @Test
    void asAddressRejectsValuesAboveRange() {
        assertThrows(IllegalStateException.class, () -> asAddress(0x10001));
    }

    @Test
    void asHexByteFormatsValidValues() {
        assertEquals("$00", asHexByte(0));
        assertEquals("$7F", asHexByte(0x7F));
        assertEquals("$FF", asHexByte(0xFF));
    }

    @Test
    void asHexByteAdmitsOneAboveRange() {
        // Bug (issue 0012): the bounds check is `<= 0x100`, one past the last valid byte.
        assertEquals("$100", asHexByte(0x100));
    }

    @Test
    void asHexByteRejectsNegativeValues() {
        assertThrows(IllegalStateException.class, () -> asHexByte(-1));
    }

    @Test
    void asHexByteRejectsValuesAboveRange() {
        assertThrows(IllegalStateException.class, () -> asHexByte(0x101));
    }

    @Test
    void asHexWordFormatsValidValues() {
        assertEquals("$0000", asHexWord(0));
        assertEquals("$00FF", asHexWord(0xFF));
        assertEquals("$FFFF", asHexWord(0xFFFF));
    }

    @Test
    void asHexWordAdmitsOneAboveRange() {
        // Bug (issue 0012): the bounds check is `<= 0x10000`, one past the last valid word.
        assertEquals("$10000", asHexWord(0x10000));
    }

    @Test
    void asHexWordRejectsNegativeValues() {
        assertThrows(IllegalStateException.class, () -> asHexWord(-1));
    }

    @Test
    void asHexWordRejectsValuesAboveRange() {
        assertThrows(IllegalStateException.class, () -> asHexWord(0x10001));
    }

    @Test
    void asHexDwordFormatsValidValues() {
        assertEquals("$00000000", asHexDword(0));
        assertEquals("$12345678", asHexDword(0x12345678));
        assertEquals("$7FFFFFFF", asHexDword(0x7FFFFFFF));
    }

    @Test
    void asHexDwordRejectsNegativeValues() {
        assertThrows(IllegalStateException.class, () -> asHexDword(-1));
    }
}
