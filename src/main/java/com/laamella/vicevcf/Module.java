package com.laamella.vicevcf;

public abstract class Module {
    private final String moduleType;
    private final Version version;

    protected Module(String moduleType, Version version) {
        this.moduleType = moduleType;
        this.version = version;
    }

    @Override
    public String toString() {
        return moduleType + " " + version;
    }
}
