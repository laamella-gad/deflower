import std/unittest
import snippets_test

suite "split":
  test "an empty string gives no parts":
    check splitParts("", "\n--\n").len == 0

  test "a separator at both ends gives empty parts":
    check splitParts("\n--\nceoiaejoiea\n--\njfoieajoiaje\n--\n", "\n--\n") ==
        @["", "ceoiaejoiea", "jfoieajoiaje", ""]

  test "a separator at the end gives an empty last part":
    check splitParts("aoiejoiaj\n--\nceoiaejoiea\n--\njfoieajoiaje\n--\n", "\n--\n") ==
        @["aoiejoiaj", "ceoiaejoiea", "jfoieajoiaje", ""]

  test "no separator at the ends":
    check splitParts("x\n--\nceoiaejoiea\n--\njfoieajoiaje\n--\nx", "\n--\n") ==
        @["x", "ceoiaejoiea", "jfoieajoiaje", "x"]

  test "only the separator":
    check splitParts("abc", "abc") == @["", ""]

  test "no separator":
    check splitParts("abc", "def") == @["abc"]

  test "an empty separator":
    check splitParts("abc", "") == @["abc"]
