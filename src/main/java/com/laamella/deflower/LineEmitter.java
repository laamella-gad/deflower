package com.laamella.deflower;

import java.io.IOException;
import java.io.Writer;

/**
 * Writes assembly text line by line, and is the one place that knows how
 * a line starts and finishes: it tracks whether anything is on the current
 * line yet, how many values a directive line like {@code .byte} or
 * {@code .text} holds so far, and whether a string literal on it is still
 * open. When to break, separate or glue lines is decided by its caller.
 */
class LineEmitter {
    private final Writer w;
    // True right after a newLine() - i.e. nothing has been written on the
    // current line yet - false once any text is printed. Distinct from
    // `column`, which only counts the values of a .byte/.text line: this
    // tracks whether the line as a whole still needs closing.
    private boolean atLineStart = true;
    private int column = 0;
    // True while a double-quoted literal is open on the current line;
    // newLine() closes it.
    private boolean inQuotes = false;

    LineEmitter(Writer w) {
        this.w = w;
    }

    void print(String s) throws IOException {
        w.write(s);
        atLineStart = false;
    }

    void newLine() throws IOException {
        closeQuotes();
        w.write("\n");
        column = 0;
        atLineStart = true;
    }

    /**
     * Closes the current line, unless nothing has been written on it yet.
     */
    void finishLine() throws IOException {
        if (!atLineStart) {
            newLine();
        }
    }

    void indent() throws IOException {
        print("\t\t");
    }

    boolean isAtLineStart() {
        return atLineStart;
    }

    /**
     * The number of values printed on the current line.
     */
    int column() {
        return column;
    }

    /**
     * Prints one value of a directive line, separated from the previous
     * one by a comma.
     */
    void item(String value) throws IOException {
        closeQuotes();
        if (column != 0) {
            print(", ");
        }
        print(value);
        column++;
    }

    /**
     * Prints one character as a value of a directive line, inside a
     * double-quoted literal shared with the characters right before it.
     */
    void quotedCharacter(char character) throws IOException {
        if (!inQuotes) {
            if (column != 0) {
                print(", ");
            }
            print("\"");
            inQuotes = true;
        }
        print(String.valueOf(character));
        column++;
    }

    private void closeQuotes() throws IOException {
        if (inQuotes) {
            print("\"");
            inQuotes = false;
        }
    }

    /**
     * Finishes the output: closes a string literal still open on the last
     * line.
     */
    void close() throws IOException {
        closeQuotes();
    }
}
