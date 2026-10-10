---
title: Detect the lda/sta/lda/sta address setup pattern and annotate the address as data
status: open
priority: medium
labels: enhancement
---

6502 code sets up a pointer by storing the two halves of a constant address:

```
		lda #$00
		sta $fb
		lda #$c0
		sta $fc
```

`$c000` is almost always the start of something the code reads or writes through the pointer: a table, a text, a sprite image, a screen. Today deflower doesn't notice. `$c000` gets no label, and unless the `.flo` file declares it, it isn't marked as data either. So the reader has to find these pairs by hand, work out the address, and annotate it.

Want: while `FlowAnalyser` decodes code, it detects the pattern and annotates the address the two immediates build as data:
- give it a label (`dXXXX`, like the other automatic data labels) unless it already has one;
- mark it as data, so a jump into it is reported and the trace doesn't decode it as code.

The pattern, at its simplest:

```
lda #lo
sta target
lda #hi
sta target + 1
```

This is the detection that [0034](0034-support-hi-lo-byte-extraction-operators.md) needs before it can print the immediates as `#<label`/`#>label`.

## To decide

- **How strict the match is.** The four instructions in a row only, or also:
  - the high byte first;
  - `ldx`/`stx` or `ldy`/`sty`;
  - other instructions in between that don't touch the register or the target;
  - one `lda` stored to several targets.

  Recommendation: start with four instructions in a row, in either order, using the same register for both halves, and nothing in between. A label on any of the four ends the match, because the code could be entered there.
- **What "annotate as data" registers.**
  - A label only?
  - A one-byte `UNKNOWN` placeholder that the `.flo` file can still narrow without a conflict?
  - Nothing at all when the address is already covered, by an area, by the ROM, or by I/O?

  Recommendation: a label and a one-byte placeholder, and only for addresses not yet covered.
- **The target.** Should `target` be typed as an `addr` (a pointer) as well? 0034 only prints `<`/`>` for stores into a `word` or `addr` area.
- **False positives.** Two halves that happen to look like an address, e.g. a color and a counter stored to adjacent zero page bytes. The match has to rely on `target`/`target + 1` being adjacent. Should anything else count, such as the target being used indirectly (`(target),y`) elsewhere in the trace?
- **Order.** The analyser has a stack of entry points. An address annotated as data can stop a later trace that the user meant as code. A `code` line in the `.flo` file should win over the detected data.

Done when:
- a small fixture with the pattern shows the built address labelled and marked as data;
- the existing fixtures' changed `expected.asm` files are reviewed with snipsert, with each new label checked against the program;
- immediates that aren't such a pair are unaffected.
