package com.laamella.deflower;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.io.Writer;
import java.net.URISyntaxException;
import java.nio.file.FileVisitResult;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.SimpleFileVisitor;
import java.nio.file.attribute.BasicFileAttributes;
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
     * Usage: [--verify] &lt;classpath-relative .flo file&gt;. Exits with 1 when
     * a run has errors or, with --verify, doesn't verify.
     */
    public static void main(String[] args) throws IOException, URISyntaxException {
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
            System.exit(2);
        }
        if (!new Deflower(verify).deflower(flowerFile)) {
            System.exit(1);
        }
    }

    /**
     * Runs the .flo file at this classpath-relative path.
     */
    public boolean deflower(String flowerFile) throws IOException, URISyntaxException {
        return deflower(Paths.get(Deflower.class.getResource("/" + flowerFile).toURI()));
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
