package com.laamella.vicevcf;

import java.nio.ByteBuffer;

import static com.laamella.ByteBufferAccess.getByte;
import static com.laamella.ByteBufferAccess.getByteArray;

public class C64MemModuleHandler implements ModuleHandler {
    @Override
    public C64MemModule handle(String name, Version version, byte[] moduleContentArray) {
        ByteBuffer moduleContent = ByteBuffer.wrap(moduleContentArray);
        if (name.equals("C64MEM")) {
            int cpuData = getByte(moduleContent);
            int cpuDir = getByte(moduleContent);
            int exrom = getByte(moduleContent);
            int game = getByte(moduleContent);
            byte[] ram = getByteArray(moduleContent, 0x10000);
            return new C64MemModule(name, version, cpuData, cpuDir, exrom, game, ram);
        }
        return null;
    }
}
