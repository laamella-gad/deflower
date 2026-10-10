---
title: Address range end is off by one
status: invalid
priority: high
labels: bug
---

Originally filed as: `SubjectConfigurer.exitLine` computes `amount = (addressEnd - address) / size`, which looked wrong assuming `$0800-$080f` means 16 bytes inclusive.

**Closed as invalid.** The range end is deliberately exclusive, not inclusive, and that's required by the real fixtures, not just a style choice. `squirm.flo` has `$35e7-$35e8 data` immediately followed by `$35e8 code colorize_maze`. If the range included `$35e8`, that byte would be claimed as both data and code. Applying the originally proposed `+1` fix made `colorize_maze` stop being traced as code entirely (it hit `Jumping into non-code area`), confirmed by diffing the generated output. The other ranges in the same file (`$2572-$2680`, `$2682-$26ac`, `$26df-$2800`) also line up edge-to-edge only under the exclusive reading. This also matches `enterMul`'s `addressEnd`, which is exclusive by construction.

So the current code is correct, and the fixture data depends on it staying that way. No code change.
