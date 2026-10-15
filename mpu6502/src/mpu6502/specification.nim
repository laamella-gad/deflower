## The 6502's instructions: per opcode its mnemonic, addressing mode, cycles
## and whether it is illegal, and the instructions by number.

import std/[options, strutils, tables]

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
  ("ASL", Accumulator, false, 2, false),  # $0a
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
  ("ROL", Accumulator, false, 2, false),  # $2a
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
  ("LSR", Accumulator, false, 2, false),  # $4a
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
  ("ROR", Accumulator, false, 2, false),  # $6a
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
    ## Per opcode its addressing mode.
  cpuCycles*: array[256, int] = (func: array[256, int] =
    for nr, row in opcodeRows: result[nr] = row.cycles)()
  specialCycles*: array[256, bool] = (func: array[256, bool] =
    for nr, row in opcodeRows: result[nr] = row.specialCycles)()

const
  nameAbbreviations: array[AddressingMode, string] = ["", "IZX", "IZY", "", "ZP", "ZPX", "ZPY", "IMM", "ABS", "ABX",
      "ABY", "", "IND", ""]
  instructions*: seq[Instruction] = (func: seq[Instruction] =
    for nr, row in opcodeRows:
      if row.mode == AddressingMode.Jam: continue
      var name = row.name
      if nameAbbreviations[row.mode] != "": name &= "_" & nameAbbreviations[row.mode]
      if row.illegal: name &= "_" & nr.toHex(2)
      result.add Instruction(nr: nr, name: name, cycles: row.cycles, opcode: parseEnum[Opcode](row.name),
        illegal: row.illegal, addressingMode: row.mode, specialCycles: row.specialCycles))()
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
