## Checks the opcode table against `opcodes.txt`, which the Java mpu6502
## printed: per opcode its name, addressing mode, illegal, cycles and special
## cycles, then the instruction's name, opcode, addressing mode, illegal,
## cycles and special cycles, or "-" where there is none.

import std/[options, os, strutils, tables, unittest]
import mpu6502

suite "specification":
  test "every opcode decodes like the Java table":
    var count = 0
    for line in lines(currentSourcePath.parentDir / "opcodes.txt"):
      let f = line.splitWhitespace
      let nr = parseHexInt(f[0])
      checkpoint line
      check opcodeName[nr] == f[1]
      check $addressingMode[nr] == f[2]
      check $illegal[nr] == f[3]
      check $cpuCycles[nr] == f[4]
      check $specialCycles[nr] == f[5]
      let instruction = instructionByNr[nr]
      if f[6] == "-":
        check instruction.isNone
      else:
        check instruction.isSome
        let i = instruction.get
        check i.nr == nr
        check i.name == f[6]
        check $i.opcode == f[7]
        check $i.addressingMode == f[8]
        check $i.illegal == f[9]
        check $i.cycles == f[10]
        check $i.specialCycles == f[11]
      inc count
    check count == 256

  test "total bytes":
    check AddressingMode.None.totalBytes == 1
    check AddressingMode.Relative.totalBytes == 2
    check AddressingMode.Indirect.totalBytes == 3

  test "find":
    check find(Opcode.LDA, AddressingMode.Immediate).get.nr == 0xa9
    check find(Opcode.JMP, AddressingMode.Immediate).isNone
    check find(Opcode.JMP).len == 2
