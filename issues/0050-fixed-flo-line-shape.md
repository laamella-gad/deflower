---
title: Give .flo annotation lines a fixed shape in the grammar
status: open
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
