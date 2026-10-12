package com.laamella.deflower;

/**
 * The label on one address: its name, and whether it is local, an auto
 * label on a branch or jmp target that no jsr calls - a place inside a
 * routine rather than the start of one (issue 0084).
 */
final class Label {
    final String name;
    final boolean local;

    Label(String name, boolean local) {
        this.name = name;
        this.local = local;
    }
}
