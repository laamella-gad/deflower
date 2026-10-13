package com.laamella.vicevcf;

import java.nio.ByteBuffer;

import static com.laamella.ByteBufferAccess.getByte;

/**
 * Reads a {@code CIA1} or {@code CIA2} module of version 2.x: the ports,
 * their data directions, the timers (4 bytes), the time of day (4 bytes),
 * the serial data register and then the interrupt mask. Other versions are
 * left unhandled.
 */
public class CiaModuleHandler implements ModuleHandler {
    @Override
    public CiaModule handle(String name, Version version, byte[] moduleContentArray) {
        if (!(name.equals("CIA1") || name.equals("CIA2")) || version.major != 2) {
            return null;
        }
        ByteBuffer moduleContent = ByteBuffer.wrap(moduleContentArray);
        int portA = getByte(moduleContent);
        int portB = getByte(moduleContent);
        int directionA = getByte(moduleContent);
        int directionB = getByte(moduleContent);
        moduleContent.position(13);
        int interruptMask = getByte(moduleContent);
        return new CiaModule(name, version, portA, portB, directionA, directionB, interruptMask);
    }
}
