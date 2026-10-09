---
title: Implement the `{ }` block syntax as address-offset scoping
status: open
labels: enhancement
---

The grammar (`Flo.g4`) already has the tokens for a block: `statement: ... | expr+ '{'? # line | '}' # endBlock`. Issue 0030 flagged this as dead grammar surface - `SubjectConfigurer` never acts on `'{'` or `'}'` at all, so a block currently parses but does nothing.

Intended semantics: a line ending in `{` opens a block whose base address is that line's own expression (e.g. a chip's base address). Every line's address *inside* the block, until the matching `}`, is an offset added to that base, not an absolute address. This reads naturally for hardware register maps, where the chip's base address is set once and every register is documented by its small, well-known offset from it - e.g. the SID chip at `$D400`:

```
$d400 system sid {
    $00 word freq1
    $02 word pw1
    $04 byte control1
    ...
}
```

`sid`'s own address is `$D400`; `freq1` is really at `$D400 + $00 = $D400`, `control1` at `$D400 + $04`, etc. Without the block, every one of those lines has to spell out the full absolute address (`$d404 byte control1`) and the chip's base address relationship is implicit, easy to get wrong when copying a register map from a datasheet (which is always expressed as offsets from a base).

Scope:

- **Grammar**: tokens already exist (`line`'s optional `'{'`, `endBlock`'s `'}'`) - likely no grammar change needed, just listener implementation. Worth double-checking nesting isn't silently allowed when it shouldn't be (or deciding it should be, if a chip's register map ever nests further - probably not needed for v1).
- **`SubjectConfigurer`**: track a current base-address stack (or just a single current base, if nesting isn't supported) pushed on `'{'` lines (via a new `enterLine`/`exitLine` or `enterEndBlock`/`exitEndBlock` listener method) and popped on `'}'`. While a block is open, every subsequent line's own address expression is added to the base instead of used as-is.
- **The opening line itself**: `$d400 system sid {` both declares `sid` as a (likely `system`, non-code/non-data) label at the absolute address *and* opens the block - the `{` doesn't change how that line's own address is interpreted, only the lines after it.
- **Labels inside the block**: should still resolve/print normally (`freq1` at `$D400`, not `sid + $00`) - the offset is purely an input-side convenience, the output model shouldn't need to know a block was ever used.

Done when: a `.flo` block (`base { ... lines with offset addresses ... }`) resolves every inner address as `base + offset`, with a fixture modeled on a real hardware register map (SID chip base + a handful of register offsets is the ready-made example) confirming both the resolved absolute addresses and that labels inside the block print and resolve exactly as if they'd been declared with full absolute addresses.
