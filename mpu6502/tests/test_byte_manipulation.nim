import std/unittest
import mpu6502

suite "byte manipulation":
  test "to signed byte, positive":
    check toSignedByte(10) == 10

  test "to signed byte, negative":
    check toSignedByte(-10) == -10
    check toSignedByte(0xffff) == -1

  test "word":
    check word(0x34, 0x12) == 0x1234
    check word(0x134, 0x212) == 0x1234
