package com.laamella.vicevcf;

/**
 * The registers {@code $d000-$d03f} from a {@code VIC-II} module, as last
 * written.
 */
public class VicIIModule extends Module {
    public final int[] registers;

    public VicIIModule(String name, Version version, int[] registers) {
        super(name, version);
        this.registers = registers;
    }
}
