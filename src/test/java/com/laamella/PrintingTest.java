package com.laamella;

import org.junit.jupiter.api.Test;

import static com.laamella.Printing.asAddress;
import static com.laamella.Printing.asHexByte;
import static com.laamella.Printing.asHexDword;
import static com.laamella.Printing.asHexLong;
import static com.laamella.Printing.asHexWord;
import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class PrintingTest {
    @Test
    void asAddressFormatsValidValues() {
        assertThat(asAddress(0)).isEqualTo("$0000");
        assertThat(asAddress(0xFF)).isEqualTo("$00ff");
        assertThat(asAddress(0xFFFF)).isEqualTo("$ffff");
    }

    @Test
    void asAddressRejectsNegativeValues() {
        assertThatThrownBy(() -> asAddress(-1)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asAddressRejectsValuesAboveRange() {
        assertThatThrownBy(() -> asAddress(0x10000)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asHexByteFormatsValidValues() {
        assertThat(asHexByte(0)).isEqualTo("$00");
        assertThat(asHexByte(0x7F)).isEqualTo("$7f");
        assertThat(asHexByte(0xFF)).isEqualTo("$ff");
    }

    @Test
    void asHexByteRejectsNegativeValues() {
        assertThatThrownBy(() -> asHexByte(-1)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asHexByteRejectsValuesAboveRange() {
        assertThatThrownBy(() -> asHexByte(0x100)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asHexWordFormatsValidValues() {
        assertThat(asHexWord(0)).isEqualTo("$0000");
        assertThat(asHexWord(0xFF)).isEqualTo("$00ff");
        assertThat(asHexWord(0xFFFF)).isEqualTo("$ffff");
    }

    @Test
    void asHexWordRejectsNegativeValues() {
        assertThatThrownBy(() -> asHexWord(-1)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asHexWordRejectsValuesAboveRange() {
        assertThatThrownBy(() -> asHexWord(0x10000)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asHexLongFormatsValidValues() {
        assertThat(asHexLong(0)).isEqualTo("$000000");
        assertThat(asHexLong(0xFFFF)).isEqualTo("$00ffff");
        assertThat(asHexLong(0xFFFFFF)).isEqualTo("$ffffff");
    }

    @Test
    void asHexLongRejectsNegativeValues() {
        assertThatThrownBy(() -> asHexLong(-1)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asHexLongRejectsValuesAboveRange() {
        assertThatThrownBy(() -> asHexLong(0x1000000)).isInstanceOf(IllegalStateException.class);
    }

    @Test
    void asHexDwordFormatsValidValues() {
        assertThat(asHexDword(0)).isEqualTo("$00000000");
        assertThat(asHexDword(0x12345678)).isEqualTo("$12345678");
        assertThat(asHexDword(0x7FFFFFFF)).isEqualTo("$7fffffff");
    }

    @Test
    void asHexDwordRejectsNegativeValues() {
        assertThatThrownBy(() -> asHexDword(-1)).isInstanceOf(IllegalStateException.class);
    }
}
