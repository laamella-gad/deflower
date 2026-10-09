---
title: Support 64tass text encodings (`.enc`/screen code) for CHAR output
status: open
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
