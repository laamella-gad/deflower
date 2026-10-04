package com.laamella.vicevcf;

public class Header {
    public final String machineName;
    public final Version version;

    public Header(String machineName, Version version) {
        this.machineName = machineName;
        this.version = version;
    }

    @Override
    public String toString() {
        return machineName + " " + version;
    }
}
