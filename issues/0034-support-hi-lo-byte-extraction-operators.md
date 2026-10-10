---
title: Support tass64's `<`/`>` hi/lo byte extraction operators in output
status: open
priority: medium
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
