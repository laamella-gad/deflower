package com.laamella.deflower;

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
