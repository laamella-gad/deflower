package com.laamella.vicevcf;

/**
 * The CPU registers from a {@code MAINCPU} module.
 */
public class MainCpuModule extends Module {
    public final int a;
    public final int x;
    public final int y;
    public final int sp;
    public final int pc;
    public final int status;

    public MainCpuModule(String name, Version version, int a, int x, int y, int sp, int pc, int status) {
        super(name, version);
        this.a = a;
        this.x = x;
        this.y = y;
        this.sp = sp;
        this.pc = pc;
        this.status = status;
    }
}
