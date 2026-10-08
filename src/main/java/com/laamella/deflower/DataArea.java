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
    public String labelFor(int address, Subject subject) {
        int offset = address - this.address;
        String label = subject.memory[this.address].label;
        if (label == null) {
            return null;
        }
        if (offset == 0) {
            return label;
        }
        return String.format("%s + %d", label, offset);
    }
}
