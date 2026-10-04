package com.laamella;

import java.nio.ByteBuffer;

import static java.nio.charset.StandardCharsets.US_ASCII;

public class ByteBufferAccess {

    public static String paddedString(byte[] bytes, int pad) {
        int l = bytes.length;
        for (int i = bytes.length - 1; i >= 0; i--) {
            if (bytes[i] != pad) {
                return new String(bytes, 0, i + 1, US_ASCII);
            }
        }
        return "";
    }

    public static String readPaddedString(ByteBuffer buffer, int size, int padChar) {
        return paddedString(getByteArray(buffer, size), padChar);
    }

    public static byte[] getByteArray(ByteBuffer buffer, int size) {
        byte[] bytes = new byte[size];
        buffer.get(bytes);
        return bytes;
    }

    public static int readDword(ByteBuffer buffer) {
        int loWord = readWord(buffer);
        int hiWord = readWord(buffer);
        return (hiWord << 16) + loWord;
    }

    public static int readWord(ByteBuffer buffer) {
        int lo = getByte(buffer);
        int hi = getByte(buffer);
        return (hi << 8) + lo;
    }

    public static int getByte(ByteBuffer buffer) {
        return buffer.get() & 0xff;
    }
}
