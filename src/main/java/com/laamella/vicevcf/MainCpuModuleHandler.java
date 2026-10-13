package com.laamella.vicevcf;

import java.nio.ByteBuffer;

import static com.laamella.ByteBufferAccess.getByte;
import static com.laamella.ByteBufferAccess.readWord;

/**
 * Reads the registers of a {@code MAINCPU} module. The module starts with
 * the clock: 4 bytes in version 1.1 (VICE 1.x), 8 bytes in version 1.4
 * (VICE 3.x). Other versions are left unhandled.
 */
public class MainCpuModuleHandler implements ModuleHandler {
    @Override
    public MainCpuModule handle(String name, Version version, byte[] moduleContentArray) {
        if (!name.equals("MAINCPU") || version.major != 1) {
            return null;
        }
        int clockSize;
        if (version.minor == 1) {
            clockSize = 4;
        } else if (version.minor == 4) {
            clockSize = 8;
        } else {
            return null;
        }
        ByteBuffer moduleContent = ByteBuffer.wrap(moduleContentArray);
        moduleContent.position(clockSize);
        int a = getByte(moduleContent);
        int x = getByte(moduleContent);
        int y = getByte(moduleContent);
        int sp = getByte(moduleContent);
        int pc = readWord(moduleContent);
        int status = getByte(moduleContent);
        return new MainCpuModule(name, version, a, x, y, sp, pc, status);
    }
}
