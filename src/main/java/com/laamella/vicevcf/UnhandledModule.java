package com.laamella.vicevcf;

public class UnhandledModule extends Module {
    public final byte[] data;

    public UnhandledModule(String moduleType, Version version, byte[] data) {
        super(moduleType, version);
        this.data = data;
    }
}
