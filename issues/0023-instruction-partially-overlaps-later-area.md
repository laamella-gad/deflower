---
title: A decoded instruction partially overlapping a later area corrupts it
status: open
labels: bug
---

`FlowAnalyser.analyseCodeFlow` only checks `memory[startAddress].area` before decoding (`FlowAnalyser.java:25`). A multi-byte instruction (2 or 3 bytes) can start at a free address but run into an address already owned by another `Area` (a `DataArea` from a `.flo` annotation, or a previously-registered `InstructionArea`).

`Subject.registerBlock` (`Subject.java:58`) has no overlap check: it unconditionally overwrites `memory[a].area` for every byte of the new block, so the tail of the mis-decoded instruction silently steals ownership of bytes that belonged to the other area. The other area's `Area` object is left in place at its own address but some of its later cells now point at the instruction instead — a half-overwritten area that `ResultWriter` will print wrong (e.g. a `DataArea` whose declared size no longer matches how many cells actually still point at it).

This is the mirror case of what's already handled at the *start* of an instruction (jumping into an area that already exists is caught and logged as "Jumping into non-code area"). Nothing catches the case where decoding starts cleanly but the instruction's own length carries it into a later area.

Done when: `registerBlock`, or a check before it in `FlowAnalyser`, detects an area boundary crossed mid-instruction and stops/logs instead of silently overwriting, and a test (e.g. a single-byte `DataArea` placed where a 3-byte instruction's operand bytes would land) confirms the data area survives untouched.
