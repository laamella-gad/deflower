---
title: Instructions with a duplicate opcode don't reassemble to the same bytes
status: open
priority: low
labels: bug
---

Some mnemonics have several opcodes for the same addressing mode, all of them illegal but one. Deflower prints the mnemonic and operand, and an assembler can only turn that back into one of the opcodes. A program that uses another one doesn't reassemble to its own bytes.

The groups, with the opcode mpu6502's `SourceParser` assembles them to (the legal one, else the lowest), and the ones that don't come back:

| Mnemonic and mode | Assembles to | Other opcodes |
|---|---|---|
| `nop` | `$ea` | `$1a $3a $5a $7a $da $fa` |
| `nop #` | `$80` | `$82 $89 $c2 $e2` |
| `nop zp` | `$04` | `$44 $64` |
| `nop zp, x` | `$14` | `$34 $54 $74 $d4 $f4` |
| `nop abs, x` | `$1c` | `$3c $5c $7c $dc $fc` |
| `sbc #` | `$e9` | `$eb` |
| `anc #` | `$0b` | `$2b` |
| `jam` | `$02` | `$12 $22 $32 $42 $52 $62 $72 $92 $b2 $d2 $f2` |

64tass should be checked for the same choice. If it picks differently, the table above is what decides, since the round-trip tests ([0062](0062-snippet-test-factories.md)) and verify ([0075](0075-verify-flag.md)) use mpu6502.

None of the fixtures has one of these today; every snippet passes the round trip with `SourceParser`. They do turn up in real programs: `$eb` as `sbc #` in some packers and demos, the other `nop`s as padding or to skip bytes, and code traced into data easily decodes them.

Want: an instruction whose opcode isn't the one its mnemonic and mode assemble to prints as bytes, with the instruction in a comment, e.g.

```
		.byte	$eb, $01	; sbc #$01
```

## To decide

- **Form.** `.byte` with a comment as above, or a 64tass way to force the opcode if there is one.
- **Where the table lives.** Deflower could ask mpu6502 which opcode a mnemonic and mode assemble to, so the two can't disagree. That needs a public method on mpu6502's `Mnemonics`, which is package-private now.
- **Labels and cross-references.** The instruction still gets traced and its operand's target labelled; only the printing changes. A label on the operand prints as a define after the line, as for other multi-byte areas.

Done when: a fixture with each kind of duplicate (at least `$eb` and a `nop`) prints them as bytes and reassembles to its input.
