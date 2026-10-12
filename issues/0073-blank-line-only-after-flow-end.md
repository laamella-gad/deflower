---
title: Only put a blank line between an instruction and a label when the instruction ends the flow
status: done
labels: enhancement
---

`AssemblyFileFormat.printAnnotation` (in `ResultWriter.java`) puts a blank line above every label that doesn't continue a same-type data run. In code, that splits a routine at every branch target, even where execution simply falls through into the label. From fixture `zwark`:

```
move_enemies:
		lda #$04

l9572:
```

```
		sta score_hi, y
		bcc l9338

l9338:
```

The blank lines suggest a break in the flow that isn't there, and every loop inside a routine is cut into pieces.

Want: between an instruction and a label, print a blank line only when that instruction ends the flow, so execution can't fall through into the label:
- `jmp` (absolute and indirect),
- `rts`,
- `rti`,
- `brk`?

After any other instruction, including conditional branches and `jsr`, print the label on the next line with no blank line:

```
move_enemies:
		lda #$04
l9572:
```

Unchanged: labels after data, labels before data, and labels at a `*=` origin keep their current separators.

## To decide

- **`brk`**: it ends the flow on the 6502, but in some programs it is a placeholder or padding. Treat it like `rts`?
- **Comments**: should a label with a comment from the `.flo` file still get a blank line above it after a fall-through instruction, so the comment stands out?
- **Instructions without a label**: should a flow-ending instruction followed directly by another instruction (dead code, or code reached only by a jump) also get a blank line after it, even when there is no label?

Done when: the generated `.asm` files have no blank line between a fall-through instruction and the label after it, they keep a blank line after `jmp`/`rts`/`rti`, the changed `expected.asm` files are reviewed with snipsert, and all tests pass.

## Decisions

- **`brk`** ends the flow, like `rts`.
- **Comments:** a label with a comment gets no blank line of its own after a fall-through instruction.
- **Instructions without a label:** a flow-ending instruction followed directly by another instruction gets a blank line after it.

## Closing note

`InstructionArea.endsFlow` is true for `jmp`, `rts`, `rti` and `brk`. `AssemblyFileFormat.printAnnotation` leaves out the blank line above a label on code when the instruction printed before it falls through, and `printInstruction` adds one before an instruction that directly follows a flow end. A `*=` origin and labels on data keep their separators. Only blank lines changed in the fixtures' expectations; the small ones still reassemble to their `.prg`.

Seen on the way: `FlowAnalyser` treated `rti` like any other instruction and traced on after it (`3dgolf_snap`, `rti` then `jmp kernal_irq`). Fixed: tracing now stops after `rti`. That left two gaps in `3dgolf_snap`, which `3dgolf_snap.flo` now annotates: `$a587 code` (the leftover `jmp kernal_irq`) and `$a687 byte nmi_active`. Also fixed: a comment-only annotation on an instruction no longer gets a blank line between the comment and the instruction.
