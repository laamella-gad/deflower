package com.laamella.vicevcf;

import java.util.List;
import java.util.Optional;

public class ViceVcfFile {
    public final Header header;
    public final List<Module> modules;

    public ViceVcfFile(Header header, List<Module> modules) {
        this.header = header;
        this.modules = modules;
    }

    /**
     * The module with this name, if a handler read it as this class.
     */
    public <T extends Module> Optional<T> module(String moduleType, Class<T> moduleClass) {
        return modules.stream()
                .filter(module -> module.moduleType.equals(moduleType))
                .filter(moduleClass::isInstance)
                .map(moduleClass::cast)
                .findAny();
    }

    @Override
    public String toString() {
        return "Vice VCF: " + header + " " + modules;
    }
}
