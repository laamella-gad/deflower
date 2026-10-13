package com.laamella.vicevcf;

/**
 * The registers of interest from a {@code CIA1} or {@code CIA2} module.
 */
public class CiaModule extends Module {
    public final int portA;
    public final int portB;
    public final int directionA;
    public final int directionB;
    /**
     * The interrupt sources that are enabled: bit 0 timer A, 1 timer B,
     * 2 the TOD alarm, 3 the serial port, 4 the FLAG line.
     */
    public final int interruptMask;

    public CiaModule(String name, Version version, int portA, int portB, int directionA, int directionB, int interruptMask) {
        super(name, version);
        this.portA = portA;
        this.portB = portB;
        this.directionA = directionA;
        this.directionB = directionB;
        this.interruptMask = interruptMask;
    }
}
