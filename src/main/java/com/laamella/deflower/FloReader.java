package com.laamella.deflower;

import com.laamella.enflower.FloBaseListener;
import com.laamella.enflower.FloLexer;
import com.laamella.enflower.FloParser;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.IOException;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

import static com.laamella.Assert.assertState;
import static com.laamella.deflower.LineType.*;

/**
 * Parses a {@code .flo} file into its runs: one per 'deflower' line, each
 * with the annotations that follow it. Reads nothing but the {@code .flo}
 * file itself, and changes no memory.
 */
class FloReader {
    List<DeflowerRun> read(Path path, String sourceName) throws IOException {
        List<String> parseErrors = new ArrayList<>();
        FloParser parser = createParser(parseErrors, path);
        FloParser.ProgContext tree = parser.prog();
        assertState(parseErrors.isEmpty(), "Failed to parse %s:%n%s", sourceName, String.join("\n", parseErrors));
        AnnotationCollector collector = new AnnotationCollector();
        new ParseTreeWalker().walk(collector, tree);
        collector.closeRun();
        assertState(collector.errors.isEmpty(), "Failed to parse %s:%n%s", sourceName, String.join("\n", collector.errors));
        return collector.runs;
    }

    private static FloParser createParser(List<String> parseErrors, Path path) throws IOException {
        BaseErrorListener errorCollector = new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
                parseErrors.add(String.format("line %d:%d %s", line, charPositionInLine, msg));
            }
        };
        FloLexer lexer = new FloLexer(CharStreams.fromPath(path));
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
        DeflowerRun run = null;
        Integer address = null;
        Integer addressEnd = null;
        LineType type = UNKNOWN_LINE;
        boolean isVirtual = false;
        int amount = 1;
        String name = null;
        final List<String> pendingComments = new ArrayList<>();
        // Mistakes the grammar can't catch, like a misplaced block.
        final List<String> errors = new ArrayList<>();
        // The open { } block (issue 0035): inner addresses are offsets
        // from blockBase. Null when no block is open; blocks don't nest.
        Integer blockBase = null;
        boolean blockVirtual = false;
        int blockLine = 0;

        void startNewLine() {
            address = null;
            addressEnd = null;
            type = UNKNOWN_LINE;
            isVirtual = false;
            amount = 1;
            name = null;
        }

        @Override
        public void enterSetFileName(FloParser.SetFileNameContext ctx) {
            closeRun();
            run = new DeflowerRun(ctx.ID().getText());
            pendingComments.clear();
            runs.add(run);
        }

        @Override
        public void enterLine(FloParser.LineContext ctx) {
            startNewLine();
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
            } else if (ctx.DWORD() != null) {
                type = DWORD_LINE;
            } else if (ctx.ADDR() != null) {
                type = ADDR_LINE;
            } else if (ctx.SBYTE() != null) {
                type = SBYTE_LINE;
            } else if (ctx.SWORD() != null) {
                type = SWORD_LINE;
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
        public void exitLine(FloParser.LineContext ctx) {
            assertState(run != null, "Start the file with a 'deflower <file>' line.", ctx.getStart().getLine(), ctx.getText());
            int line = ctx.getStart().getLine();
            String comment = pendingComments.isEmpty() ? null : String.join("\n", pendingComments);
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
            run.annotations.add(new Annotation(address, addressEnd, type, isVirtual, amount, name, comment));
        }

        /**
         * A '{' line only gives the base address and, optionally,
         * 'virtual', which then applies to every line inside. It covers
         * no memory itself; a comment above it goes onto the base address.
         */
        private void openBlock(FloParser.LineContext ctx, int line, String comment) {
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
            if (comment != null) {
                run.annotations.add(new Annotation(address, null, UNKNOWN_LINE, false, 1, null, comment));
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
