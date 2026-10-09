---
title: Document the .flo line shape and keywords authoritatively
status: done
labels: documentation
---

Follow-up of issue 0030. The `.flo` convention is only learned from examples. Someone writing or editing `.flo` lines from the `.asm` output, especially an AI, needs one authoritative description to generate against.

Document it in two places: a comment at the top of `Flo.g4`, and the Input section of `CLAUDE.md`. Cover:
- the statement kinds:
  - `deflower <file>`: starts a run and loads a `.vsf`/`.prg`, relative to the `.flo` file;
  - annotation lines;
  - `;`/`#` comments, which attach to the next annotation line;
- the annotation line shape from issue 0050: `(address | start-end) [virtual] [type[size]] [label] [export ID] ['{']`, with what each part means:
  - the range end is exclusive;
  - the size expression allows `*`/`+`, decimal or `$hex`;
  - a line with no type is an `UNKNOWN` placeholder;
  - a size of 0 is an error;
- the reserved words (`deflower`, `virtual`, `export`, `char`, `byte`, `word`, `dword`, `code`), which can't be used as labels;
- the label character set (`[A-Za-z0-9._?]`);
- that `export` and `{`/`}` parse but have no effect yet.

Best done together with, or right after, issue 0050, so the description matches the grammar.

## Closing note

Done.
- **`Flo.g4`** now starts with a comment describing the whole format:
  - `deflower` runs and their output names;
  - comments, which go on their own line (a trailing comment is a parse error, checked by hand);
  - the annotation line shape from 0050, part by part: address formats; the exclusive range end; a `[size]` ignored next to a range; `virtual`; types and placeholders; `code`'s ignored size; size expressions and the zero-size error; the label characters and reserved words; `export`/`{ }` having no effect yet;
  - the overlap rule (placeholder, identical or conflict);
  - a short example.
- **`CLAUDE.md`**'s Input section now points to that comment as the authoritative description, with a short summary.

The claims in the comment were checked by hand: blank lines, indentation and uppercase hex are accepted, `code[3]` parses, and a trailing comment fails. Grammar comments don't change the generated parser; the build passes and the tests are unaffected.
