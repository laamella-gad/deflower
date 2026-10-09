---
title: Report an error when the same label is defined at two addresses
status: open
labels: bug, enhancement
---

`SubjectConfigurer.exitLine` sets `subject.memory[address].label = name` without checking whether `name` is already used at another address. A `.flo` file can therefore give one label to two different locations, and the generated asm then defines that label twice. The assembler rejects that, or worse, code references silently resolve to the wrong address.

Real case: `squirm.flo` declared `bonus_guy_char` at both `$2684` and `$268e`. Code references both addresses, and the output printed `bonus_guy_char` for both, so you couldn't tell them apart. It went unnoticed until issue 0032's cleanup. It's fixed there by renaming one of them, but nothing would catch the next one.

Expected: defining a label that already belongs to a different address adds an entry to `Subject.errors`, naming both addresses and the label (for example `Duplicate label bonus_guy_char at $268E, already defined at $2684`). Output is then skipped, the same way area conflicts are (issue 0018). Re-declaring the same label at the *same* address stays allowed, since it does no harm.

Things to decide while doing it:
- Whether auto-generated labels (`_XXXX_CODE`/`_XXXX_DATA`/`_XXXX_POINTER` from `FlowAnalyser.ensureLabelled`) take part in the check. They contain their own address, so they can't collide with each other, but a user could in theory write one by hand.
- A label at one address being *replaced* by a different label at that same address (the last ID on a line wins; later lines overwrite earlier ones) is a separate question. It isn't a duplicate definition and is out of scope.

Done when: a new fixture that defines one label at two addresses fails with that error and writes no output, a test asserts the error message, and all existing fixtures still pass.
