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

    /**
     * True for an area that only marks memory as "not yet understood" -
     * i.e. a {@code .flo} line with no explicit type keyword (issue 0031).
     * A placeholder may be silently narrowed by any later, more specific
     * annotation ({@link Subject#registerBlock}), and {@link FlowAnalyser}
     * may decode straight through one instead of refusing as it would for
     * a deliberate area.
     */
    public boolean isPlaceholder() {
        return false;
    }

    /**
     * True for an area declared {@code virtual} in the {@code .flo} file:
     * memory the code uses but whose contents aren't part of the program
     * (I/O registers, screen/colour RAM, zero-page variables, ...). Its
     * contents are never dumped; it's emitted as a 64tass {@code .virtual}
     * reservation instead, keeping its labels, type and size (issues
     * 0045, 0046).
     */
    public boolean isVirtual() {
        return false;
    }

    public abstract String labelFor(int address, Subject subject);
}
