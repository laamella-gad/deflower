---
title: Give .flo annotation lines a fixed shape in the grammar
status: done
labels: enhancement
---

Follow-up of issue 0030. Today an annotation line is `expr+`: any mix of address, range, datatype, `virtual`, `export` and label, in any order and any number of times.
- A repeated part silently overwrites the earlier one: a second address, type or label wins.
- Any stray word is taken as a label and then overwritten by the next one (e.g. `$1234 data16 foo`).
- A line without an address only fails later, in `FloReader` ("Require an address"), not as a parse error.

## Decided design (from the user, in 0030)

A fixed order, matching what every fixture already uses:

```
line: (address | memoryRange) 'virtual'? datatype? ID? ('export' ID)? '{'?
```

- Address or range first, required.
- Then `virtual`, then the type with an optional `[size]`, then the label. Each part is optional and appears at most once.
- `export ID` and the `{` / `}` block syntax are **kept** (user decision), in the positions shown: export after the label, `{` at the end of the line, `}` on its own line as today. They stay unused by the code, as now.

A wrong order, a duplicate part, a stray word or a missing address then becomes a parse error with a line and column, through the existing "Failed to parse" path.

## Implementation notes

- Replace the `expr` alternatives with the fixed `line` rule. `setSize` (`expr datatype`) goes away, because the datatype is just a part of the line.
- Adjust `FloReader`'s listener to the new contexts. The "Require an address" check becomes unnecessary.
- Add `invalid/` fixtures with `assertFailsToParse` for each of these:
  - two labels;
  - two types;
  - type after the label;
  - a stray word (`$1234 data16 foo`);
  - no address.

Done when the above parse errors are reported, all existing fixtures pass unchanged, and the grammar has no `expr+` line rule any more.

## Closing note

Done as designed. In `Flo.g4`, an annotation line is now `(address | memoryRange) setVirtual? datatype? setLabel? export? '{'?`. `address`, `memoryRange`, `setVirtual`, `setLabel` and `export` became small rules of their own, so `FloReader`'s listener methods kept their names. The `expr` rule and `setSize` are gone, and so is the "Require an address" check in `FloReader`.

Found while testing: `prog` was `(statement NEWLINE)*` with no `EOF`. A line that couldn't start a statement, such as one with no address, ended the parse silently, and everything after it was ignored without an error. `prog` now ends in `EOF`. No existing fixture depended on that.

New `invalid/` fixtures, each failing through "Failed to parse" with a line and column:
- `two-labels` ("extraneous input 'second'");
- `two-types` ("mismatched input 'word'");
- `two-addresses`;
- `type-after-label`;
- `stray-word` (`$1234 data16 foo`);
- `no-address`.

Verification: 40/40 tests green. No `expected.asm` changed. screencodes, strings and datatypes still reassemble with 64tass.
