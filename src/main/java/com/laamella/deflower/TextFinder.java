package com.laamella.deflower;

import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.function.IntFunction;

/**
 * Lists the stretches of memory of a {@code .vsf} or {@code .prg} file that
 * read as text (issue 0100), in PETSCII ({@code ascii} in a .flo file) and
 * in screen codes ({@code screencode}), with the characters {@code --dump}
 * shows. A stretch has at least 6 characters besides spaces (or the
 * minimum asked for), at least half of them letters and at least half of
 * them different, with the letters in one case apart from a capital at the
 * start of a word; spaces at either end are left out. Shorter or looser
 * stretches are mostly bytes of code, tables and graphics. A stretch followed by
 * $00 or $ff prints as {@code [until $xx]}, one preceded by its length as
 * {@code [lengthbyte]}, so the line can be pasted into a .flo file. Reversed
 * screen codes don't count: the {@code screencode} type can't print them.
 */
class TextFinder {
    static final int MIN_CHARACTERS = 6;

    List<String> find(Path file, String range, int minimum) throws IOException {
        if (minimum < 1) {
            throw new IllegalArgumentException("Not a minimum length: " + minimum);
        }
        int[] bounds = range == null ? new int[]{0, 0x10000} : Dumper.range(range);
        int[] memory = MemoryImage.read(file);
        List<String> lines = new ArrayList<>();
        find(memory, bounds, minimum, "ascii", Dumper::petsciiCharacter, lines);
        find(memory, bounds, minimum, "screencode", Dumper::screenCodeCharacter, lines);
        lines.sort(null);
        return lines;
    }

    private static void find(int[] memory, int[] bounds, int minimum, String type, IntFunction<Character> decode, List<String> lines) {
        int at = bounds[0];
        while (at < bounds[1]) {
            int end = at;
            while (end < bounds[1] && character(memory, end, decode) != 0) {
                end++;
            }
            if (end > at) {
                text(memory, at, end, bounds, minimum, type, decode).ifPresent(lines::add);
                at = end;
            } else {
                at++;
            }
        }
    }

    private static Optional<String> text(int[] memory, int start, int end, int[] bounds, int minimum, String type, IntFunction<Character> decode) {
        boolean trimmedEnd = false;
        while (start < end && character(memory, start, decode) == ' ') {
            start++;
        }
        while (end > start && character(memory, end - 1, decode) == ' ') {
            end--;
            trimmedEnd = true;
        }
        StringBuilder text = new StringBuilder();
        int characters = 0;
        int letters = 0;
        for (int address = start; address < end; address++) {
            char character = character(memory, address, decode);
            text.append(character);
            if (character != ' ') {
                characters++;
            }
            if (Character.isLetter(character)) {
                letters++;
            }
        }
        long distinct = text.chars().filter(character -> character != ' ').distinct().count();
        if (characters < minimum || letters * 2 < characters || distinct * 2 < characters || !oneCase(text)) {
            return Optional.empty();
        }
        String quoted = "\"" + text + "\"";
        if (!trimmedEnd && end < bounds[1] && (memory[end] == 0x00 || memory[end] == 0xff)) {
            return Optional.of(String.format("$%04x %s[until $%02x]  %s", start, type, memory[end], quoted));
        }
        if (start > bounds[0] && memory[start - 1] == end - start) {
            return Optional.of(String.format("$%04x %s[lengthbyte]  %s", start - 1, type, quoted));
        }
        return Optional.of(String.format("$%04x-$%04x %s  %s", start, end, type, quoted));
    }

    /**
     * Whether the letters share one case, apart from a capital at the start
     * of a word. Bytes of code and tables mix the cases at random.
     */
    private static boolean oneCase(CharSequence text) {
        int lower = 0;
        int upper = 0;
        for (int i = 0; i < text.length(); i++) {
            char character = text.charAt(i);
            boolean startOfWord = i == 0 || !Character.isLetter(text.charAt(i - 1));
            if (Character.isLowerCase(character)) {
                lower++;
            } else if (Character.isUpperCase(character) && !startOfWord) {
                upper++;
            }
        }
        return lower == 0 || upper == 0;
    }

    /**
     * The character at this address, or 0 when it isn't text: unloaded,
     * not a character, or {@code @}, which is the zero byte in screen codes.
     */
    private static char character(int[] memory, int address, IntFunction<Character> decode) {
        char character = memory[address] < 0 ? 0 : decode.apply(memory[address]);
        return character == '@' ? 0 : character;
    }
}
