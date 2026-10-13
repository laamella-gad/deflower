---
title: Support tass64's `<`/`>` hi/lo byte extraction operators in output
status: done
labels: enhancement
---

tass64 (https://tass64.sourceforge.net/, "Bit string extraction operators") has prefix operators for pulling one byte out of a 16-bit value: `<expr` is the low byte, `>expr` is the high byte.

6502 code sets up an address variable by loading the two halves of an address as constants and storing them into it:

```
LDA #$00      ; low byte of $C000
STA $FB
LDA #$C0      ; high byte of $C000
STA $FC       ; $FB/$FC now holds $C000
```

If `$C000` has a label, `level_data`, the constants can say what they are: `LDA #<level_data` and `LDA #>level_data`. Today deflower prints `#$00` and `#$C0`, and the reader has to work out that they belong together.

**Blocked by [0074](0074-detect-address-setup-pattern.md).** That issue detects the pattern and annotates the address it builds; this one only changes how the immediates are printed.

## Decisions

- **Only immediates stored into a typed address variable.** `<`/`>` are used only when two immediate values are stored into the low and the high byte of an area typed `word` (or `addr`, [0041](0041-user-declarable-address-pointer-type.md)). With `$fb virtual addr target` in the `.flo` file, the example prints as:

  ```
  LDA #<level_data
  STA target
  LDA #>level_data
  STA target + $1
  ```

- **Both halves are needed.** One half alone doesn't say which address it belongs to, so the low and high store have to be paired to form the address, and its label is printed. Without a label at that address, or without a pair, the immediates stay numeric. Nothing is guessed at stores into untyped memory.
- **Memory loads are out of scope.** The original version of this issue also proposed printing `LDA snk_head_loc_hi` (a load from memory) or `label + $01` (an operand inside a word) as `>label`. That is wrong: those read a byte at an address, while `#>label` is a constant, the high byte of the label's own address. They stay as they are.

Points to settle while implementing: how far apart the two stores may be (same basic block, or any order within the flow), and which loads count (`LDA`/`LDX`/`LDY` immediate, followed by the matching `STA`/`STX`/`STY`).

Done when: the address-setup idiom storing into a `word`-typed area prints `#<label`/`#>label`, with a fixture covering it, and immediates that aren't such a pair are unchanged.

## Closing note

Rejected: too complex for little gain. Even limited to the exact four-instruction pattern (`lda #lo`, `sta target`, `lda #hi`, `sta target + $1`, register A only, low byte first, no label in between), it needs pattern detection across instructions, plus a rule for which label to print, to improve a handful of operands. No code was written.

## Reopened

Reopened with the pattern detection split off into [0074](0074-detect-address-setup-pattern.md), which removes most of the complexity that got this rejected. Once 0074 finds the pairs and gives the built address a label, printing `#<label`/`#>label` for the paired immediates is a change to the output only.

## Closing note (reopened)

Done with [0074](0074-detect-address-setup-pattern.md): the immediates of an address setup into an `addr` print as `#<label` and `#>label` (`AssemblyFileFormat.nameForImmediate`). Only for a label on the address itself: for an address inside an array, 64tass reads `#<label + $22` as the low byte of the sum, but mpu6502's `SourceParser` as the low byte of `label` plus `$22`, and it has no parentheses. Those immediates stay numeric. A built address only keeps an included label or virtual area from being dropped when it prints that way.
