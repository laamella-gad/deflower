package com.laamella;

public class Assert {
    public static void assertState(boolean condition, String problem, Object... args) {
        if (!condition) {
            throw new IllegalStateException(String.format(problem, args));
        }
    }

    public static void assertArgument(boolean condition, String problem, Object... args) {
        if (!condition) {
            throw new IllegalArgumentException(String.format(problem, args));
        }
    }
}
