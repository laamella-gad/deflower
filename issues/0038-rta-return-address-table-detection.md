---
title: Detect and support 64tass's `.rta` return-address-table idiom
status: open
priority: low
labels: enhancement
---

Split out of issue 0036. 64tass (https://tass64.sourceforge.net/, "Storing numeric values") has `.rta` - "return address" constants, 16-bit, **stored as address-1**.

This is the classic 6502 jump-table idiom: a dispatch table of `.rta label` entries, each pushed onto the stack (lo/hi) so that a trailing `RTS` lands on `label` (since `RTS` pops an address and adds 1 to it). Code typically does something like: index into the table, push hi/lo, `RTS` - and the bytes sitting in the table are each `label - 1`, not `label` itself.

Deflower has no way to express this today. A `.flo` author marking up a return-address table has no annotation for "this word is one less than the address execution actually continues at" - the table just resolves as a plain 16-bit value/address, and the reader has to notice the off-by-one idiom themselves and mentally add 1 to every entry.

Scope:

- A way to mark a word (or array of words) as an `.rta`-style table in the `.flo` grammar - most likely a new `DataType`/keyword (`rta`?) alongside `word`/`addr`.
- Output: print under `.rta` with the label resolved to the *actual* target (`label`, not `label - 1`) - i.e. `nameForAddress` needs to look up `address + 1` instead of `address` for this type, mirroring what the directive itself means.
- Possibly: `FlowAnalyser` could treat an `.rta` table as containing code entry points too (each entry is a real place execution continues, same as a jump table) - worth considering alongside issue 0031's placeholder-carving workflow, though that may be its own follow-up rather than part of this one.

Done when: a `.flo` line can mark a table as `rta`, it prints as `.rta` with correctly-resolved (not off-by-one) labels, and there's a fixture modeling a real RTS-trick dispatch table (push hi/push lo/RTS reading from the table) to anchor it.

## Decisions

- **Keyword `rta`**, a type like `word`: `$c100 rta[4] handlers`, printed as `.rta label` with the label of value + 1.
- **The entries are traced as code.** Each entry + 1 is where an `RTS` lands, so it is pushed as a code entry point, like a `code` line. A table then disassembles its handlers without separate `code` lines.

## Analysis phases

If tables are ever detected from the code instead of only declared (the `pha`/`pha`/`rts` dispatch, reading its table at `table,x`), the detector finds new code entries, and those have to be traced too. That doesn't fit the current pipeline: `Deflower.deflower` runs the tracing once, then `AddressSetupFinder` ([0074](0074-detect-address-setup-pattern.md)), `Subject.dropUnusedIncludes` and `Subject.reportDuplicateLabels`, each exactly once.

A declared `rta` table doesn't need this: its entries are pushed before the tracing starts, like `code` lines.

Proposed structure, once something needs it:
- A `Phase` interface, `void run(Subject)`, with the analysis holding a list of phases instead of `Deflower` calling each step.
- Two kinds of phases. Ones that may find code (this detector) repeat with the tracing until no new entry turns up. Ones that only label or clean up (address setups, dropping unused includes, duplicate labels) run once afterwards, in order. The order matters: address setups must run before the unused includes are dropped, or the labels they keep are gone.
- `dropUnusedIncludes` and `reportDuplicateLabels` move out of `Subject` into phases.
- The tracing itself stays one phase: `FlowAnalyser`'s worklist loop, with its per-opcode cases, doesn't split into phases.

Not worth doing before then: today it is four fixed steps, and only one of them is an extra analysis.
