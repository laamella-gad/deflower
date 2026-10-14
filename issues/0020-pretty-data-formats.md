---
title: Add pretty disassembly formats for known data shapes (charset, screen, sprite)
status: open
priority: low
labels: enhancement
---

`AssemblyFileFormat` prints byte data as flat `.byte` lines, 16 to a line. Known C64 data shapes deserve dedicated, readable output instead of a flat byte dump, e.g.:

- **character set**: 8 bytes per char, printed as 8 binary rows (so the pixel art is visible in the source).
- **40x25 character screen**: bytes grouped into rows of 40.
- **sprite**: 63 bytes (3 per row x 21 rows), grouped into rows of 3. Sprites usually sit 64 bytes apart, because the VIC-II fetches them from 64-byte blocks. The 64th byte means nothing to the sprite, but it isn't necessarily unused: a program may keep its own data there, like the sprite's color.

These would need new `.flo` data types (or annotations on the existing `byte`/array syntax) so the user can mark a block as one of these shapes, and corresponding formatting in the writer.

Constraint: whatever is emitted must stay assembleable with **64tass** (the output is still a real `.asm` source, not just a human-readable comment) — so the pretty formatting has to use directives/syntax 64tass accepts (e.g. its binary byte literals, `%........`, for the charset/sprite bit patterns), not just cosmetic comments bolted onto `.byte`.

Done when: at least charset and screen blocks can be marked in a `.flo` file and come out formatted, and the resulting `out/<binary>.asm` still assembles under 64tass and verifies.

## Decisions

- **Syntax: new type keywords** `charset`, `screen` and `sprite`, alongside `byte`/`word`/`dword`. (`screen` is free: since [0094](0094-explicit-text-encoding.md) the screen-code text type is `screencode`.) The size counts shapes, not bytes: `$2000 charset[64] font` is 64 characters of 8 bytes, `$3000 sprite[4] ship` is 4 sprites, `$0400 screen title` is one 1000-byte screen. They become reserved words.
- **A sprite is 63 bytes.** The byte after it, which fills the 64-byte block, is no part of the sprite, though the program may use it. Open: whether `sprite[4]` covers 4 × 64 bytes, printing each 64th byte as a plain `.byte` after its sprite (the common case, so one line covers the whole block, and a `.flo` line may still name or type that byte), or 4 × 63 bytes, with the 64th bytes declared separately or left as gaps. Sprites packed 63 bytes apart don't occur in VIC-II data, but a copy outside sprite memory may be packed.
- Output: charset and sprite rows as binary `.byte %00111100` lines (one row of 8 pixels, or 3 bytes for a sprite row), the screen as `.byte` rows of 40.

## PNG export

Binary rows show the pixels of one glyph or sprite, but not the whole set at a glance, and not in color. An `export` to a `.png` file could write a picture of the data next to the `.asm`:

```
$2000 charset[64] font export font.png
$3000 sprite[4] ship export ship.png
```

Unlike `.bin` and `.prg` exports, 64tass can't `.binary` a PNG back into the right bytes, so the data still prints in the `.asm` as usual (binary rows). The PNG is an extra file in `out/`, for looking at, not part of the round trip.

It is mostly for the user, to locate graphics: open the PNG, see whether the range really holds the font or the sprites, whether it starts at the right address, and where one set ends and the next begins. That matters more than a faithful rendering, so simple choices for colors and layout are fine.

Nim's standard library has no PNG writer: use a nimble package, or write one, which is small with uncompressed (stored) deflate blocks.

### To decide

- **Which types.** Only `charset` and `sprite`, or also `screen`, which needs a character set to render with (the program's own, from another `.flo` line, or the ROM one) and colors from color RAM.
- **Multicolor.** Hires or multicolor (2 bits per pixel, double-wide), set on the line, e.g. a `multicolor` word, or per sprite from the VIC registers in a snapshot.
- **Colors.** Fixed black and white or greys, a palette given in the `.flo` file, or the colors a VICE snapshot holds (background, sprite colors, multicolor registers).
- **Layout and scale.** Characters in a grid, e.g. 16 per row, and sprites side by side; each pixel scaled up (×2, ×4) with a gap between cells, so the PNG is readable without zooming.
- **Snippet expectations.** The other files in `out/` show as hex dumps, which says nothing for a PNG. The snippet could show its pixels as text instead, e.g. `#`/`.` rows like [0080](0080-show-memory-as-screen-text-and-glyphs.md).
- **Combined with `.bin`.** Whether one line can export both a `.bin` and a `.png`. `export` takes one file today.

Related: [0080](0080-show-memory-as-screen-text-and-glyphs.md) wants the same rendering while exploring, before a range is declared. Both could share the code that turns bytes into pixels.
