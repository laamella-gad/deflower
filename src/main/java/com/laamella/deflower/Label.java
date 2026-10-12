package com.laamella.deflower;

/**
 * The label on one address: its name, and whether it is local, an auto
 * label on a branch or jmp target that no jsr calls - a place inside a
 * routine rather than the start of one (issue 0084) - and whether it
 * came from an included file.
 */
final class Label {
    final String name;
    final boolean local;
    // True for a label from an included file (issue 0078).
    final boolean included;

    Label(String name, boolean local) {
        this(name, local, false);
    }

    Label(String name, boolean local, boolean included) {
        this.name = name;
        this.local = local;
        this.included = included;
    }
}
