package com.laamella.deflower;

import static com.laamella.Printing.asAddress;

abstract class Area {
    final int address;
    final int size;
    final int lastOccupiedAddress;

    Area(int address, int size) {
        this.address = address;
        this.size = size;
        this.lastOccupiedAddress = address + size - 1;
    }

    @Override
    public String toString() {
        return asAddress(address) + " " + size;
    }

    public abstract String labelFor(int address, Subject subject);
}
