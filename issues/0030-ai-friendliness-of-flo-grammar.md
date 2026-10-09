---
title: Investigate whether the .flo format/grammar is easy to use, including for an AI writing it
status: done
labels: enhancement
---

The `.flo` format is the tool's entire interface - the user's loop is "run, read `out/deflowered.asm`, edit the `.flo`, run again". Worth checking whether the grammar (`src/main/antlr4/com/laamella/enflower/Flo.g4`) and its listener (`SubjectConfigurer`) make that loop easy to get right, by hand or by an AI generating/editing `.flo` lines from the disassembly output.

Findings from reading the grammar and real fixtures (`squirm.flo`, `zwark.flo`):

1. **A `line` is just `expr+`, with no fixed shape.** `statement: expr+ '{'? # line`, and `expr` is a flat alternation of address/range/mul/datatype/system/export/label. Nothing in the grammar says a line is "address, then optional datatype, then optional label" - any expr can appear any number of times in any order. The actual shape (address first, datatype applies via `setSize` wrapping an address expr, label last) is a convention enforced only by how `SubjectConfigurer`'s listener happens to consume tokens, not something the grammar checks or an AI could infer from it alone.

2. **Repeating an expr silently keeps the last value, with no error.** `enterSetLabel` does `name = ctx.ID().getText()` - a second `ID` on the same line just overwrites `name`, no warning. Same for `enterDatatype` (last datatype wins) and `enterAddress`. A line with two labels or two datatypes parses fine and silently drops all but the last.

3. **Any bare word that isn't a reserved keyword is silently swallowed as a label-that-gets-overwritten.** Because `ID` matches any run of `[A-Za-z0-9._?]`, a decorative word placed where a human (or AI) might expect a type or unit annotation becomes a real `setLabel` expr, immediately discarded if a later real label follows. Real examples already in the fixtures:
   - `squirm.flo:188`: `$d800 system bytes color_ram` - `bytes` is not a keyword (`byte` is), so it's parsed as a throwaway label, overwritten by `color_ram`.
   - `squirm.flo:48`: `$138a 40x25 bytes title` - both `40x25` and `bytes` are throwaway labels, overwritten by `title`.
   - Every plain `data` line (e.g. `$0057 data player_direction`) - `data` isn't a keyword either (no `DATA` token exists; only `char`/`byte`/`word`/`dword`/`code`), so it's a throwaway label too, and the real datatype silently defaults to `BYTE_BLOCK` (`LineType type = BYTE_BLOCK` in `startNewLine`). The file reads as if `data` were a type keyword meaning "some data here"; it is actually dead weight that happens to parse.

   None of this errors. An AI (or a human) writing `$1234 data16 foo` expecting a 16-bit hint, or `$1234 word thing comment-ish-word`, gets a silently-swallowed label and unexpected defaults instead of a parse error pointing at the mistake.

4. **Grammar features with no real usage found anywhere in the fixtures:** the `'{'?`/`endBlock '}'` block syntax, and `export ID`. Dead surface area that still has to be reasoned about when reading or generating against the grammar.

5. **Keywords are plain lowercase words, not visually distinguished from labels/addresses** (`deflower`, `system`, `export`, `char`/`byte`/`word`/`dword`/`code`), and the grammar has no reserved-word list check - `ID` and the keyword tokens are both just "a run of word characters", disambiguated only by ANTLR's implicit token-definition-order priority. Easy to accidentally shadow a keyword with a label of the same text, or vice versa, with no diagnostic.

None of this is necessarily wrong for a human who already knows the convention by heart (as the project's `.flo` files show, it's workable), but it's the kind of looseness that specifically hurts an AI trying to generate or edit `.flo` lines from the `.asm` output without already having memorized the unwritten convention: no parse errors to react to, silent overwrites instead of conflicts, and decorative words that look meaningful but aren't.

Done when: a decision is made on whether to (a) tighten the grammar to give structural errors for the cases above (duplicate datatype/label on one line, unrecognized bare word where a keyword might be expected), (b) document the actual line shape and reserved words explicitly (e.g. in CLAUDE.md or a grammar comment) so an AI has something authoritative to generate against instead of inferring convention from examples, or (c) both - and, if any, follow-up issues are filed for the concrete changes.

## Closing note

Re-checked against the current grammar (after 0044, 0046 and 0049):
- Findings 1 and 2 still hold: lines are free-form `expr+`, and a repeated part silently overwrites the earlier one.
- Finding 3 still holds in the grammar, though the fixtures' throwaway words are gone: `system` became `virtual`, and the `data`/`bytes` lines were cleaned up.
- Finding 4: `{ }` and `export` are still unused and ignored.
- Finding 5 is harmless. A keyword always beats a label, so a label named `byte` is a parse error.

Every real fixture line already fits `address-or-range [virtual] [type[size]] [label]`.

The user decided:
- **both** tighten and document (option c);
- tighten to a **fixed order**;
- **keep** `export ID` and `{`/`}`;
- file follow-ups instead of implementing here.

Follow-ups:
- [0050](0050-fixed-flo-line-shape.md): a fixed line shape in the grammar, with parse errors for duplicates, wrong order, stray words and a missing address.
- [0051](0051-document-flo-format.md): document the line shape and reserved words in `Flo.g4` and `CLAUDE.md`.
