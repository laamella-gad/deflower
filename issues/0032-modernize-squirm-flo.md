---
title: squirm.flo was written for an older version of deflower and needs modernizing
status: open
labels: cleanup
---

`src/test/resources/squirm/squirm.flo` predates several grammar/behavior changes and no longer reflects how a `.flo` file should be written today. Concretely:

- Nearly every data line uses the word `data` where a real datatype keyword belongs (`$0057 data player_direction`, `$2800 data charset`, ...). `data` isn't a keyword (`char`/`byte`/`word`/`dword`/`code` are the only ones) - see issue 0030. Each of these parses as a throwaway label that's immediately overwritten by the real one, and the datatype silently defaults to `byte`. That default happens to be right for most of these lines, but it's accidental, not declared.
- `$138a 40x25 bytes title` - `40x25` and `bytes` are both throwaway labels for the same reason (`bytes` isn't a keyword either; `byte` is).
- `$3ee4 byte voice_2_notes` further down *does* use the real keyword - the file is internally inconsistent about it, suggesting lines were added at different times under different understandings of the format.
- None of the `[n]`/`n*m` array-size syntax is used anywhere, even for the many clearly-array-shaped ranges (the `$xxxx-$yyyy data` ranges at the top, `title` as `40x25` bytes, `charset`, the player/bonus-guy character blocks at `$2a00`+). Those currently rely on the address-range form (`$2800-$2ff9 data`) or on nothing at all (single `data` lines that are really the first byte of a multi-byte sprite/char block, like `player_char_1`...`player_char_8` at 8-byte spacing).
- Several `# ???` placeholder comments remain from whatever investigation originally produced this file.

None of this currently breaks anything - `byte` is the listener's default type, so these lines produce the same output as if `byte` had been written explicitly - but the file is the project's main worked example and currently models exactly the sloppy, keyword-free style that issue 0030 flags as hard to read/generate correctly. Worth cleaning up so `squirm.flo` is the one fixture that shows idiomatic, current `.flo` style rather than a historical artifact.

Done when: `squirm.flo`'s `data` lines use the real `byte` keyword explicitly (or whatever datatype actually applies), the throwaway non-keyword words (`40x25`, `bytes`) are replaced with proper array-size syntax where one applies, and `squirm/expected.asm` is regenerated and reviewed (snipsert) to confirm the output is byte-for-byte unchanged - this is a pure `.flo`-style cleanup, not a behavior change. Stale `# ???` comments can be dropped or resolved, at the editor's judgement, while touching those lines anyway.
