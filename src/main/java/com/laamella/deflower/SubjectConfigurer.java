package com.laamella.deflower;

import com.laamella.enflower.FloBaseListener;
import com.laamella.enflower.FloLexer;
import com.laamella.enflower.FloParser;
import com.laamella.mpu6502.ByteManipulation;
import com.laamella.vicevcf.C64MemModule;
import com.laamella.vicevcf.C64MemModuleHandler;
import com.laamella.vicevcf.ViceVcfFile;
import com.laamella.vicevcf.ViceVcfFileReader;
import org.antlr.v4.runtime.BaseErrorListener;
import org.antlr.v4.runtime.CharStreams;
import org.antlr.v4.runtime.CommonTokenStream;
import org.antlr.v4.runtime.RecognitionException;
import org.antlr.v4.runtime.Recognizer;
import org.antlr.v4.runtime.tree.ParseTreeWalker;

import java.io.IOException;
import java.net.URISyntaxException;
import java.nio.ByteBuffer;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

import static com.laamella.Assert.assertState;
import static com.laamella.deflower.DataType.*;
import static com.laamella.deflower.SubjectConfigurer.LineType.*;
import static java.nio.file.Files.readAllBytes;

class SubjectConfigurer {
    enum LineType {
        CHAR_BLOCK(CHAR), BYTE_BLOCK(BYTE), CODE_ENTRY(null), WORD_BLOCK(WORD), DWORD_BLOCK(DWORD);
        final DataType dataType;

        LineType(DataType dataType) {
            this.dataType = dataType;
        }
    }

    List<Subject> configure(String flowerFile) throws URISyntaxException, IOException {
        Path path = Paths.get(Deflower.class.getResource("/" + flowerFile).toURI()).toAbsolutePath();
        Path basePath = path.getParent();
        List<Subject> subjects = new ArrayList<>();
        List<String> parseErrors = new ArrayList<>();
        FloParser parser = createParser(parseErrors, path);
        ParseTreeWalker walker = new ParseTreeWalker();
        FloBaseListener listener = new FloBaseListener() {
            Subject subject = null;
            Integer address = null;
            Integer addressEnd = null;
            LineType type = BYTE_BLOCK;
            boolean isSystem = false;
            int amount = 1;
            String name = null;

            void startNewLine() {
                address = null;
                addressEnd = null;
                type = BYTE_BLOCK;
                isSystem = false;
                amount = 1;
                name = null;
            }

            @Override
            public void enterSetFileName(FloParser.SetFileNameContext ctx) {
                String targetName = ctx.ID().getText();
                Path filename = basePath.resolve(targetName);
                System.out.println("Reading " + filename);
                subject = new Subject(basePath);
                subject.outputFileName = outputFileNameFor(targetName);
                subjects.add(subject);
                String filenameString = filename.toString();
                if (filenameString.endsWith("vsf")) {
                    System.out.println("Reading snapshot " + filename);
                    readSnapshot(filename, subject);
                } else if (filenameString.endsWith("prg")) {
                    System.out.println("Reading prg " + filename);
                    readPrgFile(filename, subject);
                } else {
                    throw new RuntimeException("Unsupported input format");
                }
            }

            @Override
            public void enterLine(FloParser.LineContext ctx) {
                startNewLine();
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
            public void exitLine(FloParser.LineContext ctx) {
                assertState(subject != null, "Start the file with a 'deflower <file>' line.", ctx.getStart().getLine(), ctx.getText());
                assertState(address != null, "Require an address: %s", ctx);
                if (name != null) {
                    subject.memory[address].label = name;
                }
                switch (type) {
                    case CODE_ENTRY -> {
                        subject.potentialCodeLocations.add(address);
                        System.out.format("Will disassemble from %X\n", address);
                    }
                    case BYTE_BLOCK, WORD_BLOCK, DWORD_BLOCK -> {
                        if (addressEnd != null) {
                            amount = (addressEnd - address) / type.dataType.sizeInBytes;
                        }
                        System.out.format("Marking block of %d %s at %X \"%s\"\n", amount, type.dataType.name().toLowerCase(), address, name);
                        for (int i = 0; i < amount; i++) {
                            subject.registerBlock(new DataArea(address + i * type.dataType.sizeInBytes, type.dataType, isSystem));
                        }
                    }
                    default -> throw new RuntimeException("No data type");
                }
            }

            @Override
            public void enterSetLabel(FloParser.SetLabelContext ctx) {
                name = ctx.ID().getText();
            }
        };
        FloParser.ProgContext tree = parser.prog();
        assertState(parseErrors.isEmpty(), "Failed to parse %s:%n%s", flowerFile, String.join("\n", parseErrors));
        walker.walk(listener, tree);

        return subjects;
    }

    private static String outputFileNameFor(String targetFileName) {
        String baseName = Paths.get(targetFileName).getFileName().toString();
        int dot = baseName.lastIndexOf('.');
        return (dot > 0 ? baseName.substring(0, dot) : baseName) + ".asm";
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

    private Optional<Integer> parseNumber(String part) {
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

    private static final Set<String> supportedMachines = new HashSet<>();

    static {
        supportedMachines.add("C64");
        supportedMachines.add("C64SC");
    }

    private void readSnapshot(Path c64File, Subject subject) {
        try {
            ByteBuffer c64Dump = ByteBuffer.wrap(readAllBytes(c64File));
            ViceVcfFile vcfFile = new ViceVcfFileReader().read(c64Dump, new C64MemModuleHandler());
            System.out.println(vcfFile);

            if (!supportedMachines.contains(vcfFile.header.machineName)) {
                throw new IllegalArgumentException("Only C64 dumps supported.");
            }
            subject.storeAt(0, vcfFile.modules.stream()
                    .filter(C64MemModule.class::isInstance)
                    .map(C64MemModule.class::cast)
                    .map(module -> module.ram)
                    .findAny()
                    .orElseThrow(() -> new IllegalArgumentException("No C64MEM found.")));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }

    private void readPrgFile(Path c64File, Subject subject) {
        try {
            ByteBuffer c64Dump = ByteBuffer.wrap(readAllBytes(c64File));
            int lo = c64Dump.get();
            int hi = c64Dump.get();
            int loadAddress = ByteManipulation.word(lo, hi);
            System.out.println("load address " + loadAddress);
            byte[] b = new byte[c64Dump.remaining()];
            c64Dump.get(b);
            subject.storeAt(loadAddress, b);
        } catch (IOException e) {
            throw new RuntimeException(e);
        }
    }
}
