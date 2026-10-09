---
title: Detect and support 64tass's `.rta` return-address-table idiom
status: open
labels: enhancement
---

Split out of issue 0036. 64tass (https://tass64.sourceforge.net/, "Storing numeric values") has `.rta` - "return address" constants, 16-bit, **stored as address-1**.

This is the classic 6502 jump-table idiom: a dispatch table of `.rta label` entries, each pushed onto the stack (lo/hi) so that a trailing `RTS` lands on `label` (since `RTS` pops an address and adds 1 to it). Code typically does something like: index into the table, push hi/lo, `RTS` - and the bytes sitting in the table are each `label - 1`, not `label` itself.

Deflower has no way to express this today. A `.flo` author marking up a return-address table has no annotation for "this word is one less than the address execution actually continues at" - the table just resolves as a plain 16-bit value/address, and the reader has to notice the off-by-one idiom themselves and mentally add 1 to every entry.

Scope:

- A way to mark a word (or array of words) as an `.rta`-style table in the `.flo` grammar - most likely a new `DataType`/keyword (`rta`?) alongside `word`/`pointer`.
- Output: print under `.rta` with the label resolved to the *actual* target (`label`, not `label - 1`) - i.e. `nameForAddress` needs to look up `address + 1` instead of `address` for this type, mirroring what the directive itself means.
- Possibly: `FlowAnalyser` could treat an `.rta` table as containing code entry points too (each entry is a real place execution continues, same as a jump table) - worth considering alongside issue 0031's placeholder-carving workflow, though that may be its own follow-up rather than part of this one.

Done when: a `.flo` line can mark a table as `rta`, it prints as `.rta` with correctly-resolved (not off-by-one) labels, and there's a fixture modeling a real RTS-trick dispatch table (push hi/push lo/RTS reading from the table) to anchor it.
