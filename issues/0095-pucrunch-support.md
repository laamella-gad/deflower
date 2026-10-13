---
title: Think about pucrunch support for the reassembled program
status: open
priority: low
labels: research
---

[pucrunch](https://github.com/mist64/pucrunch) is a hybrid LZ77/RLE compressor for Commodore 8-bit programs. It turns a program into one that decompresses itself when run (`-c64`, `-c20`, `-c16`), or into data with a 46-byte header for a separate decompressor (`-c0`, with `sa_uncrunch.asm`). Decompression needs no extra memory.

It does two jobs at once: it is a linker as well as a compressor. It puts the parts of a program, each at its own address, into one runnable file, and sets up how the program starts: the start address and the memory configuration (`$01`). For Deflower the linking part may matter more than the compression: the output of a snapshot is spread over memory, and there is no other step that turns it back into one program.

The compressor is portable C under the LGPL. The 6502 decompressors are under the wxWindows Library Licence, which allows shipping them with compressed data.

Many of the programs Deflower works on were crunched like this to begin with. `3dgolf_snap` still has its decruncher at `$080d`, and `squirm` and `zwark` come from snapshots, not from runnable files. Once a disassembly verifies, the natural next step is a runnable, compact `.prg` built from the `.asm`. Today that is manual: assemble the `.asm` with 64tass, work out the start address and memory configuration, and run pucrunch.

Options, from loosest to tightest:
1. **Produce input for pucrunch.** Write what pucrunch needs next to the `.asm`: the assembled `.prg` (Verifier already assembles it with mpu6502), and the command line with the start address and `$01` value, e.g. a `out/<binary>.crunch.sh`.
2. **Call it.** With a switch like `--crunch`, run a `pucrunch` executable found on the `PATH` after a clean verify, and write `out/<binary>.crunched.prg`.
3. **Integrate it.** Port the compressor to Java, or call it as a library, and ship the 6502 decompressor, so no external tool is needed.

## To decide

- **Whether it belongs in Deflower at all.** It is a build step, not disassembly. A note in the docs or a generated script may be enough.
- **What to link.** A `.prg` input has one load address and one block. A snapshot covers all memory: which of it belongs to the program (the loaded, non-virtual areas, as the map lists them)? The parts are separate blocks, so they need linking, by pucrunch itself or with the repository's `cbmcombine.c`, instead of crunching the gaps between them as filler. Deflower could hand over one file per block, e.g. an `.asm` split at each `*=`, or one `.prg` per block from the assembled segments.
- **Start state.** A crunched program starts with a jump to an address. A snapshot was taken mid-run (`snapshot_pc` in 3dgolf), with a given `$01`, interrupt vectors, VIC and SID setup, and a stack, which the program may depend on. Where would the `.flo` file say the start address and `$01` value (a `start` or `run` line?), and is restoring the rest out of scope?
- **Options.** Which of pucrunch's options to expose, if any (target machine, `-fshort`, `-fdelta`, the start address and memory configuration; check the exact flags against the version used).
- **Licences.** The LGPL for a port or a linked library, and the wxWindows licence for a shipped decompressor, against Deflower's own licence (which isn't stated in the repository yet).
- **Testing.** A snippet can't easily check crunched output, apart from its size and that decompressing it (in a 6502 emulator, like mpu6502's) gives back the image.

Related, the other way round: recognizing a pucrunched input and decrunching it before the disassembly, instead of tracing the decruncher (`3dgolf_snap`'s `decrunch` at `$080d`).

Done when: decided which option (if any) to take, and a follow-up issue filed for it.
