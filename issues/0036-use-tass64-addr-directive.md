---
title: Use 64tass's `.addr` directive instead of `.WORD` for pointer values
status: open
labels: enhancement
---

64tass (https://tass64.sourceforge.net/, "Storing numeric values") has a dedicated directive for address values: `.addr` - "create 16 bit address constants for addresses (in current program bank)". Right now `AssemblyFileFormat.print(DataArea, ...)` (`ResultWriter.java`) emits `DataType.POINTER` values as plain `.WORD` (`case POINTER: tabularPrint(".WORD", nameForAddress(...))`). `.addr` is the directive 64tass actually means for this - a 16-bit value that's an address - and using it instead of `.WORD` tells the assembler (and the reader) what the value *is*, not just its size.

This is the narrow, mechanical slice of a larger look at 64tass's numeric-storage directives - the rest (a signed-byte/word/long/dword type, `.rta` return-address tables, `.text`/`.null`/`.ptext` string detection) turned out to each need their own design discussion, so they're split into their own issues (0037, 0038, 0039) rather than bundled here.

Scope: same value formatting (`nameForAddress`, label-or-hex), just the directive name in the `POINTER` case of `print(DataArea, ...)`'s switch.

Done when: `POINTER` areas print as `.addr` instead of `.WORD`, with the `datatypes` fixture (the existing one already covering `.WORD`/`.DWORD`/`.CHAR`, per issue 0002) updated to show it.
