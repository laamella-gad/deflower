package com.laamella.vicevcf;

public class Version {
    public final byte major;
    public final byte minor;

    public Version(byte major, byte minor) {
        this.major = major;
        this.minor = minor;
    }

    @Override
    public String toString() {
        return major + "." + minor;
    }
}
