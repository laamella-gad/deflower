package com.laamella.deflower;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

import static java.nio.file.FileVisitResult.CONTINUE;
import static java.nio.file.Files.createDirectories;
import static java.nio.file.Files.delete;
import static java.nio.file.Files.walkFileTree;

public class Deflower {
    private final SubjectConfigurer subjectConfigurer = new SubjectConfigurer();
    private final FlowAnalyser flowAnalyser = new FlowAnalyser();
    private final AddressSetupFinder addressSetupFinder = new AddressSetupFinder();
    private final SelfModificationFinder selfModificationFinder = new SelfModificationFinder();
    private final ResultWriter resultWriter = new ResultWriter();
    private final Verifier verifier = new Verifier();
    // Reassemble each written .asm and check it against its image (issue 0075).
    private final boolean verify;

    public Deflower() {
        this(false);
    }

    public Deflower(boolean verify) {
        this.verify = verify;
    }

    /**
     * Usage: [--verify] &lt;.flo file&gt;. Exits with 1 when
     * a run has errors or, with --verify, doesn't verify. Or: --init
     * &lt;.vsf or .prg file&gt;, which writes a .flo skeleton next to the
     * file to start its disassembly (issue 0072), and exits with 1 when
     * that .flo file exists already. Or: --dump &lt;.vsf or .prg file&gt;
     * &lt;range&gt;, which hex-dumps that memory of the file (issue 0097).
     * Or: --find &lt;.vsf or .prg file&gt; &lt;address or bytes&gt; [in
     * &lt;range&gt;], which searches its memory (issue 0099). Or: --strings
     * &lt;.vsf or .prg file&gt; [&lt;range&gt;] [min &lt;n&gt;], which lists the text in
     * its memory (issue 0100).
     */
    public static void main(String[] args) throws IOException {
        if (args.length == 2 && args[0].equals("--init")) {
            if (!new Initializer().write(Paths.get(args[1]))) {
                System.exit(1);
            }
            return;
        }
        if (args.length >= 2 && LOOK_FLAGS.contains(args[0])) {
            List<String> arguments = Arrays.asList(args).subList(2, args.length);
            printOrExit(() -> look(args[0], Paths.get(args[1]), arguments));
            return;
        }
        boolean verify = false;
        String flowerFile = null;
        for (String arg : args) {
            if (arg.equals("--verify")) {
                verify = true;
            } else if (flowerFile == null && !arg.startsWith("--")) {
                flowerFile = arg;
            } else {
                flowerFile = null;
                break;
            }
        }
        if (flowerFile == null) {
            System.err.println("Usage: deflower [--verify] <file.flo>");
            System.err.println("       deflower --init <file.vsf or file.prg>");
            System.err.println("       deflower --dump <file.vsf or file.prg> <start>-<end>");
            System.err.println("       deflower --find <file.vsf or file.prg> <address or bytes> [in <start>-<end>]");
            System.err.println("       deflower --strings <file.vsf or file.prg> [<start>-<end>] [min <n>]");
            System.exit(2);
        }
        Path flowerPath = Paths.get(flowerFile);
        if (!Files.isRegularFile(flowerPath)) {
            System.err.println("No such file: " + flowerFile);
            System.exit(2);
        }
        if (!new Deflower(verify).deflower(flowerPath)) {
            System.exit(1);
        }
    }

    private static final List<String> LOOK_FLAGS = List.of("--dump", "--find", "--strings");

    /**
     * Runs a tool that looks at an input file without a .flo file:
     * {@code --dump}, {@code --find} or {@code --strings}, with the
     * arguments after the file. Bad arguments throw an
     * IllegalArgumentException.
     */
    static List<String> look(String flag, Path file, List<String> arguments) throws IOException {
        List<String> rest = new ArrayList<>(arguments);
        switch (flag) {
            case "--dump":
                if (rest.size() == 1) {
                    return new Dumper().dump(file, rest.get(0));
                }
                break;
            case "--find": {
                String range = takeOption(rest, "in");
                if (!rest.isEmpty()) {
                    return new Finder().find(file, rest, range);
                }
                break;
            }
            case "--strings": {
                String minimum = takeOption(rest, "min");
                if (rest.size() <= 1) {
                    return new TextFinder().find(file, rest.isEmpty() ? null : rest.get(0),
                            minimum == null ? TextFinder.MIN_CHARACTERS : minimumLength(minimum));
                }
                break;
            }
            default:
                break;
        }
        throw new IllegalArgumentException("Wrong arguments for " + flag + ": " + String.join(" ", arguments));
    }

    /**
     * Removes "{@code <keyword> <value>}" from the end of the arguments, and
     * returns the value, or null when they don't end that way.
     */
    private static String takeOption(List<String> arguments, String keyword) {
        int size = arguments.size();
        if (size < 2 || !arguments.get(size - 2).equals(keyword)) {
            return null;
        }
        String value = arguments.get(size - 1);
        arguments.subList(size - 2, size).clear();
        return value;
    }

    private static int minimumLength(String text) {
        try {
            return Dumper.number(text);
        } catch (NumberFormatException e) {
            throw new IllegalArgumentException("Not a minimum length: " + text);
        }
    }

    private interface Lines {
        List<String> get() throws IOException;
    }

    /**
     * Prints the lines of a tool that looks at an input file, or its error
     * about the arguments with exit code 2.
     */
    private static void printOrExit(Lines lines) throws IOException {
        try {
            lines.get().forEach(System.out::println);
        } catch (IllegalArgumentException e) {
            System.err.println(e.getMessage());
            System.exit(2);
        }
    }

    /**
     * Runs the .flo file at this path. Messages name files relative to
     * its directory. Returns false when a run has errors or, when
     * verifying, doesn't verify.
     */
    public boolean deflower(Path flowerFile) throws IOException {
        boolean ok = true;
        try {
            List<Subject> subjects = subjectConfigurer.configure(flowerFile);
            if (subjects.isEmpty()) {
                return true;
            }
            prepareOutputDirectory(subjects.get(0).basePath);
            for (Subject subject : subjects) {
                flowAnalyser.analyseCodeFlows(subject);
                addressSetupFinder.find(subject);
                selfModificationFinder.find(subject);
                subject.warnUsedSkeletonRanges();
                subject.dropUnusedIncludes();
                subject.reportDuplicateLabels();
                subject.warnings.stream()
                        .sorted(Comparator.comparingInt(warning -> warning.address))
                        .map(Warning::toString)
                        .distinct()
                        .forEach(System.out::println);
                if (!subject.errors.isEmpty()) {
                    subject.errors.forEach(System.err::println);
                    System.err.println("Errors detected for " + subject.outputFileName + ", not writing output.");
                    ok = false;
                    continue;
                }
                Path asmFile = write(subject);
                if (verify && !verifier.verify(subject, asmFile)) {
                    ok = false;
                }
            }
        } catch (IllegalStateException e) {
            System.err.println(e.getMessage());
            ok = false;
        }
        return ok;
    }

    private Path write(Subject subject) throws IOException {
        Path asmFile = subject.outputPath.resolve(subject.outputFileName);
        System.out.println("Writing " + subject.basePath.relativize(asmFile));
        try (Writer w = new BufferedWriter(new FileWriter(asmFile.toFile()))) {
            resultWriter.write(subject, w);
        }
        for (ExportRegion export : subject.exports) {
            Path binFile = subject.outputPath.resolve(export.fileName);
            System.out.println("Writing " + subject.basePath.relativize(binFile));
            Files.write(binFile, subject.bytesOf(export));
        }
        Path mapFile = subject.outputPath.resolve(subject.outputFileName.replaceFirst("\\.asm$", "") + ".map");
        System.out.println("Writing " + subject.basePath.relativize(mapFile));
        Files.write(mapFile, MemoryMap.lines(subject));
        return asmFile;
    }

    /**
     * Clears and recreates the shared output directory. Called once per
     * .flo file, before any of its (possibly several) Subjects are written,
     * so that one deflower line's run doesn't delete another's output.
     */
    private void prepareOutputDirectory(Path basePath) throws IOException {
        recreateDirectory(basePath.resolve("out"));
    }

    private void recreateDirectory(Path directory) throws IOException {
        if (Files.exists(directory)) {
            walkFileTree(directory, new SimpleFileVisitor<>() {
                @Override
                public FileVisitResult visitFile(Path file, BasicFileAttributes attrs) throws IOException {
                    delete(file);
                    return CONTINUE;
                }

                @Override
                public FileVisitResult postVisitDirectory(Path dir, IOException exc) throws IOException {
                    delete(dir);
                    return CONTINUE;
                }
            });
        }
        createDirectories(directory);
    }
}
