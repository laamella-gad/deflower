import std/[options, unittest]
import mpu6502

suite "assembler":
  test "assemblables built in code":
    let assembler = newAssembler()
    let testByte = bytes(0)
    assembler.add(org(0x1000), instruction(0xa9, 15'i32), instruction(0x8d, testByte), instruction(2), testByte)
    let segments = assembler.assemble()
    check segments.len == 1
    check segments[0].loadAddress == 0x1000
    check segments[0].data == @[0xa9'u8, 0x0f, 0x8d, 0x06, 0x10, 0x02, 0x00]
    check testByte.address == some(0x1006'i32)

  test "without an org":
    let assembler = newAssembler()
    assembler.add(bytes(1))
    expect AssemblerError:
      discard assembler.assemble()

  test "undefined values":
    let assembler = newAssembler()
    assembler.add(org(0x1000), instruction(0xad, assembler.symbol("nowhere")))
    expect AssemblerError:
      discard assembler.assemble()
    try:
      let other = newAssembler()
      other.add(org(0x1000), values(1, false, @[other.symbol("nowhere")]))
      discard other.assemble()
    except AssemblerError as e:
      check e.msg == "a value is undefined"
    try:
      discard assembler.assemble()
    except AssemblerError as e:
      check e.msg == "the operand of LDA is undefined"
