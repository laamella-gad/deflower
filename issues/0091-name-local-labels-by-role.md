---
title: Name local auto labels by their role in the routine, not by their address
status: open
priority: medium
labels: enhancement
---

Since [0084](0084-local-labels.md), an auto label on a branch or `jmp` target that no `jsr` calls is local: cross-references skip it, so a referrer is named by its routine. But it still prints as a global label named after its address, like `l3395` or `l241E`. In the real programs most labels are of this kind. The hex names say nothing about what the place is, and they take up the global namespace.

## How assemblers do local labels

- **Scoped locals**, valid up to the next normal label, so the same name can be used again in every routine:
  - 64tass (Deflower's output syntax) has `_name`, local to the label before it. `.proc`/`.pend` and `.block`/`.bend` give explicit scopes.
  - ca65 has `@name` ("cheap locals").
  - ACME has `.name` inside a `!zone`, and newer versions also have `@name`.
  - DASM has `.name` inside a `SUBROUTINE`.
  - Merlin has `:name`.
- **Anonymous labels**, referenced by direction and count:
  - 64tass and ACME use a line with just `-` or `+`, referenced as `bne -` or `beq ++`.
  - ca65 uses `:`, referenced as `:-` and `:+`.
  - Kick Assembler uses reusable `!name:`, referenced as `!name-`.

Want: local auto labels as 64tass `_` locals named by their role:
- `_loop` for a backward target, `_skip` for a forward one;
- numbered when a routine has several (`_loop`, `_loop2`), counting again in every routine.

For example:

```
wait_frame:
		lda $d012
_loop:
		cmp $d012
		beq _loop
		rts
```

The names don't depend on the address, but they stay the same from run to run. A new label changes names inside that routine only, which keeps the diffs in the watcher loop small.

A command line switch, e.g. `--no-local-labels`, turns this off: every auto label is then a global one named after its address (`l3395`), as today. Some users want the address in every name, or want output for an assembler without 64tass's `_` scoping.

## To decide

- **Scope safety.** A `_` local can only be referenced from its own scope. By 0084's rule, a `jmp` target that no `jsr` calls is local, but the `jmp` can come from another routine. Such a target must stay a global auto label, so the rule becomes "every reference comes from the same routine". The same goes for operands that read or write the address (self-modifying code), and for `.addr` values.
- **mpu6502.** Its `SourceParser` accepts `_name` as an ordinary global identifier and doesn't scope it, so the second `_loop` in a file would be a duplicate. It has no anonymous `-`/`+` labels either. Verify ([0075](0075-verify-flag.md)) and the snippet round trip both assemble with it, so it needs 64tass's `_` scoping first. That is a change in the mpu6502 repository.
- **Role names.** Is `_loop`/`_skip` enough, or are more roles worth telling apart? For example `_next` for a forward target that several branches share, or `_done` for one just before an `rts`.
- **Anonymous labels.** Is `-`/`+` worth having as well, for hops of a few lines with nothing else in between? It reads compactly there, but gets hard to follow once several are near each other.
- **Renaming in the .flo file.** A user who renames `_loop2` to `_wait_raster` needs a way to write a local name. It could be a `.flo` label starting with `_`, scoped to the routine its address falls in, or a name tied to the routine, like `wait_frame._wait_raster`. A `.flo` label without `_` on a local target makes it global, as today.
- **The switch.** Its name. Whether it also turns off 0084's local status (cross-references skipping the label) or only the naming. Whether `.flo` labels starting with `_` stay locals with the switch on. Snippets have no way to pass a flag yet (they run `new Deflower(true)`), so they need one, e.g. a snippet option or a `.flo` line.
- **Defines and offsets.** A local label inside an instruction or array, printed as a `label = $addr` define after it, or used in `label + offset`, must still resolve inside its scope.

Related: [0090](0090-report-auto-labels.md) counts and lists the auto labels left. Its "which labels count" question depends on whether local labels still count as unnamed once they have role names.

Done when: a short snippet with two routines, each with a backward and a forward branch, prints `_loop`/`_skip` locals in both; a `jmp` from one routine into the other keeps a global label; the snippet passes the round trip; and the same input with the switch prints address-named global labels.
