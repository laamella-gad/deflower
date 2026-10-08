---
title: A decoded instruction partially overlapping a later area corrupts it
status: done
labels: bug
---

`FlowAnalyser.analyseCodeFlow` only checks `memory[startAddress].area` before decoding (`FlowAnalyser.java:25`). A multi-byte instruction (2 or 3 bytes) can start at a free address but run into an address already owned by another `Area` (a `DataArea` from a `.flo` annotation, or a previously-registered `InstructionArea`).

`Subject.registerBlock` (`Subject.java:58`) has no overlap check: it unconditionally overwrites `memory[a].area` for every byte of the new block, so the tail of the mis-decoded instruction silently steals ownership of bytes that belonged to the other area. The other area's `Area` object is left in place at its own address but some of its later cells now point at the instruction instead — a half-overwritten area that `ResultWriter` will print wrong (e.g. a `DataArea` whose declared size no longer matches how many cells actually still point at it).

This is the mirror case of what's already handled at the *start* of an instruction (jumping into an area that already exists is caught and logged as "Jumping into non-code area"). Nothing catches the case where decoding starts cleanly but the instruction's own length carries it into a later area.

Related to [0018](0018-area-conflicts-silently-overwritten.md) (now done): `registerBlock` logs this conflict as of that fix, so it's no longer silent. Still open here because logging isn't enough — the done criterion below (the data area surviving untouched) needs the instruction to actually stop short of overwriting it, which 0018 didn't add.

Done when: `registerBlock`, or a check before it in `FlowAnalyser`, detects an area boundary crossed mid-instruction and stops/logs instead of silently overwriting, and a test (e.g. a single-byte `DataArea` placed where a 3-byte instruction's operand bytes would land) confirms the data area survives untouched. ✅

Fixed, the better way around: don't let decoding start at all if it would run into an existing area, rather than decode first and patch up the damage after. `FlowAnalyser.analyseCodeFlow` already refused to decode when the *start* address was inside a non-code area ("Jumping into non-code area"); it now also checks the rest of the instruction's own bytes (`instruction.addressingMode.totalBytes`) before creating the `InstructionArea` at all, and bails out the same way ("Instruction at ... would run into ..., not disassembling") if any of them already belong to another `Area`. `Subject.registerBlock` is unchanged - it's never even called for this case, so no conflict gets logged and the other area is never touched.

New fixture `partialoverlap/`: a 3-byte `LDA $4234` at $C000 whose last operand byte would land on a single-byte `DataArea` declared at $C002. `DeflowerTest.doesNotDisassembleIntoAnExistingArea` confirms the output has `guard`'s `.BYTE $42` intact, nothing decoded as code at $C000/$C001, and no area conflict logged.
