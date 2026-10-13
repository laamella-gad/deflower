package com.laamella.deflower;

import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

/**
 * Searches the memory of a {@code .vsf} or {@code .prg} file (issue 0099).
 * A pattern of one number above $ff, or of one hex number with 3 or 4
 * digits, is an address: found as a little-endian word ({@code addr}), as
 * the address minus one ({@code rta}, as an {@code rts} dispatch table
 * holds it), and as its low and high byte at the same index in two tables
 * at most 256 bytes apart ({@code lo/hi}). Any other pattern is a sequence
 * of bytes. Memory the file doesn't load never matches.
 */
class Finder {
    private static final Pattern HEX_ADDRESS = Pattern.compile("\\$[0-9a-fA-F]{3,4}");
    private static final int CONTEXT = 8;
    private static final int MAX_TABLE_DISTANCE = 256;

    List<String> find(Path file, List<String> pattern, String range) throws IOException {
        int[] bounds = range == null ? new int[]{0, 0x10000} : Dumper.range(range);
        int[] memory = MemoryImage.read(file);
        List<String> lines = new ArrayList<>();
        if (pattern.size() == 1 && isAddress(pattern.get(0))) {
            int address = Dumper.number(pattern.get(0));
            if (address > 0xffff) {
                throw new IllegalArgumentException("Not an address: " + pattern.get(0));
            }
            for (int at = bounds[0]; at < bounds[1]; at++) {
                if (matches(memory, at, bounds[1], word(address))) {
                    lines.add(hit(memory, at, "addr"));
                }
                if (matches(memory, at, bounds[1], word(address - 1 & 0xffff))) {
                    lines.add(hit(memory, at, "rta"));
                }
            }
            lines.addAll(splitTables(memory, bounds, address));
            lines.sort(null);
        } else {
            int[] bytes = pattern.stream().mapToInt(Finder::byteValue).toArray();
            for (int at = bounds[0]; at < bounds[1]; at++) {
                if (matches(memory, at, bounds[1], bytes)) {
                    lines.add(hit(memory, at, "bytes"));
                }
            }
        }
        return lines;
    }

    /**
     * The low byte at {@code lo} and the high byte at {@code lo + distance},
     * for a distance of 2 to 256 (1 is a plain word). A neighbouring pair
     * at the same distance has to look like an entry of the same table:
     * its high byte within 1 of this one. Without that, any low byte with
     * the high byte somewhere after it would match. A high byte table often
     * repeats a byte, which matches at each distance, so one line lists
     * the high bytes of a low byte, runs as ranges (end exclusive).
     */
    private static List<String> splitTables(int[] memory, int[] bounds, int address) {
        List<String> lines = new ArrayList<>();
        int low = address & 0xff;
        int high = address >> 8;
        for (int lo = bounds[0]; lo < bounds[1]; lo++) {
            if (memory[lo] != low) {
                continue;
            }
            List<String> highs = new ArrayList<>();
            int runStart = -1;
            for (int distance = 2; distance <= MAX_TABLE_DISTANCE + 1; distance++) {
                int hi = lo + distance;
                boolean match = distance <= MAX_TABLE_DISTANCE && hi < bounds[1] && memory[hi] == high
                        && (sameTable(memory, bounds, lo - 1, distance, high) || sameTable(memory, bounds, lo + 1, distance, high));
                if (match && runStart < 0) {
                    runStart = hi;
                } else if (!match && runStart >= 0) {
                    highs.add(runStart == hi - 1 ? String.format("$%04x", runStart) : String.format("$%04x-$%04x", runStart, hi));
                    runStart = -1;
                }
            }
            if (!highs.isEmpty()) {
                lines.add(String.format("$%04x lo/hi  high byte at %s", lo, String.join(", ", highs)));
            }
        }
        return lines;
    }

    private static boolean sameTable(int[] memory, int[] bounds, int lo, int distance, int high) {
        int hi = lo + distance;
        return lo >= bounds[0] && hi < bounds[1] && memory[lo] >= 0 && memory[hi] >= 0
                && Math.abs(memory[hi] - high) <= 1;
    }

    private static boolean matches(int[] memory, int at, int end, int[] bytes) {
        if (at + bytes.length > end) {
            return false;
        }
        for (int i = 0; i < bytes.length; i++) {
            if (memory[at + i] != bytes[i]) {
                return false;
            }
        }
        return true;
    }

    /**
     * The address and kind of a hit, then the bytes from it on, as
     * {@code --dump} prints them.
     */
    private static String hit(int[] memory, int at, String kind) {
        StringBuilder line = new StringBuilder(String.format("$%04x %-6s", at, kind));
        for (int address = at; address < at + CONTEXT && address < memory.length; address++) {
            line.append(memory[address] < 0 ? " .." : String.format(" %02x", memory[address]));
        }
        return line.toString();
    }

    private static int[] word(int value) {
        return new int[]{value & 0xff, value >> 8};
    }

    private static boolean isAddress(String text) {
        return HEX_ADDRESS.matcher(text).matches() || !text.startsWith("$") && number(text) > 0xff;
    }

    private static int byteValue(String text) {
        int value = number(text);
        if (value > 0xff) {
            throw new IllegalArgumentException("Not a byte: " + text + ", an address is searched for on its own");
        }
        return value;
    }

    private static int number(String text) {
        try {
            return Dumper.number(text);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Not a number: " + text + ", expected e.g. $c540 or $a9 $00");
        }
    }
}
