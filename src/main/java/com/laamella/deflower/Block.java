package com.laamella.deflower;

import static com.laamella.Printing.asAddress;

abstract class Block {
    final int address;
    final int size;
    final int lastOccupiedAddress;

    Block(int address, int size) {
        this.address = address;
        this.size = size;
        this.lastOccupiedAddress = address + size - 1;
    }

    @Override
    public String toString() {
        return asAddress(address) + " " + size;
    }
}
