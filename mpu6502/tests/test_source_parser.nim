import std/[options, strutils, unittest]
import mpu6502

proc dataFile(name: string): Option[seq[byte]] =
  if name == "data.bin": some(@[1'u8, 2, 3, 4]) else: none(seq[byte])

proc assembleOne(source: string): seq[int] =
  let segments = assemble(source, dataFile)
  check segments.len == 1
  for b in segments[0].data:
    result.add int(b)

proc errorOf(source: string): string =
  try:
    discard assemble(source, dataFile)
  except AssemblerError as e:
    return e.msg
  "no error"

proc sourceErrorOf(source: string): string =
  try:
    discard assemble(source, dataFile)
  except SourceError as e:
    check e.msg.startsWith("line " & $e.line & ": ")
    return e.msg
  "no source error"

## The opcode the assembler picks for the mnemonic and addressing mode of
## this one: the legal one, else the lowest.
proc canonical(opcode: int): int =
  proc modeOf(nr: int): AddressingMode =
    if addressingMode[nr] == AddressingMode.Jam: AddressingMode.None else: addressingMode[nr]
  result = -1
  for other in 0 ..< 0x100:
    if opcodeName[other] == opcodeName[opcode] and modeOf(other) == modeOf(opcode) and
        (result == -1 or illegal[result] and not illegal[other]):
      result = other

suite "source parser":
  test "addressing modes":
    check assembleOne("""
*=$c000
        nop
        asl
        asl a
        lda #$10
        lda $10
        lda $1234
        lda $10, x
        lda $1234, x
        ldx $10, y
        lda $10, y
        lda ($10, x)
        lda ($10), y
        jmp ($1234)
""") == @[0xea,
          0x0a,
          0x0a,
          0xa9, 0x10,
          0xa5, 0x10,
          0xad, 0x34, 0x12,
          0xb5, 0x10,
          0xbd, 0x34, 0x12,
          0xb6, 0x10,
          0xb9, 0x10, 0x00,
          0xa1, 0x10,
          0xb1, 0x10,
          0x6c, 0x34, 0x12]

  test "absolute operand below zero page with prefix":
    check assembleOne("""
*=$c000
        lda @w $0010
        sta $10
""") == @[0xad, 0x10, 0x00, 0x85, 0x10]

  test "forward reference to zero page shrinks":
    check assembleOne("""
*=$c000
start:  lda counter
        jmp start
.virtual $10
counter:        .byte   ?
.endv
""") == @[0xa5, 0x10, 0x4c, 0x00, 0xc0]

  test "branches":
    check assembleOne("""
*=$c000
back:   bne forward
        beq back
forward:
        rts
""") == @[0xd0, 0x02, 0xf0, 0xfc, 0x60]

  test "branch out of range":
    check errorOf("""
*=$c000
        bne far
        .fill 200
far:    rts
""") == "line 2: branch target is 200 bytes away, out of range"

  test "illegal opcodes and aliases":
    check assembleOne("""
*=$c000
        sbc #1
        isc $10
        isb $10
        asr #$0f
        jam
        nop #1
""") == @[0xe9, 0x01, 0xe7, 0x10, 0xe7, 0x10, 0x4b, 0x0f, 0x02, 0x80, 0x01]

  test "the opcode a duplicate assembles to":
    check assembledOpcode(0xe9) == 0xe9
    check assembledOpcode(0xeb) == 0xe9
    check assembledOpcode(0x1a) == 0xea
    check assembledOpcode(0x0a) == 0x0a
    check assembledOpcode(0x12) == 0x02
    for opcode in 0 ..< 0x100:
      check assembledOpcode(opcode) == canonical(opcode)

  test "every opcode":
    ## Every opcode that is the one chosen for its mnemonic and addressing
    ## mode assembles back to itself.
    for opcode in 0 ..< 0x100:
      let operand =
        case addressingMode[opcode]
        of AddressingMode.None, AddressingMode.Jam, AddressingMode.Accumulator: ""
        of AddressingMode.IndX: "($12, x)"
        of AddressingMode.IndY: "($12), y"
        of AddressingMode.ZeroPage: "$12"
        of AddressingMode.ZeroPageX: "$12, x"
        of AddressingMode.ZeroPageY: "$12, y"
        of AddressingMode.Immediate: "#$12"
        of AddressingMode.Absolute: "$1234"
        of AddressingMode.AbsoluteX: "$1234, x"
        of AddressingMode.AbsoluteY: "$1234, y"
        of AddressingMode.Relative: "here"
        of AddressingMode.Indirect: "($1234)"
      let source = "*=$1000\nhere:\t" & opcodeName[opcode].toLowerAscii & " " & operand
      checkpoint source
      check assembleOne(source)[0] == canonical(opcode)

  test "data directives":
    check assembleOne("""
*=$c000
start:  .byte   1, $ff
        .char   -2, 127
        .word   $1234
        .addr   start
        .sint   -32768
        .long   $123456
        .lint   -1
        .dword  $44332211, $4e08bfb4
        .dint   -2
        .fill   2
        .fill   3, 7
""") == @[1, 0xff,
          0xfe, 0x7f,
          0x34, 0x12, 0x00, 0xc0,
          0x00, 0x80,
          0x56, 0x34, 0x12,
          0xff, 0xff, 0xff,
          0x11, 0x22, 0x33, 0x44,
          0xb4, 0xbf, 0x08, 0x4e,
          0xfe, 0xff, 0xff, 0xff,
          0, 0,
          7, 7, 7]

  test "unsigned dword above the int32 range":
    check assembleOne("*=$c000\n .dword $fffffffe") == @[0xfe, 0xff, 0xff, 0xff]

  test "return addresses":
    check assembleOne("""
*=$c000
start:  .rta    start, $1235, ?
        .rta    0
""") == @[0xff, 0xbf, 0x34, 0x12, 0x00, 0x00, 0xff, 0xff]

  test "value out of range":
    check errorOf("""
*=$c000
        .byte 256
""") == "line 2: value 256 is out of range 0..255"

  test "expressions":
    check assembleOne("""
table = $c000
*=$c000
        lda table + $3
        lda #>table
        lda #<table + 2
        lda #'A'
        .word table - -14
        .byte %1111, $40 + 2 ; a comment
""") == @[0xad, 0x03, 0xc0, 0xa9, 0xc0, 0xa9, 0x02, 0xa9, 0x41, 0x0e, 0xc0, 0x0f, 0x42]

  test "text":
    check assembleOne("""
*=$c000
        .text   "AB", $0d, ";"
.enc    "screen"
        .text   "AB @a]"
.enc    "none"
        .null   "HI"
        .ptext  "ABC"
        .text   "q", '"'
""") == @[int('A'), int('B'), 0x0d, int(';'),
          0x01, 0x02, 0x20, 0x00, 0x41, 0x1d,
          int('H'), int('I'), 0,
          3, int('A'), int('B'), int('C'),
          int('q'), int('"')]

  test "binary":
    check assembleOne("""
*=$c000
        .binary "data.bin"
        .binary "data.bin", 2
        .binary "data.bin", 1, 1
""") == @[1, 2, 3, 4, 3, 4, 2]

  test "segments and virtual blocks":
    let segments = assemble("""
.virtual $0057
pointer:        .word   ?
.endv

*=$1000
        lda pointer
.virtual $d020
border: .byte   ?
.endv
        sta border
*=$2000
label   .byte   1
after = label + 1
        .word   after
""")
    check segments.len == 2
    check segments[0].loadAddress == 0x1000
    check segments[0].data == @[0xa5'u8, 0x57, 0x8d, 0x20, 0xd0]
    check segments[1].loadAddress == 0x2000
    check segments[1].data == @[1'u8, 0x01, 0x20]

  test "line ends":
    check assembleOne("*=$c000\r\n nop\r\n rts\r\n") == @[0xea, 0x60]

  test "errors":
    check sourceErrorOf("""
*=$c000
        nop
        jmp nowhere
""") == "line 3: nowhere is not defined"
    check sourceErrorOf("""
*=$c000
        foo $10
""") == "line 2: unknown mnemonic foo"
    check sourceErrorOf("""
*=$c000
twice:  nop
twice:  nop
""") == "line 3: twice is already defined"
    check sourceErrorOf("""
*=$c000
        jmp #1
""") == "line 2: jmp has no immediate addressing mode"
    check sourceErrorOf("""
        .binary "missing.bin"
""") == "line 1: can't read missing.bin"
    check sourceErrorOf("""
*=$c000
        .foo
""") == "line 2: unknown directive .foo"

  test "more errors":
    check errorOf("        nop") == "line 1: Cannot assemble without an org(...)."
    check errorOf("*=$c000\n.virtual $10") == "A virtual block isn't ended."
    check errorOf("*=$c000\n.endv") == "line 2: End of a virtual block that wasn't started."
    check errorOf("*=$c000\n lda $10000") == "line 2: operand 65536 is out of range"
    check errorOf("*=$c000\n lda #256") == "line 2: operand 256 is out of range"
    check errorOf("*=$c000\n lda $10, z") == "line 2: index register must be x or y, not z"
    check errorOf("*=$c000\n lda ($10, y)") == "line 2: expected index register x, not y"
    check errorOf("*=$c000\n jmp") == "line 2: jmp needs an operand"
    check errorOf("*=$c000\n .byte $123456789") == "line 2: number 123456789 is larger than 32 bits"
    check errorOf("*=$c000\n .byte $ffffffffffffffffff") ==
        "For input string: \"ffffffffffffffffff\" under radix 16"
    check errorOf("*=$c000\n .byte 99999999999999999999") == "For input string: \"99999999999999999999\""
    check errorOf("*=$c000\n .byte \"a") == "line 2: expected a value at '\"a'"
    check errorOf("*=$c000\n .text \"a") == "line 2: string isn't closed"
    check errorOf("*=$c000\n .enc \"petscii\"") == "line 2: unknown encoding petscii, only none and screen are known"
    check errorOf("*=$c000\n .enc \"screen\"\n .text \"é\"") == "line 3: character é has no screen code"
    check errorOf("*=$c000\n .text \"€\"") == "line 2: character € doesn't fit in a byte"
    check errorOf("*=$c000\n .null \"a\", 0, \"@\"") == "no error"
    check errorOf("*=$c000\n .enc \"screen\"\n .null \"@\"") == "line 3: .null text can't hold a 0"
    check errorOf("*=$c000\n .binary \"data.bin\", 3, 2") ==
        "line 2: data.bin has 4 bytes, too few for offset 3 and length 2"
    check errorOf("*=$c000\n .byte x") == "line 2: x is not defined"
    check errorOf("*=$c000\n .byte +") == "line 2: expected a value at '+'"
    check errorOf("*=$c000\n *= x\nx = 1") == "line 2: the value must be known here"
    check errorOf("*=$c000\n lda #1 2") == "line 2: unexpected '2'"
    check errorOf("*=$c000\n 1abc") == "line 2: expected a name at '1abc'"
