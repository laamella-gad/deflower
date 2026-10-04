package com.laamella.vicevcf;

import java.util.List;

public class ViceVcfFile {
    public final Header header;
    public final List<Module> modules;

    public ViceVcfFile(Header header, List<Module> modules) {
        this.header = header;
        this.modules = modules;
    }

    @Override
    public String toString() {
        return "Vice VCF: " + header + " " + modules;
    }
}
