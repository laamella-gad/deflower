---
title: Run deflower as an MCP server that answers questions about a disassembly
status: open
priority: low
labels: enhancement
---

An agent (Claude Code) disassembling with Deflower works in a loop: edit the `.flo` file, run, grep the output, repeat. Every question, such as "what is at `$2686`", "who writes `snake_tries`" or "is `$1042` a screen", means a full run and a search through a generated `.asm` of thousands of lines.

Want: a mode, e.g. `--mcp <file.flo>`, in which Deflower runs as an MCP server. It keeps the image and the analysis loaded, re-runs when the `.flo` file changes, and offers tools such as:
- **what_is_at(address)**: the area, its type, label and value;
- **references(label or address)**: the cross-references of [0076](0076-cross-reference-comments.md);
- **verify()**: the differences and gaps of [0075](0075-verify-flag.md);
- **inspect()**: the facts `--init` writes ([0072](0072-inspect-input-file.md));
- **dump/find/strings(...)**: what `--dump`, `--find` and `--strings` print;
- **show(range, shape)**: screen text, glyphs or sprites, as in [0080](0080-show-memory-as-screen-text-and-glyphs.md);
- **preview(range, type)**: the output a declaration would give, without editing the `.flo` file, as in [0070](0070-preview-gap-as-code.md).

The files stay the main interface: the `.flo` file is still edited as a file, and `out/*.asm` is still written, so the user and the tests see the same result. The server is only a faster way to ask questions.

**Blocked by** 0080 (0072, 0075 and 0076 are done): the server should be a thin layer over those features, not a second implementation of them. It also comes after [0059](0059-convert-to-nim.md), the port to Nim, like the other command line modes.

## To decide

- **MCP library.** Nim has no mature MCP SDK. The stdio transport with JSON-RPC is small enough to write by hand.
- **Relation to watch mode.** [0057](0057-watch-mode.md) already re-runs on changes; the server could be that mode with tools added.
- **Writes.** Whether tools may change the `.flo` file (e.g. add a label), or only read.

Done when: Claude Code, configured with the server, can answer the questions above for `squirm` without running Deflower through the shell.
