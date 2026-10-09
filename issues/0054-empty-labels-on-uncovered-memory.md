---
title: Labels on memory no area covers come out as empty origin blocks
status: done
labels: enhancement
---

A label on an address that no area covers is printed as its own `*=` origin with nothing after it. Since issue 0015, every absolute data reference outside the program (I/O registers, vectors, unused RAM, bytes past the end of the image) gets a `dXXXX` label, so the output is full of blocks like this one from `multi/expected-a.asm`:

```
*=$C076

dC076:
*=$C080

dC080:
*=$C40E
```

It assembles and the labels resolve, but it's noise. The origin block exists only to place one label, and there isn't even a blank line before the next `*=`.

Counts in the current expectations: zwark 30, squirm 12, multi/a 2, tcmine 2, virtualarea 1 (`dD400`). `partialoverlap` has the same shape for a user label: `entry:` at `$C000` is printed with no code, because its instruction would run into `guard`.

Options:

- **Address defines.** Print such a label as `dC076 = $C076` instead of an origin block, for example all together in a block at the top of the file, sorted by address. That's the same mechanism [0028](0028-mid-block-labels-as-address-defines.md) proposes for labels inside an area.
- **Stop labelling uncovered memory.** Leave those operands numeric (`LDA $C076, Y`), as before 0015. Loses the label, and contradicts the choice made in 0015.
- **Keep origin blocks, fix the layout.** Add the missing blank line, or group consecutive empty labels under one origin. Least change, but the noise stays.

Done when: a label on memory no area covers no longer produces an origin block with nothing in it, the label still resolves in operands, and the affected expectations still reassemble to the same bytes.

## Closing note

Chose **stop labelling uncovered memory**, reversing that part of 0015. `FlowAnalyser.labelDataReference` now skips a target no area covers, so references to I/O registers, vectors, unused RAM and bytes outside the image stay numeric (`LDA $C076, Y`, `STA $D400`) and no origin block is printed for them. Data references into a covered area are still labelled as in 0015.

`ResultWriter.nameForAddress` keeps the 0015 fallback that prints a label on uncovered memory. It no longer gets auto data labels, but it still names user labels and jump targets whose instruction couldn't be decoded.

Not covered: `partialoverlap`'s user label `entry:` at `$C000`, whose instruction would run into `guard`, still prints as an origin block with nothing in it. That's a user label on code that failed to decode, not an auto data label. Address defines ([0028](0028-mid-block-labels-as-address-defines.md)) would be the fix for it.

Expectations regenerated: squirm, zwark, tcmine, multi/a, virtualarea. Each diff only removes `dXXXX:` origin blocks and turns `dXXXX` operands back into `$XXXX`: every changed instruction line pairs up exactly once the label is replaced by its number. Reassembled with 64tass (zwark with `-i`), each one gives the same bytes as the previous expectation.

43/43 tests green.
