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
        LineType type = UNKNOWN_BLOCK;
        boolean isVirtual = false;
        int amount = 1;
        String name = null;
        final List<String> pendingComments = new ArrayList<>();

        void startNewLine() {
            address = null;
            addressEnd = null;
            type = UNKNOWN_BLOCK;
            isVirtual = false;
            amount = 1;
            name = null;
        }

        @Override
        public void enterSetFileName(FloParser.SetFileNameContext ctx) {
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
                type = CHAR_BLOCK;
            } else if (ctx.BYTE() != null) {
                type = BYTE_BLOCK;
            } else if (ctx.WORD() != null) {
                type = WORD_BLOCK;
            } else if (ctx.DWORD() != null) {
                type = DWORD_BLOCK;
            } else if (ctx.CODE() != null) {
                type = CODE_ENTRY;
            }
            if (ctx.arraySize != null) {
                amount = parseNumber(ctx.arraySize.getText()).orElse(amount);
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
        public void enterMul(FloParser.MulContext ctx) {
            int left = parseNumber(ctx.number(0).getText()).orElseThrow();
            int right = parseNumber(ctx.number(1).getText()).orElseThrow();
            amount = left * right;
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
            assertState(address != null, "Require an address: %s", ctx);
            String comment = pendingComments.isEmpty() ? null : String.join("\n", pendingComments);
            pendingComments.clear();
            run.annotations.add(new Annotation(address, addressEnd, type, isVirtual, amount, name, comment));
        }
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
