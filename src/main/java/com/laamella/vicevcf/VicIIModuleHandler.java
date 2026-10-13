package com.laamella.vicevcf;

/**
 * Reads the registers from a {@code VIC-II} module of version 1.3, as
 * written by x64sc in VICE 3.x: one byte, then the 64 registers. Other
 * versions, like x64's 1.1, have another layout and are left unhandled.
 */
public class VicIIModuleHandler implements ModuleHandler {
    @Override
    public VicIIModule handle(String name, Version version, byte[] moduleContentArray) {
        if (!name.equals("VIC-II") || version.major != 1 || version.minor != 3) {
            return null;
        }
        int[] registers = new int[0x40];
        for (int i = 0; i < registers.length; i++) {
            registers[i] = moduleContentArray[1 + i] & 0xff;
        }
        return new VicIIModule(name, version, registers);
    }
}
