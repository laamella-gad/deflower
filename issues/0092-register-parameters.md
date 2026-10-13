---
title: Document a routine's register and zero-page parameters in its parameter list
status: open
priority: low
labels: enhancement
---

[0068](0068-inline-data-after-jsr.md) gives a `code` line a parameter list for the data that follows each `jsr`:

```
$c000 code print (char[10] text, byte colour)
```

Most routines take their parameters somewhere else: in `a`, `x` and `y`, or in zero-page or other fixed addresses that the caller fills before the `jsr`. In the real programs this is the more common kind, e.g. a print routine that takes a character in `a`, or a copy routine that takes its source pointer in `$fb`/`$fc`. Today the only place to say so is a comment above the line.

Want: the same parameter list can name register and memory parameters, e.g.

```
$0ffb code print_char (a: char c)
$2c93 code print_nibble (a: byte value, x: byte column)
$1800 code copy (addr $fb: source, byte $fd: count)
```

These parameters don't change the tracing, since nothing follows the `jsr`. They are documentation: printed with the routine's label, and maybe as a comment at each call site.

## To decide

- **Syntax.** `a: char c` or `char c in a`, and how a memory parameter names its address. Whether register, memory and inline parameters can be mixed in one list, and in what order.
- **Output.** A comment block above the routine (`; a: c (char)`), a comment at each `jsr`, or both. A comment on the instruction that loads the parameter before the call (`lda #$41 ; c`) is more work: it needs the analyser to find that instruction.
- **Memory parameters as labels.** Should a memory parameter also label its address (`source = $fb`)? It might clash with a label on the same address from elsewhere, e.g. a zero-page variable in `c64_zeropage.flo`.
- **Return values.** The same idea, for what a routine returns (carry set on error, a result in `a`).

Done when: a short snippet declares a routine with a register parameter and a memory parameter, and the output shows them in the chosen form.
