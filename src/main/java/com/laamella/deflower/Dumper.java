package com.laamella.deflower;

import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Hex-dumps a memory range of a {@code .vsf} or {@code .prg} file (issue
 * 0097): 16 bytes a line, from the start of the range, then the bytes as
 * PETSCII and as screen codes, to spot text. Both text columns read the
 * bytes with the lower/upper character set and show every character that
 * has a printable counterpart, graphics as dots. Memory the file doesn't
 * load shows as {@code ..}.
 */
class Dumper {
    // A range as in a .flo file, end exclusive: $c540-$c560 or 49472-49504.
    private static final Pattern RANGE = Pattern.compile("(\\$[0-9a-fA-F]+|[0-9]+)-(\\$[0-9a-fA-F]+|[0-9]+)");
    private static final int BYTES_PER_LINE = 16;

    List<String> dump(Path file, String range) throws IOException {
        int[] bounds = range(range);
        int start = bounds[0];
        int end = bounds[1];
        int[] memory = MemoryImage.read(file);
        List<String> lines = new ArrayList<>();
        for (int line = start; line < end; line += BYTES_PER_LINE) {
            StringBuilder hex = new StringBuilder(String.format("%04x:", line));
            StringBuilder petscii = new StringBuilder();
            StringBuilder screenCodes = new StringBuilder();
            for (int address = line; address < line + BYTES_PER_LINE; address++) {
                if (address >= end) {
                    hex.append("   ");
                    petscii.append(' ');
                } else if (memory[address] < 0) {
                    hex.append(" ..");
                    petscii.append(' ');
                    screenCodes.append(' ');
                } else {
                    int value = memory[address];
                    hex.append(String.format(" %02x", value));
                    petscii.append(petscii(value));
                    screenCodes.append(screenCode(value));
                }
            }
            lines.add((hex + "  " + petscii + "  " + screenCodes).stripTrailing());
        }
        return lines;
    }

    /**
     * The lower/upper character set's characters that have a printable
     * counterpart, from screen code $00 to $3f; graphics are dots. The
     * set holds lowercase letters at $01-$1a and uppercase at $41-$5a.
     */
    private static final String SCREEN_CODES =
            "@abcdefghijklmnopqrstuvwxyz[\u00a3]\u2191\u2190 !\"#$%&'()*+,-./0123456789:;<=>?";

    /**
     * A PETSCII byte as the lower/upper character set shows it, or a dot
     * for a control code or a graphic.
     */
    static char petscii(int value) {
        char character = petsciiCharacter(value);
        return character == 0 ? '.' : character;
    }

    /**
     * A PETSCII byte as the lower/upper character set shows it, or 0 for
     * a control code or a graphic.
     */
    static char petsciiCharacter(int value) {
        if (value >= 0x20 && value <= 0x3f) {
            return SCREEN_CODES.charAt(value);
        }
        if (value >= 0x40 && value <= 0x5f) {
            return SCREEN_CODES.charAt(value - 0x40);
        }
        if (value >= 0x61 && value <= 0x7a || value >= 0xc1 && value <= 0xda) {
            return (char) ((value & 0x1f) - 1 + 'A');
        }
        return value == 0xa0 || value == 0xe0 ? ' ' : 0;
    }

    /**
     * A screen code as the lower/upper character set shows it, reversed
     * or not, or a dot for a graphic.
     */
    static char screenCode(int value) {
        char character = screenCodeCharacter(value & 0x7f);
        return character == 0 ? '.' : character;
    }

    /**
     * A screen code as the lower/upper character set shows it, or 0 for
     * a graphic or a reversed character.
     */
    static char screenCodeCharacter(int value) {
        if (value >= 0x80) {
            return 0;
        }
        if (value < 0x40) {
            return SCREEN_CODES.charAt(value);
        }
        if (value >= 0x41 && value <= 0x5a) {
            return (char) (value - 0x41 + 'A');
        }
        return value == 0x60 ? ' ' : 0;
    }

    /**
     * A range as in a .flo file, end exclusive, as {start, end}.
     */
    static int[] range(String range) {
        Matcher matcher = RANGE.matcher(range);
        if (!matcher.matches()) {
            throw new IllegalArgumentException("Not a range: " + range + ", expected e.g. $c540-$c560");
        }
        int start = number(matcher.group(1));
        int end = number(matcher.group(2));
        if (start >= end || end > 0x10000) {
            throw new IllegalArgumentException("Not a range inside $0000-$10000: " + range);
        }
        return new int[]{start, end};
    }

    static int number(String text) {
        return text.startsWith("$") ? Integer.parseInt(text.substring(1), 16) : Integer.parseInt(text);
    }
}
