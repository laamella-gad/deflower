## The 6502's instructions: per opcode its mnemonic, addressing mode, cycles
## and whether it is illegal, and the instructions by number.

import std/[options, tables]

type
  AddressingMode* {.pure.} = enum
    None         ## no operand
    IndX         ## (n, x)
    IndY         ## (n), y
    Jam          ## this instruction will jam the CPU
    ZeroPage     ## n
    ZeroPageX    ## n, x
    ZeroPageY    ## n, y
    Immediate    ## #n
    Absolute     ## nn
    AbsoluteX    ## nn, x
    AbsoluteY    ## nn, y
    Relative     ## n (for relative jumps)
    Indirect     ## (nn)
    Accumulator  ## data is in the accumulator

  Opcode* {.pure.} = enum
    BRK, ORA, SLO, NOP, ASL, PHP, ANC, BPL, CLC, JSR, AND, RLA, BIT, ROL, PLP, BMI, SEC, RTI, EOR, SRE, PHA, LSR,
    ALR, JMP, BVC, CLI, RTS, ADC, RRA, ROR, PLA, ARR, BVS, SEI, STA, SAX, STY, STX, DEY, TXA, XAA, BCC, AHX, TYA,
    TXS, TAS, SHY, SHX, LDY, LDA, LDX, LAX, TAY, TAX, BCS, CLV, TSX, LAS, CPY, CMP, DCP, DEC, INY, DEX, AXS, BNE,
    CLD, CPX, SBC, ISC, INC, INX, BEQ, SED

  Instruction* = object
    nr*: int
    name*: string       ## e.g. "LDA_IMM" or "NOP_ZP_04"
    cycles*: int
    opcode*: Opcode
    illegal*: bool
    addressingMode*: AddressingMode
    specialCycles*: bool

const
  totalBytesByMode: array[AddressingMode, int] = [1, 2, 2, 1, 2, 2, 2, 2, 3, 3, 3, 2, 3, 1]
  modeNames: array[AddressingMode, string] = ["none", "ind_x", "ind_y", "jam", "zero_page", "zero_page_x",
      "zero_page_y", "immediate", "absolute", "absolute_x", "absolute_y", "relative", "indirect", "accumulator"]

func totalBytes*(mode: AddressingMode): int =
  ## The size of an instruction in this mode, opcode included.
  totalBytesByMode[mode]

func name*(mode: AddressingMode): string =
  ## The mode's name in lower case, words joined by "_", e.g. "zero_page_x".
  modeNames[mode]

type OpcodeRow = tuple[name: string, mode: AddressingMode, illegal: bool, cycles: int, specialCycles: bool]

const opcodeRows: array[256, OpcodeRow] = [
  ("BRK", None, false, 7, false),  # $00
  ("ORA", IndX, false, 6, false),  # $01
  ("JAM", Jam, true, 0, false),  # $02
  ("SLO", IndX, true, 8, false),  # $03
  ("NOP", ZeroPage, true, 3, false),  # $04
  ("ORA", ZeroPage, false, 3, false),  # $05
  ("ASL", ZeroPage, false, 5, false),  # $06
  ("SLO", ZeroPage, true, 5, false),  # $07
  ("PHP", None, false, 3, false),  # $08
  ("ORA", Immediate, false, 2, false),  # $09
  ("ASL", None, false, 2, false),  # $0a
  ("ANC", Immediate, true, 2, false),  # $0b
  ("NOP", Absolute, true, 4, false),  # $0c
  ("ORA", Absolute, false, 4, false),  # $0d
  ("ASL", Absolute, false, 6, false),  # $0e
  ("SLO", Absolute, true, 6, false),  # $0f
  ("BPL", Relative, false, 2, true),  # $10
  ("ORA", IndY, false, 5, true),  # $11
  ("JAM", Jam, true, 0, false),  # $12
  ("SLO", IndY, true, 8, false),  # $13
  ("NOP", ZeroPageX, true, 4, false),  # $14
  ("ORA", ZeroPageX, false, 4, false),  # $15
  ("ASL", ZeroPageX, false, 6, false),  # $16
  ("SLO", ZeroPageX, true, 6, false),  # $17
  ("CLC", None, false, 2, false),  # $18
  ("ORA", AbsoluteY, false, 4, true),  # $19
  ("NOP", None, true, 2, false),  # $1a
  ("SLO", AbsoluteY, true, 7, false),  # $1b
  ("NOP", AbsoluteX, true, 4, true),  # $1c
  ("ORA", AbsoluteX, false, 4, true),  # $1d
  ("ASL", AbsoluteX, false, 7, false),  # $1e
  ("SLO", AbsoluteX, true, 7, false),  # $1f
  ("JSR", Absolute, false, 6, false),  # $20
  ("AND", IndX, false, 6, false),  # $21
  ("JAM", Jam, true, 0, false),  # $22
  ("RLA", IndX, true, 8, false),  # $23
  ("BIT", ZeroPage, false, 3, false),  # $24
  ("AND", ZeroPage, false, 3, false),  # $25
  ("ROL", ZeroPage, false, 5, false),  # $26
  ("RLA", ZeroPage, true, 5, false),  # $27
  ("PLP", None, false, 4, false),  # $28
  ("AND", Immediate, false, 2, false),  # $29
  ("ROL", None, false, 2, false),  # $2a
  ("ANC", Immediate, true, 2, false),  # $2b
  ("BIT", Absolute, false, 4, false),  # $2c
  ("AND", Absolute, false, 4, false),  # $2d
  ("ROL", Absolute, false, 6, false),  # $2e
  ("RLA", Absolute, true, 6, false),  # $2f
  ("BMI", Relative, false, 2, true),  # $30
  ("AND", IndY, false, 5, true),  # $31
  ("JAM", Jam, true, 0, false),  # $32
  ("RLA", IndY, true, 8, false),  # $33
  ("NOP", ZeroPageX, true, 4, false),  # $34
  ("AND", ZeroPageX, false, 4, false),  # $35
  ("ROL", ZeroPageX, false, 6, false),  # $36
  ("RLA", ZeroPageX, true, 6, false),  # $37
  ("SEC", None, false, 2, false),  # $38
  ("AND", AbsoluteY, false, 4, true),  # $39
  ("NOP", None, true, 2, false),  # $3a
  ("RLA", AbsoluteY, true, 7, false),  # $3b
  ("NOP", AbsoluteX, true, 4, true),  # $3c
  ("AND", AbsoluteX, false, 4, true),  # $3d
  ("ROL", AbsoluteX, false, 7, false),  # $3e
  ("RLA", AbsoluteX, true, 7, false),  # $3f
  ("RTI", None, false, 6, false),  # $40
  ("EOR", IndX, false, 6, false),  # $41
  ("JAM", Jam, true, 0, false),  # $42
  ("SRE", IndX, true, 8, false),  # $43
  ("NOP", ZeroPage, true, 3, false),  # $44
  ("EOR", ZeroPage, false, 3, false),  # $45
  ("LSR", ZeroPage, false, 5, false),  # $46
  ("SRE", ZeroPage, true, 5, false),  # $47
  ("PHA", None, false, 3, false),  # $48
  ("EOR", Immediate, false, 2, false),  # $49
  ("LSR", None, false, 2, false),  # $4a
  ("ALR", Immediate, true, 2, false),  # $4b
  ("JMP", Absolute, false, 3, false),  # $4c
  ("EOR", Absolute, false, 4, false),  # $4d
  ("LSR", Absolute, false, 6, false),  # $4e
  ("SRE", Absolute, true, 6, false),  # $4f
  ("BVC", Relative, false, 2, true),  # $50
  ("EOR", IndY, false, 5, true),  # $51
  ("JAM", Jam, true, 0, false),  # $52
  ("SRE", IndY, true, 8, false),  # $53
  ("NOP", ZeroPageX, true, 4, false),  # $54
  ("EOR", ZeroPageX, false, 4, false),  # $55
  ("LSR", ZeroPageX, false, 6, false),  # $56
  ("SRE", ZeroPageX, true, 6, false),  # $57
  ("CLI", None, false, 2, false),  # $58
  ("EOR", AbsoluteY, false, 4, true),  # $59
  ("NOP", None, true, 2, false),  # $5a
  ("SRE", AbsoluteY, true, 7, false),  # $5b
  ("NOP", AbsoluteX, true, 4, true),  # $5c
  ("EOR", AbsoluteX, false, 4, true),  # $5d
  ("LSR", AbsoluteX, false, 7, false),  # $5e
  ("SRE", AbsoluteX, true, 7, false),  # $5f
  ("RTS", None, false, 6, false),  # $60
  ("ADC", IndX, false, 6, false),  # $61
  ("JAM", Jam, true, 0, false),  # $62
  ("RRA", IndX, true, 8, false),  # $63
  ("NOP", ZeroPage, true, 3, false),  # $64
  ("ADC", ZeroPage, false, 3, false),  # $65
  ("ROR", ZeroPage, false, 5, false),  # $66
  ("RRA", ZeroPage, true, 5, false),  # $67
  ("PLA", None, false, 4, false),  # $68
  ("ADC", Immediate, false, 2, false),  # $69
  ("ROR", None, false, 2, false),  # $6a
  ("ARR", Immediate, true, 2, false),  # $6b
  ("JMP", Indirect, false, 5, false),  # $6c
  ("ADC", Absolute, false, 4, false),  # $6d
  ("ROR", Absolute, false, 6, false),  # $6e
  ("RRA", Absolute, true, 6, false),  # $6f
  ("BVS", Relative, false, 2, true),  # $70
  ("ADC", IndY, false, 5, true),  # $71
  ("JAM", Jam, true, 0, false),  # $72
  ("RRA", IndY, true, 8, false),  # $73
  ("NOP", ZeroPageX, true, 4, false),  # $74
  ("ADC", ZeroPageX, false, 4, false),  # $75
  ("ROR", ZeroPageX, false, 6, false),  # $76
  ("RRA", ZeroPageX, true, 6, false),  # $77
  ("SEI", None, false, 2, false),  # $78
  ("ADC", AbsoluteY, false, 4, true),  # $79
  ("NOP", None, true, 2, false),  # $7a
  ("RRA", AbsoluteY, true, 7, false),  # $7b
  ("NOP", AbsoluteX, true, 4, true),  # $7c
  ("ADC", AbsoluteX, false, 4, true),  # $7d
  ("ROR", AbsoluteX, false, 7, false),  # $7e
  ("RRA", AbsoluteX, true, 7, false),  # $7f
  ("NOP", Immediate, true, 2, false),  # $80
  ("STA", IndX, false, 6, false),  # $81
  ("NOP", Immediate, true, 2, false),  # $82
  ("SAX", IndX, true, 6, false),  # $83
  ("STY", ZeroPage, false, 3, false),  # $84
  ("STA", ZeroPage, false, 3, false),  # $85
  ("STX", ZeroPage, false, 3, false),  # $86
  ("SAX", ZeroPage, true, 3, false),  # $87
  ("DEY", None, false, 2, false),  # $88
  ("NOP", Immediate, true, 2, false),  # $89
  ("TXA", None, false, 2, false),  # $8a
  ("XAA", Immediate, true, 2, false),  # $8b
  ("STY", Absolute, false, 4, false),  # $8c
  ("STA", Absolute, false, 4, false),  # $8d
  ("STX", Absolute, false, 4, false),  # $8e
  ("SAX", Absolute, true, 4, false),  # $8f
  ("BCC", Relative, false, 2, true),  # $90
  ("STA", IndY, false, 6, false),  # $91
  ("JAM", Jam, true, 0, false),  # $92
  ("AHX", IndY, true, 6, false),  # $93
  ("STY", ZeroPageX, false, 4, false),  # $94
  ("STA", ZeroPageX, false, 4, false),  # $95
  ("STX", ZeroPageY, false, 4, false),  # $96
  ("SAX", ZeroPageY, true, 4, false),  # $97
  ("TYA", None, false, 2, false),  # $98
  ("STA", AbsoluteY, false, 5, false),  # $99
  ("TXS", None, false, 2, false),  # $9a
  ("TAS", AbsoluteY, true, 5, false),  # $9b
  ("SHY", AbsoluteX, true, 5, false),  # $9c
  ("STA", AbsoluteX, false, 5, false),  # $9d
  ("SHX", AbsoluteY, true, 5, false),  # $9e
  ("AHX", AbsoluteY, true, 5, false),  # $9f
  ("LDY", Immediate, false, 2, false),  # $a0
  ("LDA", IndX, false, 6, false),  # $a1
  ("LDX", Immediate, false, 2, false),  # $a2
  ("LAX", IndX, true, 6, false),  # $a3
  ("LDY", ZeroPage, false, 3, false),  # $a4
  ("LDA", ZeroPage, false, 3, false),  # $a5
  ("LDX", ZeroPage, false, 3, false),  # $a6
  ("LAX", ZeroPage, true, 3, false),  # $a7
  ("TAY", None, false, 2, false),  # $a8
  ("LDA", Immediate, false, 2, false),  # $a9
  ("TAX", None, false, 2, false),  # $aa
  ("LAX", Immediate, true, 2, false),  # $ab
  ("LDY", Absolute, false, 4, false),  # $ac
  ("LDA", Absolute, false, 4, false),  # $ad
  ("LDX", Absolute, false, 4, false),  # $ae
  ("LAX", Absolute, true, 4, false),  # $af
  ("BCS", Relative, false, 2, true),  # $b0
  ("LDA", IndY, false, 5, true),  # $b1
  ("JAM", Jam, true, 0, false),  # $b2
  ("LAX", IndY, true, 5, true),  # $b3
  ("LDY", ZeroPageX, false, 4, false),  # $b4
  ("LDA", ZeroPageX, false, 4, false),  # $b5
  ("LDX", ZeroPageY, false, 4, false),  # $b6
  ("LAX", ZeroPageY, true, 4, false),  # $b7
  ("CLV", None, false, 2, false),  # $b8
  ("LDA", AbsoluteY, false, 4, true),  # $b9
  ("TSX", None, false, 2, false),  # $ba
  ("LAS", AbsoluteY, true, 4, true),  # $bb
  ("LDY", AbsoluteX, false, 4, true),  # $bc
  ("LDA", AbsoluteX, false, 4, true),  # $bd
  ("LDX", AbsoluteY, false, 4, true),  # $be
  ("LAX", AbsoluteY, true, 4, true),  # $bf
  ("CPY", Immediate, false, 2, false),  # $c0
  ("CMP", IndX, false, 6, false),  # $c1
  ("NOP", Immediate, true, 2, false),  # $c2
  ("DCP", IndX, true, 8, false),  # $c3
  ("CPY", ZeroPage, false, 3, false),  # $c4
  ("CMP", ZeroPage, false, 3, false),  # $c5
  ("DEC", ZeroPage, false, 5, false),  # $c6
  ("DCP", ZeroPage, true, 5, false),  # $c7
  ("INY", None, false, 2, false),  # $c8
  ("CMP", Immediate, false, 2, false),  # $c9
  ("DEX", None, false, 2, false),  # $ca
  ("AXS", Immediate, true, 2, false),  # $cb
  ("CPY", Absolute, false, 4, false),  # $cc
  ("CMP", Absolute, false, 4, false),  # $cd
  ("DEC", Absolute, false, 6, false),  # $ce
  ("DCP", Absolute, true, 6, false),  # $cf
  ("BNE", Relative, false, 2, true),  # $d0
  ("CMP", IndY, false, 5, true),  # $d1
  ("JAM", Jam, true, 0, false),  # $d2
  ("DCP", IndY, true, 8, false),  # $d3
  ("NOP", ZeroPageX, true, 4, false),  # $d4
  ("CMP", ZeroPageX, false, 4, false),  # $d5
  ("DEC", ZeroPageX, false, 6, false),  # $d6
  ("DCP", ZeroPageX, true, 6, false),  # $d7
  ("CLD", None, false, 2, false),  # $d8
  ("CMP", AbsoluteY, false, 4, true),  # $d9
  ("NOP", None, true, 2, false),  # $da
  ("DCP", AbsoluteY, true, 7, false),  # $db
  ("NOP", AbsoluteX, true, 4, true),  # $dc
  ("CMP", AbsoluteX, false, 4, true),  # $dd
  ("DEC", AbsoluteX, false, 7, false),  # $de
  ("DCP", AbsoluteX, true, 7, false),  # $df
  ("CPX", Immediate, false, 2, false),  # $e0
  ("SBC", IndX, false, 6, false),  # $e1
  ("NOP", Immediate, true, 2, false),  # $e2
  ("ISC", IndX, true, 8, false),  # $e3
  ("CPX", ZeroPage, false, 3, false),  # $e4
  ("SBC", ZeroPage, false, 3, false),  # $e5
  ("INC", ZeroPage, false, 5, false),  # $e6
  ("ISC", ZeroPage, true, 5, false),  # $e7
  ("INX", None, false, 2, false),  # $e8
  ("SBC", Immediate, false, 2, false),  # $e9
  ("NOP", None, false, 2, false),  # $ea
  ("SBC", Immediate, true, 2, false),  # $eb
  ("CPX", Absolute, false, 4, false),  # $ec
  ("SBC", Absolute, false, 4, false),  # $ed
  ("INC", Absolute, false, 6, false),  # $ee
  ("ISC", Absolute, true, 6, false),  # $ef
  ("BEQ", Relative, false, 2, true),  # $f0
  ("SBC", IndY, false, 5, true),  # $f1
  ("JAM", Jam, true, 0, false),  # $f2
  ("ISC", IndY, true, 8, false),  # $f3
  ("NOP", ZeroPageX, true, 4, false),  # $f4
  ("SBC", ZeroPageX, false, 4, false),  # $f5
  ("INC", ZeroPageX, false, 6, false),  # $f6
  ("ISC", ZeroPageX, true, 6, false),  # $f7
  ("SED", None, false, 2, false),  # $f8
  ("SBC", AbsoluteY, false, 4, true),  # $f9
  ("NOP", None, true, 2, false),  # $fa
  ("ISC", AbsoluteY, true, 7, false),  # $fb
  ("NOP", AbsoluteX, true, 4, true),  # $fc
  ("SBC", AbsoluteX, false, 4, true),  # $fd
  ("INC", AbsoluteX, false, 7, false),  # $fe
  ("ISC", AbsoluteX, true, 7, false)]  # $ff

const
  opcodeName*: array[256, string] = (func: array[256, string] =
    for nr, row in opcodeRows: result[nr] = row.name)()
    ## Per opcode its mnemonic in upper case, "JAM" for the ones that jam.
  illegal*: array[256, bool] = (func: array[256, bool] =
    for nr, row in opcodeRows: result[nr] = row.illegal)()
  addressingMode*: array[256, AddressingMode] = (func: array[256, AddressingMode] =
    for nr, row in opcodeRows: result[nr] = row.mode)()
    ## Per opcode its addressing mode. Unlike the instructions, asl, rol, lsr
    ## and ror on the accumulator ($0a, $2a, $4a, $6a) have mode None here.
  cpuCycles*: array[256, int] = (func: array[256, int] =
    for nr, row in opcodeRows: result[nr] = row.cycles)()
  specialCycles*: array[256, bool] = (func: array[256, bool] =
    for nr, row in opcodeRows: result[nr] = row.specialCycles)()

const instructions*: seq[Instruction] = @[
  Instruction(nr: 0x00, name: "BRK", cycles: 7, opcode: Opcode.BRK, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x01, name: "ORA_IZX", cycles: 6, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x03, name: "SLO_IZX_03", cycles: 8, opcode: Opcode.SLO, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x04, name: "NOP_ZP_04", cycles: 3, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x05, name: "ORA_ZP", cycles: 3, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x06, name: "ASL_ZP", cycles: 5, opcode: Opcode.ASL, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x07, name: "SLO_ZP_07", cycles: 5, opcode: Opcode.SLO, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x08, name: "PHP", cycles: 3, opcode: Opcode.PHP, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x09, name: "ORA_IMM", cycles: 2, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x0a, name: "ASL", cycles: 2, opcode: Opcode.ASL, illegal: false, addressingMode: AddressingMode.Accumulator, specialCycles: false),
  Instruction(nr: 0x0b, name: "ANC_IMM_0B", cycles: 2, opcode: Opcode.ANC, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x0c, name: "NOP_ABS_0C", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x0d, name: "ORA_ABS", cycles: 4, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x0e, name: "ASL_ABS", cycles: 6, opcode: Opcode.ASL, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x0f, name: "SLO_ABS_0F", cycles: 6, opcode: Opcode.SLO, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x10, name: "BPL", cycles: 2, opcode: Opcode.BPL, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0x11, name: "ORA_IZY", cycles: 5, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0x13, name: "SLO_IZY_13", cycles: 8, opcode: Opcode.SLO, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0x14, name: "NOP_ZPX_14", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x15, name: "ORA_ZPX", cycles: 4, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x16, name: "ASL_ZPX", cycles: 6, opcode: Opcode.ASL, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x17, name: "SLO_ZPX_17", cycles: 6, opcode: Opcode.SLO, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x18, name: "CLC", cycles: 2, opcode: Opcode.CLC, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x19, name: "ORA_ABY", cycles: 4, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0x1a, name: "NOP_1A", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x1b, name: "SLO_ABY_1B", cycles: 7, opcode: Opcode.SLO, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0x1c, name: "NOP_ABX_1C", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x1d, name: "ORA_ABX", cycles: 4, opcode: Opcode.ORA, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x1e, name: "ASL_ABX", cycles: 7, opcode: Opcode.ASL, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x1f, name: "SLO_ABX_1F", cycles: 7, opcode: Opcode.SLO, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x20, name: "JSR_ABS", cycles: 6, opcode: Opcode.JSR, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x21, name: "AND_IZX", cycles: 6, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x23, name: "RLA_IZX_23", cycles: 8, opcode: Opcode.RLA, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x24, name: "BIT_ZP", cycles: 3, opcode: Opcode.BIT, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x25, name: "AND_ZP", cycles: 3, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x26, name: "ROL_ZP", cycles: 5, opcode: Opcode.ROL, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x27, name: "RLA_ZP_27", cycles: 5, opcode: Opcode.RLA, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x28, name: "PLP", cycles: 4, opcode: Opcode.PLP, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x29, name: "AND_IMM", cycles: 2, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x2a, name: "ROL", cycles: 2, opcode: Opcode.ROL, illegal: false, addressingMode: AddressingMode.Accumulator, specialCycles: false),
  Instruction(nr: 0x2b, name: "ANC_IMM_2B", cycles: 2, opcode: Opcode.ANC, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x2c, name: "BIT_ABS", cycles: 4, opcode: Opcode.BIT, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x2d, name: "AND_ABS", cycles: 4, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x2e, name: "ROL_ABS", cycles: 6, opcode: Opcode.ROL, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x2f, name: "RLA_ABS_2F", cycles: 6, opcode: Opcode.RLA, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x30, name: "BMI", cycles: 2, opcode: Opcode.BMI, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0x31, name: "AND_IZY", cycles: 5, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0x33, name: "RLA_IZY_33", cycles: 8, opcode: Opcode.RLA, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0x34, name: "NOP_ZPX_34", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x35, name: "AND_ZPX", cycles: 4, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x36, name: "ROL_ZPX", cycles: 6, opcode: Opcode.ROL, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x37, name: "RLA_ZPX_37", cycles: 6, opcode: Opcode.RLA, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x38, name: "SEC", cycles: 2, opcode: Opcode.SEC, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x39, name: "AND_ABY", cycles: 4, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0x3a, name: "NOP_3A", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x3b, name: "RLA_ABY_3B", cycles: 7, opcode: Opcode.RLA, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0x3c, name: "NOP_ABX_3C", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x3d, name: "AND_ABX", cycles: 4, opcode: Opcode.AND, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x3e, name: "ROL_ABX", cycles: 7, opcode: Opcode.ROL, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x3f, name: "RLA_ABX_3F", cycles: 7, opcode: Opcode.RLA, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x40, name: "RTI", cycles: 6, opcode: Opcode.RTI, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x41, name: "EOR_IZX", cycles: 6, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x43, name: "SRE_IZX_43", cycles: 8, opcode: Opcode.SRE, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x44, name: "NOP_ZP_44", cycles: 3, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x45, name: "EOR_ZP", cycles: 3, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x46, name: "LSR_ZP", cycles: 5, opcode: Opcode.LSR, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x47, name: "SRE_ZP_47", cycles: 5, opcode: Opcode.SRE, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x48, name: "PHA", cycles: 3, opcode: Opcode.PHA, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x49, name: "EOR_IMM", cycles: 2, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x4a, name: "LSR", cycles: 2, opcode: Opcode.LSR, illegal: false, addressingMode: AddressingMode.Accumulator, specialCycles: false),
  Instruction(nr: 0x4b, name: "ALR_IMM_4B", cycles: 2, opcode: Opcode.ALR, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x4c, name: "JMP_ABS", cycles: 3, opcode: Opcode.JMP, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x4d, name: "EOR_ABS", cycles: 4, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x4e, name: "LSR_ABS", cycles: 6, opcode: Opcode.LSR, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x4f, name: "SRE_ABS_4F", cycles: 6, opcode: Opcode.SRE, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x50, name: "BVC", cycles: 2, opcode: Opcode.BVC, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0x51, name: "EOR_IZY", cycles: 5, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0x53, name: "SRE_IZY_53", cycles: 8, opcode: Opcode.SRE, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0x54, name: "NOP_ZPX_54", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x55, name: "EOR_ZPX", cycles: 4, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x56, name: "LSR_ZPX", cycles: 6, opcode: Opcode.LSR, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x57, name: "SRE_ZPX_57", cycles: 6, opcode: Opcode.SRE, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x58, name: "CLI", cycles: 2, opcode: Opcode.CLI, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x59, name: "EOR_ABY", cycles: 4, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0x5a, name: "NOP_5A", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x5b, name: "SRE_ABY_5B", cycles: 7, opcode: Opcode.SRE, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0x5c, name: "NOP_ABX_5C", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x5d, name: "EOR_ABX", cycles: 4, opcode: Opcode.EOR, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x5e, name: "LSR_ABX", cycles: 7, opcode: Opcode.LSR, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x5f, name: "SRE_ABX_5F", cycles: 7, opcode: Opcode.SRE, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x60, name: "RTS", cycles: 6, opcode: Opcode.RTS, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x61, name: "ADC_IZX", cycles: 6, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x63, name: "RRA_IZX_63", cycles: 8, opcode: Opcode.RRA, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x64, name: "NOP_ZP_64", cycles: 3, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x65, name: "ADC_ZP", cycles: 3, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x66, name: "ROR_ZP", cycles: 5, opcode: Opcode.ROR, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x67, name: "RRA_ZP_67", cycles: 5, opcode: Opcode.RRA, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x68, name: "PLA", cycles: 4, opcode: Opcode.PLA, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x69, name: "ADC_IMM", cycles: 2, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x6a, name: "ROR", cycles: 2, opcode: Opcode.ROR, illegal: false, addressingMode: AddressingMode.Accumulator, specialCycles: false),
  Instruction(nr: 0x6b, name: "ARR_IMM_6B", cycles: 2, opcode: Opcode.ARR, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x6c, name: "JMP_IND", cycles: 5, opcode: Opcode.JMP, illegal: false, addressingMode: AddressingMode.Indirect, specialCycles: false),
  Instruction(nr: 0x6d, name: "ADC_ABS", cycles: 4, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x6e, name: "ROR_ABS", cycles: 6, opcode: Opcode.ROR, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x6f, name: "RRA_ABS_6F", cycles: 6, opcode: Opcode.RRA, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x70, name: "BVS", cycles: 2, opcode: Opcode.BVS, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0x71, name: "ADC_IZY", cycles: 5, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0x73, name: "RRA_IZY_73", cycles: 8, opcode: Opcode.RRA, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0x74, name: "NOP_ZPX_74", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x75, name: "ADC_ZPX", cycles: 4, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x76, name: "ROR_ZPX", cycles: 6, opcode: Opcode.ROR, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x77, name: "RRA_ZPX_77", cycles: 6, opcode: Opcode.RRA, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x78, name: "SEI", cycles: 2, opcode: Opcode.SEI, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x79, name: "ADC_ABY", cycles: 4, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0x7a, name: "NOP_7A", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x7b, name: "RRA_ABY_7B", cycles: 7, opcode: Opcode.RRA, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0x7c, name: "NOP_ABX_7C", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x7d, name: "ADC_ABX", cycles: 4, opcode: Opcode.ADC, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0x7e, name: "ROR_ABX", cycles: 7, opcode: Opcode.ROR, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x7f, name: "RRA_ABX_7F", cycles: 7, opcode: Opcode.RRA, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x80, name: "NOP_IMM_80", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x81, name: "STA_IZX", cycles: 6, opcode: Opcode.STA, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x82, name: "NOP_IMM_82", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x83, name: "SAX_IZX_83", cycles: 6, opcode: Opcode.SAX, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0x84, name: "STY_ZP", cycles: 3, opcode: Opcode.STY, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x85, name: "STA_ZP", cycles: 3, opcode: Opcode.STA, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x86, name: "STX_ZP", cycles: 3, opcode: Opcode.STX, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x87, name: "SAX_ZP_87", cycles: 3, opcode: Opcode.SAX, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0x88, name: "DEY", cycles: 2, opcode: Opcode.DEY, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x89, name: "NOP_IMM_89", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x8a, name: "TXA", cycles: 2, opcode: Opcode.TXA, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x8b, name: "XAA_IMM_8B", cycles: 2, opcode: Opcode.XAA, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0x8c, name: "STY_ABS", cycles: 4, opcode: Opcode.STY, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x8d, name: "STA_ABS", cycles: 4, opcode: Opcode.STA, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x8e, name: "STX_ABS", cycles: 4, opcode: Opcode.STX, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x8f, name: "SAX_ABS_8F", cycles: 4, opcode: Opcode.SAX, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0x90, name: "BCC", cycles: 2, opcode: Opcode.BCC, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0x91, name: "STA_IZY", cycles: 6, opcode: Opcode.STA, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0x93, name: "AHX_IZY_93", cycles: 6, opcode: Opcode.AHX, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0x94, name: "STY_ZPX", cycles: 4, opcode: Opcode.STY, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x95, name: "STA_ZPX", cycles: 4, opcode: Opcode.STA, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0x96, name: "STX_ZPY", cycles: 4, opcode: Opcode.STX, illegal: false, addressingMode: AddressingMode.ZeroPageY, specialCycles: false),
  Instruction(nr: 0x97, name: "SAX_ZPY_97", cycles: 4, opcode: Opcode.SAX, illegal: true, addressingMode: AddressingMode.ZeroPageY, specialCycles: false),
  Instruction(nr: 0x98, name: "TYA", cycles: 2, opcode: Opcode.TYA, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x99, name: "STA_ABY", cycles: 5, opcode: Opcode.STA, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0x9a, name: "TXS", cycles: 2, opcode: Opcode.TXS, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0x9b, name: "TAS_ABY_9B", cycles: 5, opcode: Opcode.TAS, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0x9c, name: "SHY_ABX_9C", cycles: 5, opcode: Opcode.SHY, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x9d, name: "STA_ABX", cycles: 5, opcode: Opcode.STA, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0x9e, name: "SHX_ABY_9E", cycles: 5, opcode: Opcode.SHX, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0x9f, name: "AHX_ABY_9F", cycles: 5, opcode: Opcode.AHX, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0xa0, name: "LDY_IMM", cycles: 2, opcode: Opcode.LDY, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xa1, name: "LDA_IZX", cycles: 6, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0xa2, name: "LDX_IMM", cycles: 2, opcode: Opcode.LDX, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xa3, name: "LAX_IZX_A3", cycles: 6, opcode: Opcode.LAX, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0xa4, name: "LDY_ZP", cycles: 3, opcode: Opcode.LDY, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xa5, name: "LDA_ZP", cycles: 3, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xa6, name: "LDX_ZP", cycles: 3, opcode: Opcode.LDX, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xa7, name: "LAX_ZP_A7", cycles: 3, opcode: Opcode.LAX, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xa8, name: "TAY", cycles: 2, opcode: Opcode.TAY, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xa9, name: "LDA_IMM", cycles: 2, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xaa, name: "TAX", cycles: 2, opcode: Opcode.TAX, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xab, name: "LAX_IMM_AB", cycles: 2, opcode: Opcode.LAX, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xac, name: "LDY_ABS", cycles: 4, opcode: Opcode.LDY, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xad, name: "LDA_ABS", cycles: 4, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xae, name: "LDX_ABS", cycles: 4, opcode: Opcode.LDX, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xaf, name: "LAX_ABS_AF", cycles: 4, opcode: Opcode.LAX, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xb0, name: "BCS", cycles: 2, opcode: Opcode.BCS, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0xb1, name: "LDA_IZY", cycles: 5, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0xb3, name: "LAX_IZY_B3", cycles: 5, opcode: Opcode.LAX, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0xb4, name: "LDY_ZPX", cycles: 4, opcode: Opcode.LDY, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xb5, name: "LDA_ZPX", cycles: 4, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xb6, name: "LDX_ZPY", cycles: 4, opcode: Opcode.LDX, illegal: false, addressingMode: AddressingMode.ZeroPageY, specialCycles: false),
  Instruction(nr: 0xb7, name: "LAX_ZPY_B7", cycles: 4, opcode: Opcode.LAX, illegal: true, addressingMode: AddressingMode.ZeroPageY, specialCycles: false),
  Instruction(nr: 0xb8, name: "CLV", cycles: 2, opcode: Opcode.CLV, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xb9, name: "LDA_ABY", cycles: 4, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0xba, name: "TSX", cycles: 2, opcode: Opcode.TSX, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xbb, name: "LAS_ABY_BB", cycles: 4, opcode: Opcode.LAS, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0xbc, name: "LDY_ABX", cycles: 4, opcode: Opcode.LDY, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0xbd, name: "LDA_ABX", cycles: 4, opcode: Opcode.LDA, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0xbe, name: "LDX_ABY", cycles: 4, opcode: Opcode.LDX, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0xbf, name: "LAX_ABY_BF", cycles: 4, opcode: Opcode.LAX, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0xc0, name: "CPY_IMM", cycles: 2, opcode: Opcode.CPY, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xc1, name: "CMP_IZX", cycles: 6, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0xc2, name: "NOP_IMM_C2", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xc3, name: "DCP_IZX_C3", cycles: 8, opcode: Opcode.DCP, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0xc4, name: "CPY_ZP", cycles: 3, opcode: Opcode.CPY, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xc5, name: "CMP_ZP", cycles: 3, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xc6, name: "DEC_ZP", cycles: 5, opcode: Opcode.DEC, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xc7, name: "DCP_ZP_C7", cycles: 5, opcode: Opcode.DCP, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xc8, name: "INY", cycles: 2, opcode: Opcode.INY, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xc9, name: "CMP_IMM", cycles: 2, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xca, name: "DEX", cycles: 2, opcode: Opcode.DEX, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xcb, name: "AXS_IMM_CB", cycles: 2, opcode: Opcode.AXS, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xcc, name: "CPY_ABS", cycles: 4, opcode: Opcode.CPY, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xcd, name: "CMP_ABS", cycles: 4, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xce, name: "DEC_ABS", cycles: 6, opcode: Opcode.DEC, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xcf, name: "DCP_ABS_CF", cycles: 6, opcode: Opcode.DCP, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xd0, name: "BNE", cycles: 2, opcode: Opcode.BNE, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0xd1, name: "CMP_IZY", cycles: 5, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0xd3, name: "DCP_IZY_D3", cycles: 8, opcode: Opcode.DCP, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0xd4, name: "NOP_ZPX_D4", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xd5, name: "CMP_ZPX", cycles: 4, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xd6, name: "DEC_ZPX", cycles: 6, opcode: Opcode.DEC, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xd7, name: "DCP_ZPX_D7", cycles: 6, opcode: Opcode.DCP, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xd8, name: "CLD", cycles: 2, opcode: Opcode.CLD, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xd9, name: "CMP_ABY", cycles: 4, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0xda, name: "NOP_DA", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xdb, name: "DCP_ABY_DB", cycles: 7, opcode: Opcode.DCP, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0xdc, name: "NOP_ABX_DC", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0xdd, name: "CMP_ABX", cycles: 4, opcode: Opcode.CMP, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0xde, name: "DEC_ABX", cycles: 7, opcode: Opcode.DEC, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0xdf, name: "DCP_ABX_DF", cycles: 7, opcode: Opcode.DCP, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0xe0, name: "CPX_IMM", cycles: 2, opcode: Opcode.CPX, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xe1, name: "SBC_IZX", cycles: 6, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0xe2, name: "NOP_IMM_E2", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xe3, name: "ISC_IZX_E3", cycles: 8, opcode: Opcode.ISC, illegal: true, addressingMode: AddressingMode.IndX, specialCycles: false),
  Instruction(nr: 0xe4, name: "CPX_ZP", cycles: 3, opcode: Opcode.CPX, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xe5, name: "SBC_ZP", cycles: 3, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xe6, name: "INC_ZP", cycles: 5, opcode: Opcode.INC, illegal: false, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xe7, name: "ISC_ZP_E7", cycles: 5, opcode: Opcode.ISC, illegal: true, addressingMode: AddressingMode.ZeroPage, specialCycles: false),
  Instruction(nr: 0xe8, name: "INX", cycles: 2, opcode: Opcode.INX, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xe9, name: "SBC_IMM", cycles: 2, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xea, name: "NOP", cycles: 2, opcode: Opcode.NOP, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xeb, name: "SBC_IMM_EB", cycles: 2, opcode: Opcode.SBC, illegal: true, addressingMode: AddressingMode.Immediate, specialCycles: false),
  Instruction(nr: 0xec, name: "CPX_ABS", cycles: 4, opcode: Opcode.CPX, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xed, name: "SBC_ABS", cycles: 4, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xee, name: "INC_ABS", cycles: 6, opcode: Opcode.INC, illegal: false, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xef, name: "ISC_ABS_EF", cycles: 6, opcode: Opcode.ISC, illegal: true, addressingMode: AddressingMode.Absolute, specialCycles: false),
  Instruction(nr: 0xf0, name: "BEQ", cycles: 2, opcode: Opcode.BEQ, illegal: false, addressingMode: AddressingMode.Relative, specialCycles: true),
  Instruction(nr: 0xf1, name: "SBC_IZY", cycles: 5, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.IndY, specialCycles: true),
  Instruction(nr: 0xf3, name: "ISC_IZY_F3", cycles: 8, opcode: Opcode.ISC, illegal: true, addressingMode: AddressingMode.IndY, specialCycles: false),
  Instruction(nr: 0xf4, name: "NOP_ZPX_F4", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xf5, name: "SBC_ZPX", cycles: 4, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xf6, name: "INC_ZPX", cycles: 6, opcode: Opcode.INC, illegal: false, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xf7, name: "ISC_ZPX_F7", cycles: 6, opcode: Opcode.ISC, illegal: true, addressingMode: AddressingMode.ZeroPageX, specialCycles: false),
  Instruction(nr: 0xf8, name: "SED", cycles: 2, opcode: Opcode.SED, illegal: false, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xf9, name: "SBC_ABY", cycles: 4, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.AbsoluteY, specialCycles: true),
  Instruction(nr: 0xfa, name: "NOP_FA", cycles: 2, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.None, specialCycles: false),
  Instruction(nr: 0xfb, name: "ISC_ABY_FB", cycles: 7, opcode: Opcode.ISC, illegal: true, addressingMode: AddressingMode.AbsoluteY, specialCycles: false),
  Instruction(nr: 0xfc, name: "NOP_ABX_FC", cycles: 4, opcode: Opcode.NOP, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0xfd, name: "SBC_ABX", cycles: 4, opcode: Opcode.SBC, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: true),
  Instruction(nr: 0xfe, name: "INC_ABX", cycles: 7, opcode: Opcode.INC, illegal: false, addressingMode: AddressingMode.AbsoluteX, specialCycles: false),
  Instruction(nr: 0xff, name: "ISC_ABX_FF", cycles: 7, opcode: Opcode.ISC, illegal: true, addressingMode: AddressingMode.AbsoluteX, specialCycles: false)]
  ## Every instruction, by number. The jamming opcodes have none.

const instructionByNr*: array[256, Option[Instruction]] = (func: array[256, Option[Instruction]] =
  for instruction in instructions: result[instruction.nr] = some(instruction))()
  ## The instruction for each opcode, none for the ones that jam.

func find*(opcode: Opcode, mode: AddressingMode): Option[Instruction] =
  ## The instruction for an opcode in an addressing mode. Where there are
  ## several, the last one in `instructions`.
  for instruction in instructions:
    if instruction.opcode == opcode and instruction.addressingMode == mode:
      result = some(instruction)

func find*(opcode: Opcode): OrderedTable[AddressingMode, Instruction] =
  ## The opcode's instructions by addressing mode, the last one where there are several.
  for instruction in instructions:
    if instruction.opcode == opcode:
      result[instruction.addressingMode] = instruction
