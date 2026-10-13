package com.laamella.deflower;

import static com.laamella.Printing.asHexWord;

/**
 * A suspect spot the analysis found (issue 0077), printed after the run as
 * "warning: $addr: text".
 */
final class Warning {
    final int address;
    final String text;

    Warning(int address, String text) {
        this.address = address;
        this.text = text;
    }

    @Override
    public String toString() {
        return "warning: " + asHexWord(address) + ": " + text;
    }
}
