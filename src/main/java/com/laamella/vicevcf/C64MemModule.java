package com.laamella.vicevcf;

public class C64MemModule extends Module {
    public final int cpuData;
    public final int cpuDir;
    public final int exrom;
    public final int game;
    public final byte[] ram;

    public C64MemModule(String name, Version version, int cpuData, int cpuDir, int exrom, int game, byte[] ram) {
        super(name, version);
        this.cpuData = cpuData;
        this.cpuDir = cpuDir;
        this.exrom = exrom;
        this.game = game;
        this.ram = ram;
    }
}
