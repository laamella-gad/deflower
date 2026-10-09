---
title: Support 64tass text encodings (`.enc`/screen code) for CHAR output
status: done
labels: enhancement
---

64tass (https://tass64.sourceforge.net/, text encoding) selects a character-to-byte mapping with `.enc`. Two are built in - `"none"` (standard ASCII/Unicode) and `"screen"` (Commodore screen code) - and custom ones can be defined with `.cdef`/`.tdef`/`.edef` inside an `.encode`/`.endencode` block. The manual's own example: `"u"` is `$55` under `"none"` but `$15` under `"screen"`.

Deflower's `CHAR` rendering (`AssemblyFileFormat.asChar(...)` in `ResultWriter.java`) assumes the `"none"` mapping unconditionally: a byte prints as a quoted literal (`'A'`) only when it falls in `0x20-0x7E` (standard ASCII printable range), otherwise it falls back to hex. On a real C64 binary, though, on-screen text (score displays, menus, scrolltext - most of what a `char` annotation is actually for) is stored as **screen codes**, not ASCII/PETSCII: `'A'` is screen code `$01`, not `$41`. Those bytes don't fall in `asChar`'s `0x20-0x7E` check at all, so today every screen-code character silently falls back to a hex byte - the one case `CHAR` exists for is the one it currently can't render.

Scope:

- A way for a `.flo` line to say which encoding its `char` data uses - at minimum `none` vs `screen` (64tass's two built-ins); a custom `.cdef`/`.tdef`/`.edef`-style mapping would be a further extension, probably not needed for v1 since C64 disassembly is overwhelmingly either plain PETSCII/ASCII text or screen codes.
- `asChar` (or a successor) needs a per-encoding table to decide both *whether* a byte is printable and *what character* to quote it as, instead of the current hardcoded ASCII range check.
- The generated `.asm` output needs to actually say which encoding is in effect (emit `.enc "screen"` or `.enc "none"` near the data, matching 64tass's own directive) so the output reassembles to the exact same bytes - not just render nicely for a human reader.
- Interacts with issue 0039 (string-run detection → `.text`/`.null`/`.ptext`): whichever encoding a string run uses needs to be in effect before that directive, and the same quoting/printability table applies either way (one character at a time today, one string at a time once 0039 lands).

Done when: a `.flo` line can declare a `char`/string area as `screen`-encoded (in addition to today's implicit `none`), the output renders screen-code bytes as their correct human-readable character instead of falling back to hex, and the generated `.asm` carries the matching `.enc` directive so it reassembles correctly. A fixture with real screen-code text (there's precedent in `squirm`/`zwark`, both C64 binaries) anchors it.

## Closing note

Done.

Decisions taken:
- **No `.flo` syntax.** The encoding of `char` data is decided by a heuristic over the bytes themselves.
- **One decision per declared array.** That means the elements of one `char[n]` line: the same array label and consecutive indexes.
- **Rule: count uppercase letters.** Bytes in `$41`-`$5A` count for `none` and bytes in `$01`-`$1A` count for `screen`; the higher count wins.
  - Only uppercase counts. ASCII uppercase is also screen-code lowercase, so counting every quotable byte let a `$00` terminator or a length byte tip plain ASCII text over to `screen` (`"bye@"`).
- **A tie keeps the encoding already in effect.** This covers digits, reverse video and lowercase-only text, and avoids needless `.enc` switches.
- **64tass raw mode** (no `--ascii`), which the output already assumed for `char`. Under it `none` is the identity and `screen` maps:
  - `$00`-`$1F` → `@A-Z[\]^_`;
  - `$20`-`$3F` → themselves;
  - `$40`-`$5E` → `` `a-z{|}~ ``.

  I checked this against 64tass 1.59 by assembling every printable character under `.enc "screen"`.
- **Reverse video stays hex.** `$80`-`$FF` has no built-in 64tass encoding, so it prints as hex items, and so do `$5F`-`$7F` and the double quote.
- **`.enc` only on a switch.** The output starts in 64tass's default `none`. When a `.text` line opens under a different encoding, `.enc` goes on its own line right before it. An array that changes encoding mid-line starts a new line.

Accepted trade-offs:
- Lowercase-only ASCII ties, so after screen-code text it stays `screen` and prints as hex (`.text $61, $62, $63` instead of `"abc"`). The bytes are still right.
- Mixed-case screen text with as many lowercase as uppercase letters ties as well.

Changes:
- `ResultWriter`: `textPrint` takes the area, so it can call `encodingFor`, which decides the encoding once per array and caches it. `characterFor` maps a byte to its quoted character per encoding.
- New fixture `screencodes` (test `charArraysPickAsciiOrScreenCodeEncoding`). It covers mixed-case screen text, reverse video with a double quote and `@`, lowercase ASCII (tie), digits (tie), and an unlabelled screen-code array sharing their line. It also has uppercase ASCII switching back to `none`.
- squirm and zwark need no `.flo` change. Their screen-code strings now read as text, e.g. `.text "PRESS FIRE TO START"` and `"CRACKED BY MANIK"`. zwark's PETSCII `top_score_line`/`turns_text` stay `none`.

Review:
- Snipsert: squirm and zwark instruction lines are identical (checksum match), and `strings` and `datatypes` are unchanged.
- 64tass reassembles `screencodes`, `strings` and `datatypes` to exactly their `.prg` bytes.

30/30 green.
