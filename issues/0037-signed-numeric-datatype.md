---
title: Add a signed numeric DataType (64tass's `.char`/`.sint`/`.lint`/`.dint`)
status: open
labels: enhancement
---

Split out of issue 0036. 64tass (https://tass64.sourceforge.net/, "Storing numeric values") has signed counterparts for every unsigned size it supports:

- `.char` - 8-bit signed (-128-127)
- `.sint` - 16-bit signed (-32768-32767)
- `.lint` - 24-bit signed (-8388608-8388607)
- `.dint` - 32-bit signed (-2147483648-2147483647)

Deflower has no signed numeric type today - `DataType.java` has `CHAR(1), BYTE(1), WORD(2), DWORD(4), POINTER(2), UNKNOWN(1)`, all unsigned (or, for `CHAR`, not numeric at all - see below). A disassembler run into a genuinely signed value (a speed/delta table, a relative Y-offset, a signed velocity) currently has no way to say so: it prints as a plain unsigned `.BYTE`/`.WORD` with no indication the top bit is a sign, and the reader has to work out the two's-complement value by hand.

The naming collision that blocked doing this directly in 0036: 64tass's `.char` is a signed-**integer** directive, unrelated to text - it's not the same thing as deflower's existing `DataType.CHAR`, which is a printable-ASCII-literal byte (`AssemblyFileFormat.asChar(...)`, quoted `'A'` or falls back to hex) emitted today under `.BYTE`. A character constant like `'A'` happens to evaluate to a plain number (65) that's in range for 64tass's `.char`, so reusing it for deflower's existing printable-character type would still assemble correctly - but the directive's *name* is about signedness, not characters, so doing that would be a bit of a misnomer baked into the output.

Decide between:

1. Add a real signed-byte `DataType` (distinct from `CHAR`), and give it/`WORD`/`DWORD` signed siblings as needed, output under `.char`/`.sint`/`.lint`/`.dint`. Leaves the existing printable-character `CHAR` type alone (keep it on `.BYTE`, or move it to whatever 64tass directive is actually about text - see issue 0039).
2. Repurpose the existing `CHAR` type's output directive to `.char` anyway, accepting the name mismatch (it would still be printing printable-ASCII literals, just under 64tass's signed-byte directive name).

Done when: a decision is made and a signed value (at minimum, a signed byte; `.sint`/`.lint`/`.dint` as needed if a fixture calls for the bigger sizes) can be declared in a `.flo` file and prints under the matching 64tass directive, two's-complement value shown correctly, with a fixture covering it.
