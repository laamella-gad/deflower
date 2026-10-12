package com.laamella.deflower;

import com.laamella.enflower.FloBaseListener;
import com.laamella.enflower.FloLexer;
import com.laamella.enflower.FloParser;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStream;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

import static com.laamella.Assert.assertState;
import static com.laamella.deflower.LineType.*;

/**
 * Parses a {@code .flo} file into its runs: one per 'deflower' line, each
 * with the annotations that follow it. Reads nothing but the {@code .flo}
 * file itself, and changes no memory.
 */
class FloReader {
    // The directory of the .flo files built into Deflower (issue 0078).
    private static final String BUILT_IN = "/deflower/";

    List<DeflowerRun> read(Path path, String sourceName) throws IOException {
        AnnotationCollector collector = new AnnotationCollector(null, false, path, new ArrayList<>(List.of(sourceName)));
        collect(CharStreams.fromPath(path), sourceName, collector);
        return collector.runs;
    }

    /**
     * Parses `input` and walks it with `collector`, failing on a syntax
     * error or a mistake the collector found.
     */
    private static void collect(CharStream input, String sourceName, AnnotationCollector collector) {
        List<String> parseErrors = new ArrayList<>();
        FloParser parser = createParser(parseErrors, input);
        FloParser.ProgContext tree = parser.prog();
        assertState(parseErrors.isEmpty(), "Failed to parse %s:%n%s", sourceName, String.join("\n", parseErrors));
        new ParseTreeWalker().walk(collector, tree);
        collector.closeRun();
        assertState(collector.errors.isEmpty(), "Failed to parse %s:%n%s", sourceName, String.join("\n", collector.errors));
    }

    private static FloParser createParser(List<String> parseErrors, CharStream input) {
        BaseErrorListener errorCollector = new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
                parseErrors.add(String.format("line %d:%d %s", line, charPositionInLine, msg));
            }
        };
        FloLexer lexer = new FloLexer(input);
        lexer.removeErrorListeners();
        lexer.addErrorListener(errorCollector);
        FloParser parser = new FloParser(new CommonTokenStream(lexer));
        parser.removeErrorListeners();
        parser.addErrorListener(errorCollector);
        return parser;
    }

    /**
     * Collects the parts of each line as the walk enters them, and turns
     * the line into an Annotation when it exits it.
     */
    private static class AnnotationCollector extends FloBaseListener {
        final List<DeflowerRun> runs = new ArrayList<>();
        DeflowerRun run;
        // True while reading an included file: its lines are weak.
        final boolean included;
        // The file being read, or null for a built-in one.
        final Path path;
        // The files being read, outermost first, to catch an include cycle.
        final List<String> includeChain;
        Integer address = null;
        Integer addressEnd = null;
        LineType type = UNKNOWN_LINE;
        boolean isVirtual = false;
        int amount = 1;
        String name = null;
        String export = null;
        // The line each export file name was first given on, across all
        // runs: they share one output directory.
        final Map<String, Integer> exportLines;
        final List<String> pendingComments = new ArrayList<>();
        // Mistakes the grammar can't catch, like a misplaced block.
        final List<String> errors = new ArrayList<>();
        // The open { } block (issue 0035): inner addresses are offsets
        // from blockBase. Null when no block is open; blocks don't nest.
        Integer blockBase = null;
        boolean blockVirtual = false;
        int blockLine = 0;

        AnnotationCollector(DeflowerRun run, boolean included, Path path, List<String> includeChain) {
            this.run = run;
            this.included = included;
            this.path = path;
            this.includeChain = includeChain;
            this.exportLines = new HashMap<>();
        }

        void startNewLine() {
            address = null;
            addressEnd = null;
            type = UNKNOWN_LINE;
            isVirtual = false;
            amount = 1;
            name = null;
            export = null;
        }

        @Override
        public void enterSetFileName(FloParser.SetFileNameContext ctx) {
            if (included) {
                errors.add(String.format("line %d: an included file can't start a run", ctx.getStart().getLine()));
                return;
            }
            closeRun();
            run = new DeflowerRun(ctx.ID().getText());
            pendingComments.clear();
            runs.add(run);
        }

        @Override
        public void enterLine(FloParser.LineContext ctx) {
            startNewLine();
        }

        /**
         * Reads the included file's lines into the current run, marked as
         * included (issue 0078). The file is looked up next to the file
         * being read, then among the built-in ones.
         */
        @Override
        public void enterInclude(FloParser.IncludeContext ctx) {
            int line = ctx.getStart().getLine();
            assertState(run != null, "Start the file with a 'deflower <file>' line.", line, ctx.getText());
            if (blockBase != null) {
                errors.add(String.format("line %d: can't include inside a block", line));
                return;
            }
            // A comment above an include line is about the include.
            pendingComments.clear();
            String name = ctx.ID().getText();
            if (includeChain.contains(name)) {
                errors.add(String.format("line %d: include cycle: %s -> %s", line, String.join(" -> ", includeChain), name));
                return;
            }
            List<String> chain = new ArrayList<>(includeChain);
            chain.add(name);
            Path local = path != null ? path.resolveSibling(name) : null;
            try {
                if (local != null && Files.exists(local)) {
                    collect(CharStreams.fromPath(local), name, new AnnotationCollector(run, true, local, chain));
                    return;
                }
                InputStream builtIn = FloReader.class.getResourceAsStream(BUILT_IN + name);
                if (builtIn == null) {
                    errors.add(String.format("line %d: no file %s to include", line, name));
                    return;
                }
                try (builtIn) {
                    collect(CharStreams.fromStream(builtIn), name, new AnnotationCollector(run, true, null, chain));
                }
            } catch (IOException e) {
                errors.add(String.format("line %d: can't read %s: %s", line, name, e.getMessage()));
            }
        }

        @Override
        public void enterComment(FloParser.CommentContext ctx) {
            pendingComments.add(commentText(ctx.getText()));
        }

        @Override
        public void enterDatatype(FloParser.DatatypeContext ctx) {
            if (ctx.CHAR() != null) {
                type = CHAR_LINE;
            } else if (ctx.BYTE() != null) {
                type = BYTE_LINE;
            } else if (ctx.WORD() != null) {
                type = WORD_LINE;
            } else if (ctx.LONG() != null) {
                type = LONG_LINE;
            } else if (ctx.DWORD() != null) {
                type = DWORD_LINE;
            } else if (ctx.ADDR() != null) {
                type = ADDR_LINE;
            } else if (ctx.SBYTE() != null) {
                type = SBYTE_LINE;
            } else if (ctx.SWORD() != null) {
                type = SWORD_LINE;
            } else if (ctx.SLONG() != null) {
                type = SLONG_LINE;
            } else if (ctx.SDWORD() != null) {
                type = SDWORD_LINE;
            } else if (ctx.CODE() != null) {
                type = CODE_LINE;
            }
            if (ctx.arraySize() != null) {
                amount = evaluate(ctx.arraySize());
            }
        }

        @Override
        public void enterAddress(FloParser.AddressContext ctx) {
            address = parseNumber(ctx.getText()).orElseThrow();
        }

        @Override
        public void enterMemoryRange(FloParser.MemoryRangeContext ctx) {
            address = parseNumber(ctx.number(0).getText()).orElseThrow();
            addressEnd = parseNumber(ctx.number(1).getText()).orElseThrow();
        }

        @Override
        public void enterSetVirtual(FloParser.SetVirtualContext ctx) {
            isVirtual = true;
        }

        @Override
        public void enterSetLabel(FloParser.SetLabelContext ctx) {
            name = ctx.ID().getText();
        }

        @Override
        public void enterExport(FloParser.ExportContext ctx) {
            export = ctx.ID().getText();
        }

        @Override
        public void exitLine(FloParser.LineContext ctx) {
            assertState(run != null, "Start the file with a 'deflower <file>' line.", ctx.getStart().getLine(), ctx.getText());
            int line = ctx.getStart().getLine();
            List<String> comment = List.copyOf(pendingComments);
            pendingComments.clear();
            if (blockBase != null) {
                address += blockBase;
                if (addressEnd != null) {
                    addressEnd += blockBase;
                }
                isVirtual |= blockVirtual;
                if (address > 0xFFFF || (addressEnd != null && addressEnd > 0x10000)) {
                    errors.add(String.format("line %d: the block's base plus this offset runs past $ffff", line));
                    return;
                }
            }
            if (ctx.OPEN_BLOCK() != null) {
                openBlock(ctx, line, comment);
                return;
            }
            if (export != null && !checkExport(line)) {
                return;
            }
            run.annotations.add(new Annotation(address, addressEnd, type, isVirtual, amount, name, comment, included, export));
        }

        /**
         * Only a data line can be exported (issue 0022), to a file whose
         * name ends in .bin or .prg and that no other line exports to.
         */
        private boolean checkExport(int line) {
            String problem = null;
            if (included) {
                problem = "an included file can't export";
            } else if (!(export.endsWith(".bin") || export.endsWith(".prg")) || export.length() == ".bin".length()) {
                problem = "export " + export + " needs a file name ending in .bin or .prg";
            } else if (type == CODE_LINE) {
                problem = "code can't be exported";
            } else if (isVirtual) {
                problem = "a virtual area can't be exported";
            } else if (type == UNKNOWN_LINE && addressEnd == null) {
                problem = "export needs a type or a range";
            } else if (exportLines.containsKey(export)) {
                problem = String.format("%s is already exported on line %d", export, exportLines.get(export));
            }
            if (problem != null) {
                errors.add(String.format("line %d: %s", line, problem));
                return false;
            }
            exportLines.put(export, line);
            return true;
        }

        /**
         * A '{' line only gives the base address and, optionally,
         * 'virtual', which then applies to every line inside. It covers
         * no memory itself; a comment above it goes onto the base address.
         */
        private void openBlock(FloParser.LineContext ctx, int line, List<String> comment) {
            if (blockBase != null) {
                errors.add(String.format("line %d: blocks can't be nested (the open one starts at line %d)", line, blockLine));
                return;
            }
            if (addressEnd != null || ctx.datatype() != null || name != null || ctx.export() != null) {
                errors.add(String.format("line %d: a block's opening line takes only an address and 'virtual'", line));
                return;
            }
            blockBase = address;
            blockVirtual = isVirtual;
            blockLine = line;
            if (!comment.isEmpty()) {
                run.annotations.add(new Annotation(address, null, UNKNOWN_LINE, false, 1, null, comment, included, null));
            }
        }

        @Override
        public void enterEndBlock(FloParser.EndBlockContext ctx) {
            if (blockBase == null) {
                errors.add(String.format("line %d: '}' without an open block", ctx.getStart().getLine()));
            }
            blockBase = null;
        }

        /**
         * A block ends inside the run it opened in: a new 'deflower' line
         * or the end of the file with a block still open is an error.
         */
        void closeRun() {
            if (blockBase != null) {
                errors.add(String.format("line %d: block is not closed with '}'", blockLine));
            }
            blockBase = null;
        }
    }

    private static int evaluate(FloParser.ArraySizeContext size) {
        if (size instanceof FloParser.ArraySizeMulContext) {
            FloParser.ArraySizeMulContext mul = (FloParser.ArraySizeMulContext) size;
            return evaluate(mul.arraySize(0)) * evaluate(mul.arraySize(1));
        }
        if (size instanceof FloParser.ArraySizePlusContext) {
            FloParser.ArraySizePlusContext plus = (FloParser.ArraySizePlusContext) size;
            return evaluate(plus.arraySize(0)) + evaluate(plus.arraySize(1));
        }
        return parseNumber(((FloParser.ArraySizeNumberContext) size).number().getText()).orElseThrow();
    }

    /**
     * Strips the leading ';' or '#' marker (and one following space, if
     * any) off a COMMENT token's raw text.
     */
    private static String commentText(String raw) {
        String body = raw.substring(1);
        return body.startsWith(" ") ? body.substring(1) : body;
    }

    private static Optional<Integer> parseNumber(String part) {
        try {
            if (part.startsWith("$")) {
                return Optional.of(Integer.parseInt(part.substring(1), 16));
            } else {
                return Optional.of(Integer.parseInt(part));
            }
        } catch (NumberFormatException e) {
            return Optional.empty();
        }
    }
}
