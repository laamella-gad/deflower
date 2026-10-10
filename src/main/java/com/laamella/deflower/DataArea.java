package com.laamella.deflower;

import java.util.Objects;

class DataArea extends Area {
    final DataType type;
    final boolean virtual;
    // The label of the array this element belongs to (null if the .flo
    // line that declared it had no name), and this element's index within
    // that array. Baked in at creation time (issue 0033) so labelFor can
    // compute a reference directly instead of scanning neighboring
    // MemoryLocations for the nearest label - which depended on whichever
    // Area objects happened to still be sitting next door, and broke down
    // across a partial overwrite (issue 0031's placeholder-carving).
    final String arrayLabel;
    final int indexInArray;

    DataArea(int address, DataType type, boolean isVirtual, String arrayLabel, int indexInArray) {
        super(address, type.sizeInBytes);
        this.type = type;
        this.virtual = isVirtual;
        this.arrayLabel = arrayLabel;
        this.indexInArray = indexInArray;
    }

    @Override
    public String toString() {
        return super.toString() + " " + type.name().toLowerCase() + (virtual ? " virtual" : "");
    }

    @Override
    public boolean equals(Object o) {
        if (!super.equals(o)) return false;
        DataArea other = (DataArea) o;
        return type == other.type && virtual == other.virtual;
    }

    @Override
    public int hashCode() {
        return Objects.hash(super.hashCode(), type, virtual);
    }

    @Override
    public boolean isVirtual() {
        return virtual;
    }

    @Override
    public boolean isPlaceholder() {
        return type == DataType.UNKNOWN;
    }

    /**
     * The address of the first element of the array this element belongs to.
     */
    int arrayStart() {
        return address - indexInArray * size;
    }

    /**
     * True when `area` is element `index` of the same array as this one.
     */
    boolean isInSameArray(Area area, int index) {
        return area instanceof DataArea
                && ((DataArea) area).type == type
                && ((DataArea) area).indexInArray == index
                && Objects.equals(((DataArea) area).arrayLabel, arrayLabel);
    }

    /**
     * An array annotation (issue 0024) registers one single-element
     * DataArea per index (issue 0033), each one already knowing its own
     * array label and index, so "STA $422" into a `byte[1000] screen`
     * block starting at $400 resolves to "screen + $22" by direct
     * computation - no scanning through neighboring MemoryLocations for
     * the nearest label. `address` may differ from this element's own
     * address when it lands on a later byte of a multi-byte element
     * (e.g. the second byte of a WORD).
     * <p>
     * A label set directly on this exact address - via the .flo line's
     * own name, or an auto-label like {@code ensureLabelled} assigns
     * (`aXXXX`, `dXXXX`) - always wins outright: those don't
     * go through the array mechanism at all (`FlowAnalyser`'s ADDR
     * areas, for instance, have no arrayLabel). Only once that's absent
     * do we fall back to the baked-in array reference.
     */
    @Override
    public String labelFor(int address, Subject subject) {
        String directLabel = subject.memory[address].label;
        if (directLabel != null) {
            return directLabel;
        }
        if (arrayLabel == null) {
            return null;
        }
        int offset = indexInArray * size + (address - this.address);
        if (offset == 0) {
            return arrayLabel;
        }
        return String.format("%s + $%X", arrayLabel, offset);
    }
}
