package com.laamella.deflower;

class DataBlock extends Block {
    final DataType type;
    boolean isSystem;

    DataBlock(int address, DataType type, boolean isSystem) {
        super(address, type.sizeInBytes);
        this.type = type;
        this.isSystem = isSystem;
    }

    @Override
    public String toString() {
        return super.toString() + " " + type.name().toLowerCase() + (isSystem ? " system" : "");
    }
}
