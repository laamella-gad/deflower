---
title: An address has one label, whatever memory is banked in there
status: open
priority: low
labels: enhancement
---

On the C64, `$d000-$dfff` is either I/O (VIC, SID, CIAs, colour RAM) or the character ROM, chosen by the CPU port at `$01`. A `.flo` file can give an address only one label, so naming the I/O registers also renames every access to the character ROM at the same address.

Seen in fixture `1nvader_snap`. `build_charset` (`$4fd4`) clears bit 2 of `$01` to see the character ROM and copies it to `$2000`:

```
		lda sprite0_x, x
		sta $2000, x
		...
		lda $d300, x
		sta $2300, x
		lda voice1_frequency, x
		sta $2400, x
		lda $d500, x
		sta $2500, x
```

`$d000` and `$d400` get the VIC and SID register names from the `.flo` file's I/O blocks, while `$d300` and `$d500` print as plain numbers because no register is named there. All of them are character ROM reads, so the names are wrong.

The same applies to `$a000-$bfff` and `$e000-$ffff` (BASIC/KERNAL ROM or RAM). See [0066](0066-snapshot-rom-areas-are-not-in-the-image.md) for the ROM contents themselves.

Options to decide between:
1. **Per-operand override.** Let a `.flo` line say how one instruction's operand prints (a raw number, or a given label), e.g. keyed on the instruction's address. Simple, but has to be repeated for every such instruction.
2. **Per-range banking.** Declare that a code range runs with a given memory configuration (e.g. `$4fd4-$5020` sees the character ROM), and give labels to a bank (e.g. a `charrom` label set). Operands in that range resolve against that bank's labels.
3. **Leave it.** Document it as a limit and accept the wrong names.

Done when: `1nvader_snap`'s `build_charset` no longer prints VIC/SID register names for its character ROM reads, and the chosen way is documented in `Flo.g4`'s format comment if it involves the `.flo` file.
