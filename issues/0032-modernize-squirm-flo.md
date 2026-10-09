---
title: squirm.flo was written for an older version of deflower and needs modernizing
status: done
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

## Closing note

Done. The "byte-for-byte unchanged" criterion no longer applied: this issue was written before 0031 (bare lines became `UNKNOWN` placeholders, not `byte`) and 0033 (array elements resolve to their own line's label, no scan). The output was reviewed via snipsert instead.

`squirm.flo` changes:
- The top-of-file anonymous ranges lost their bogus `data` label. They are now pure placeholders (no keyword, no label). The three text ranges (`$26ac-$26bf`, `$26c2-$26c8`, `$26cb-$26dc`) were dropped, because the sized text lines now cover them.
- Every `data` line now uses `byte`. Named blocks inside the big `$0fa0-$23f3` range are sized up to the next label: `byte[n]` in general, and `40*21 byte` for `level_1..3`/`title_screen_colors` (each exactly 840 bytes; `level_3` leaves one placeholder byte at `$20aa`). `title` (old `40x25 bytes`) is really 40*21 split as `title byte[765]` + `rest_of_title byte[75]`, with a comment saying so. `charset` is `8*64 byte`, and each `*_char_*` is `byte[8]`. `$d800 system bytes` became `system byte`.
- Single variables stay single `byte`, and their structure was not guessed (e.g. the snake tables look like interleaved lo/hi words but are left as-is).
- Text lines are sized: `press_fire_to_start_ byte[19]`, `get_ready_text byte[10]` and `bonus_run_text byte[10]` (both decode to complete 10-char reversed screen-code strings), `bonus_text byte[8]`. This now covers `$26c1`/`$26c8`/`$26c9`, which used to be gaps.
- `bonus_guy_char` was declared at both `$2684` and `$268e`, a duplicate label in the generated asm. Code references both addresses, so `$268e` is now `bonus_guy_char_2`.
- All `# ???` comments were dropped (they carried no information). The `; 3b20 screen 0400 charset 2800` note is kept.

Output effects (reviewed):
- The opcode sequence is identical (checksum match), and no conflicts were reported.
- All 50 `data + $X` references are gone. Refs into the screen/table/level blocks are named again (`high_score_screen + $1`, `level_2 + $2FD`, ...). Refs into the snake tables (`$265C`-`$267D`) are now plain hex, since that unlabeled placeholder region has no name to offset from.
- The `data:` labels are gone, and the `; ???` comments are gone from the output.
- There are new blank-line breaks where a placeholder run meets a deliberate `byte` run (the expected 0031 side effect).
- `bonus_guy_char` refs to `$268e` now read `bonus_guy_char_2`.
- 3 more `.byte` values appear (the filled text gaps).

27/27 tests green.
