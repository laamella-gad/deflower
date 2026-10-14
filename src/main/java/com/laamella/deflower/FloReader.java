package com.laamella.deflower;

import com.laamella.enflower.FloBaseListener;
import com.laamella.enflower.FloLexer;
import com.laamella.enflower.FloParser;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.Parser;
import org.antlr.v4.runtime.Token;
import org.antlr.v4.runtime.TokenStream;
import org.antlr.v4.runtime.Vocabulary;
import org.antlr.v4.runtime.misc.IntervalSet;
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
import java.util.TreeMap;

import static com.laamella.Assert.assertState;
import static java.nio.charset.StandardCharsets.UTF_8;
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
        collect(Files.readString(path), sourceName, collector);
        return collector.runs;
    }

    /**
     * Parses `text` and walks it with `collector`, failing on a syntax
     * error or a mistake the collector found.
     */
    private static void collect(String text, String sourceName, AnnotationCollector collector) {
        // The grammar ends every line with a newline; the last one may
        // lack it (issue 0088).
        String lines = text.isEmpty() || text.endsWith("\n") || text.endsWith("\r") ? text : text + "\n";
        // The first syntax error on each line, by column: after one, ANTLR's
        // recovery only reports what follows from it.
        Map<Integer, Map.Entry<Integer, String>> firstErrors = new TreeMap<>();
        FloParser parser = createParser(firstErrors, CharStreams.fromString(lines, sourceName));
        FloParser.ProgContext tree = parser.prog();
        List<String> parseErrors = new ArrayList<>();
        firstErrors.forEach((line, error) -> parseErrors.add(String.format("line %d: %s", line, error.getValue())));
        assertState(parseErrors.isEmpty(), "Failed to parse %s:%n%s", sourceName, String.join("\n", parseErrors));
        new ParseTreeWalker().walk(collector, tree);
        collector.closeRun();
        assertState(collector.errors.isEmpty(), "Failed to parse %s:%n%s", sourceName, String.join("\n", collector.errors));
    }

    private static FloParser createParser(Map<Integer, Map.Entry<Integer, String>> firstErrors, CharStream input) {
        BaseErrorListener errorCollector = new BaseErrorListener() {
            @Override
            public void syntaxError(Recognizer<?, ?> recognizer, Object offendingSymbol, int line, int charPositionInLine, String msg, RecognitionException e) {
                String message = recognizer instanceof Parser
                        ? describe((Parser) recognizer, (Token) offendingSymbol)
                        : "unexpected " + msg.substring(msg.indexOf("at: ") + 4);
                Map.Entry<Integer, String> first = firstErrors.get(line);
                if (first == null || charPositionInLine < first.getKey()) {
                    firstErrors.put(line, Map.entry(charPositionInLine, message));
                }
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

    private static final int DEFLOWER = literal("deflower");
    private static final int INCLUDE = literal("include");
    private static final int EXPORT = literal("export");
    private static final int OPEN_PARAMETERS = literal("(");
    private static final int NORETURN = literal("noreturn");
    private static final int OPEN_SIZE = literal("[");

    /** The token type of a word or sign in the grammar. */
    private static int literal(String text) {
        for (int type = 1; type <= FloParser.VOCABULARY.getMaxTokenType(); type++) {
            if (("'" + text + "'").equals(FloParser.VOCABULARY.getLiteralName(type))) {
                return type;
            }
        }
        throw new IllegalArgumentException(text);
    }

    // What the parser can take next, in the order of a line's parts, with
    // what each is called in an error message.
    private static final List<Integer> EXPECTED_ORDER = List.of(
            FloParser.INT, DEFLOWER, INCLUDE, literal("-"), literal("virtual"), literal("banked"), literal("selfmod"),
            literal("until"), literal("lengthbyte"), FloParser.SCREENCODE, OPEN_SIZE, literal("*"), literal("+"),
            literal("]"), FloParser.ID, OPEN_PARAMETERS, literal(","), literal(")"), NORETURN,
            EXPORT, FloParser.OPEN_BLOCK, FloParser.CLOSE_BLOCK, FloParser.NEWLINE);

    /**
     * Says what the parser expected where `found` is, in the words of the
     * format description rather than the grammar's token names: "expected
     * a type, a label or the end of the line, found 'x'".
     */
    private static String describe(Parser parser, Token found) {
        IntervalSet expected = parser.getExpectedTokens();
        List<Token> line = tokensOfLineBefore(parser, found);
        boolean codeLine = line.stream().anyMatch(t -> t.getType() == FloParser.CODE);
        long openParentheses = line.stream().filter(t -> t.getText().equals("(")).count()
                - line.stream().filter(t -> t.getText().equals(")")).count();
        int previous = line.isEmpty() ? -1 : line.get(line.size() - 1).getType();
        Vocabulary vocabulary = parser.getVocabulary();
        List<String> words = new ArrayList<>();
        boolean annotationLine = !line.isEmpty() && (line.get(0).getType() == FloParser.INT || line.get(0).getType() == FloParser.HEX);
        if (annotationLine && expected.size() == 1 && expected.contains(FloParser.NEWLINE)) {
            // ANTLR passes over the optional parts that don't fit and only
            // expects the end of the line; what may still come follows from
            // the last part on the line.
            words.addAll(remainingLineParts(line, codeLine));
        }
        for (int type : words.isEmpty() ? EXPECTED_ORDER : List.<Integer>of()) {
            boolean isType = type == FloParser.SCREENCODE;
            if (!(isType ? expected.contains(FloParser.BYTE) : expected.contains(type) || type == FloParser.INT && expected.contains(FloParser.HEX))) {
                continue;
            }
            String literal = vocabulary.getLiteralName(type);
            if (isType) {
                words.add("a type");
            } else if (type == FloParser.INT) {
                words.add(expected.contains(DEFLOWER) ? "an address" : "a number");
            } else if (type == FloParser.ID) {
                words.add(previous == DEFLOWER || previous == INCLUDE || previous == EXPORT
                        ? "a file name" : openParentheses > 0 ? "a name" : "a label");
            } else if (type == FloParser.NEWLINE) {
                words.add("the end of the line");
            } else if (type == OPEN_SIZE) {
                words.add("a size");
            } else if (type == OPEN_PARAMETERS || type == NORETURN) {
                // Parameters and noreturn only make sense on a code line.
                if (codeLine) {
                    words.add(type == OPEN_PARAMETERS ? "parameters" : "noreturn");
                }
            } else if (literal.matches("'[a-z]+'")) {
                words.add(literal.substring(1, literal.length() - 1));
            } else {
                words.add(literal);
            }
        }
        String foundText = found.getType() == Token.EOF ? "the end of the file"
                : found.getType() == FloParser.NEWLINE ? "the end of the line"
                : "'" + found.getText() + "'";
        if (words.isEmpty()) {
            return "unexpected " + foundText;
        }
        String list = words.size() == 1 ? words.get(0)
                : String.join(", ", words.subList(0, words.size() - 1)) + " or " + words.get(words.size() - 1);
        return String.format("expected %s, found %s", list, foundText);
    }

    // The optional parts of an annotation line after its address, in order.
    private static final List<String> LINE_PARTS = List.of(
            "virtual", "banked", "selfmod", "a type", "a label", "parameters", "noreturn", "export", "'{'");

    /**
     * The parts that may follow the last part of an annotation line, which
     * holds `line`, named as in the format description.
     */
    private static List<String> remainingLineParts(List<Token> line, boolean codeLine) {
        int last = -1;
        int depth = 0;
        for (int i = 1; i < line.size(); i++) {
            int type = line.get(i).getType();
            String text = line.get(i).getText();
            if (text.equals("(")) {
                depth++;
            } else if (text.equals(")")) {
                depth--;
                last = LINE_PARTS.indexOf("parameters");
            } else if (depth > 0) {
                continue;
            } else if (type >= FloParser.SCREENCODE && type <= FloParser.CODE) {
                last = LINE_PARTS.indexOf("a type");
            } else if (type == FloParser.ID) {
                last = line.get(i - 1).getType() == EXPORT ? LINE_PARTS.indexOf("export") : LINE_PARTS.indexOf("a label");
            } else if (type == FloParser.OPEN_BLOCK || LINE_PARTS.contains(text)) {
                last = LINE_PARTS.indexOf(type == FloParser.OPEN_BLOCK ? "'{'" : text);
            }
        }
        List<String> parts = new ArrayList<>();
        int lastType = line.get(line.size() - 1).getType();
        for (String part : LINE_PARTS.subList(last + 1, LINE_PARTS.size())) {
            if (!codeLine && (part.equals("parameters") || part.equals("noreturn"))) {
                continue;
            }
            parts.add(part);
        }
        if (lastType >= FloParser.SCREENCODE && lastType <= FloParser.CODE) {
            parts.add(0, "a size");
        }
        parts.add("the end of the line");
        return parts;
    }

    /** The tokens on `found`'s line before it. */
    private static List<Token> tokensOfLineBefore(Parser parser, Token found) {
        TokenStream tokens = parser.getTokenStream();
        List<Token> line = new ArrayList<>();
        for (int i = found.getTokenIndex() - 1; i >= 0 && tokens.get(i).getType() != FloParser.NEWLINE; i--) {
            line.add(0, tokens.get(i));
        }
        return line;
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
        boolean isBanked = false;
        boolean isSelfMod = false;
        int amount = 1;
        String name = null;
        String export = null;
        Integer terminator = null;
        boolean lengthByte = false;
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
            isBanked = false;
            isSelfMod = false;
            amount = 1;
            name = null;
            export = null;
            terminator = null;
            lengthByte = false;
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
                    collect(Files.readString(local), name, new AnnotationCollector(run, true, local, chain));
                    return;
                }
                InputStream builtIn = FloReader.class.getResourceAsStream(BUILT_IN + name);
                if (builtIn == null) {
                    errors.add(String.format("line %d: no file %s to include", line, name));
                    return;
                }
                try (builtIn) {
                    collect(new String(builtIn.readAllBytes(), UTF_8), name, new AnnotationCollector(run, true, null, chain));
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
            // A parameter's type (issue 0068) is read in exitLine.
            if (!(ctx.getParent() instanceof FloParser.LineContext)) {
                return;
            }
            type = lineTypeOf(ctx);
            if (ctx.arraySize() != null) {
                amount = evaluate(ctx.arraySize());
            }
            if (ctx.untilSize() != null) {
                terminator = parseNumber(ctx.untilSize().number().getText()).orElseThrow();
            }
            lengthByte = ctx.lengthByte() != null;
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
        public void enterSetBanked(FloParser.SetBankedContext ctx) {
            isBanked = true;
        }

        @Override
        public void enterSetSelfMod(FloParser.SetSelfModContext ctx) {
            isSelfMod = true;
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
            if (terminator != null && !checkTerminator(line, type, terminator)) {
                return;
            }
            if (lengthByte && !checkLengthByte(line, type)) {
                return;
            }
            if (isBanked && (addressEnd != null || ctx.setVirtual() != null || ctx.datatype() != null || name == null
                    || ctx.parameters() != null || ctx.noReturn() != null || export != null)) {
                errors.add(String.format("line %d: a banked line takes only an address and a label", line));
                return;
            }
            if (isSelfMod && (addressEnd != null || ctx.setVirtual() != null || isBanked || ctx.datatype() != null || name == null
                    || ctx.parameters() != null || ctx.noReturn() != null || export != null)) {
                errors.add(String.format("line %d: a selfmod line takes only an address and a label", line));
                return;
            }
            // A virtual block's 'virtual' is about the memory, not a banked
            // name or a selfmod line.
            isVirtual &= !isBanked && !isSelfMod;
            List<Parameter> parameters = ctx.parameters() != null ? parameters(ctx.parameters(), line) : null;
            boolean noReturn = ctx.noReturn() != null;
            if ((parameters != null || noReturn) && type != CODE_LINE) {
                errors.add(String.format("line %d: only a code line takes parameters or noreturn", line));
                return;
            }
            run.annotations.add(new Annotation(address, addressEnd, type, isVirtual, amount, name, comment, included, export, terminator, lengthByte, parameters, noReturn, isBanked, isSelfMod));
        }

        /**
         * A routine's parameter list (issue 0068): the data after each jsr
         * to it, in order. Null after a mistake, which is reported.
         */
        private List<Parameter> parameters(FloParser.ParametersContext ctx, int line) {
            List<Parameter> parameters = new ArrayList<>();
            for (FloParser.ParameterContext parameter : ctx.parameter()) {
                FloParser.DatatypeContext datatype = parameter.datatype();
                LineType parameterType = lineTypeOf(datatype);
                if (parameterType == CODE_LINE) {
                    errors.add(String.format("line %d: a parameter can't be code", line));
                    return null;
                }
                int parameterAmount = datatype.arraySize() != null ? evaluate(datatype.arraySize()) : 1;
                Integer parameterTerminator = datatype.untilSize() != null
                        ? parseNumber(datatype.untilSize().number().getText()).orElseThrow()
                        : null;
                if (parameterTerminator != null && !checkTerminator(line, parameterType, parameterTerminator)) {
                    return null;
                }
                boolean parameterLengthByte = datatype.lengthByte() != null;
                if (parameterLengthByte && !checkLengthByte(line, parameterType)) {
                    return null;
                }
                if (parameterAmount <= 0) {
                    errors.add(String.format("line %d: zero-size parameter", line));
                    return null;
                }
                String parameterName = parameter.ID() != null ? parameter.ID().getText() : null;
                parameters.add(new Parameter(parameterType.dataType, parameterAmount, parameterTerminator, parameterLengthByte, parameterName));
            }
            return parameters;
        }

        /**
         * The value an "until" size ends at must fit in one element.
         */
        private boolean checkTerminator(int line, LineType lineType, int value) {
            if (lineType.dataType != null && value >= 1L << (8 * lineType.dataType.sizeInBytes)) {
                errors.add(String.format("line %d: until $%x doesn't fit in one %s", line, value, lineType.dataType.name().toLowerCase()));
                return false;
            }
            return true;
        }

        /**
         * A length byte counts elements of one byte (issue 0094).
         */
        private boolean checkLengthByte(int line, LineType lineType) {
            if (lineType.dataType != null && lineType.dataType.sizeInBytes != 1) {
                errors.add(String.format("line %d: lengthbyte needs a one-byte type, not %s", line, lineType.dataType.name().toLowerCase()));
                return false;
            }
            return true;
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
            if (addressEnd != null || ctx.setBanked() != null || ctx.setSelfMod() != null || ctx.datatype() != null || name != null || ctx.export() != null
                    || ctx.parameters() != null || ctx.noReturn() != null) {
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

    private static LineType lineTypeOf(FloParser.DatatypeContext ctx) {
        if (ctx.SCREENCODE() != null) {
            return SCREENCODE_LINE;
        } else if (ctx.ASCII() != null) {
            return ASCII_LINE;
        } else if (ctx.BYTE() != null) {
            return BYTE_LINE;
        } else if (ctx.WORD() != null) {
            return WORD_LINE;
        } else if (ctx.LONG() != null) {
            return LONG_LINE;
        } else if (ctx.DWORD() != null) {
            return DWORD_LINE;
        } else if (ctx.ADDR() != null) {
            return ADDR_LINE;
        } else if (ctx.RTA() != null) {
            return RTA_LINE;
        } else if (ctx.SBYTE() != null) {
            return SBYTE_LINE;
        } else if (ctx.SWORD() != null) {
            return SWORD_LINE;
        } else if (ctx.SLONG() != null) {
            return SLONG_LINE;
        } else if (ctx.SDWORD() != null) {
            return SDWORD_LINE;
        }
        return CODE_LINE;
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
