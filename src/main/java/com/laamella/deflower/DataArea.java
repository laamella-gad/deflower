package com.laamella.deflower;

import java.util.Objects;

class DataArea extends Area {
    final DataType type;
    boolean isSystem;

    DataArea(int address, DataType type, boolean isSystem) {
        super(address, type.sizeInBytes);
        this.type = type;
        this.isSystem = isSystem;
    }

    @Override
    public String toString() {
        return super.toString() + " " + type.name().toLowerCase() + (isSystem ? " system" : "");
    }

    @Override
    public boolean equals(Object o) {
        if (!super.equals(o)) return false;
        DataArea other = (DataArea) o;
        return type == other.type && isSystem == other.isSystem;
    }

    @Override
    public int hashCode() {
        return Objects.hash(super.hashCode(), type, isSystem);
    }

    @Override
    public boolean isPlaceholder() {
        return type == DataType.UNKNOWN;
    }

    /**
     * An array annotation (issue 0024) registers one single-element
     * DataArea per index, so a mid-block address's own area never carries
     * the block's label - only the first element does. Walk backwards
     * through same-type, same-system DataAreas until a label turns up (or
     * the run breaks), so "STA $422" into a `byte[1000] screen` block
     * starting at $400 resolves to "screen + $22" instead of falling back
     * to a bare hex address.
     */
    @Override
    public String labelFor(int address, Subject subject) {
        int blockAddress = address;
        while (subject.memory[blockAddress].label == null && sameKindAt(blockAddress - 1, subject)) {
            blockAddress--;
        }
        String label = subject.memory[blockAddress].label;
        if (label == null) {
            return null;
        }
        int offset = address - blockAddress;
        if (offset == 0) {
            return label;
        }
        return String.format("%s + $%X", label, offset);
    }

    private boolean sameKindAt(int address, Subject subject) {
        if (address < 0) {
            return false;
        }
        Area other = subject.memory[address].area;
        return other instanceof DataArea && ((DataArea) other).type == type && ((DataArea) other).isSystem == isSystem;
    }
}
