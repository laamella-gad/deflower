package com.laamella.deflower;

import java.util.List;

/**
 * What a code line says about calls to its address (issue 0068): the
 * data that follows each jsr to it, and whether the call returns at all.
 */
final class Routine {
    final List<Parameter> parameters;
    // True when a jsr to the routine doesn't return: nothing after the
    // call (or after its data) is traced.
    final boolean noReturn;

    Routine(List<Parameter> parameters, boolean noReturn) {
        this.parameters = parameters;
        this.noReturn = noReturn;
    }
}
