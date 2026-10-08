package com.laamella.deflower;

import java.util.Objects;

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

    /**
     * Two areas are equal when they describe the same memory the same way
     * (same kind, address, size, and whatever else a subclass adds), so a
     * redundant re-annotation isn't flagged as a conflict in
     * {@link Subject#registerBlock}.
     */
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Area other = (Area) o;
        return address == other.address && size == other.size;
    }

    @Override
    public int hashCode() {
        return Objects.hash(getClass(), address, size);
    }

    public abstract String labelFor(int address, Subject subject);
}
