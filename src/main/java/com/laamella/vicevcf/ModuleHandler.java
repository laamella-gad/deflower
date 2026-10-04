package com.laamella.vicevcf;

public interface ModuleHandler {
    Module handle(String name, Version version, byte[] vcfFileContents);
}
