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
import java.util.List;

import static java.nio.file.FileVisitResult.CONTINUE;
import static java.nio.file.Files.createDirectories;
import static java.nio.file.Files.delete;
import static java.nio.file.Files.walkFileTree;

public class Deflower {
    private final SubjectConfigurer subjectConfigurer = new SubjectConfigurer();
    private final FlowAnalyser flowAnalyser = new FlowAnalyser();
    private final ResultWriter resultWriter = new ResultWriter();

    public Deflower() {
    }

    public static void main(String[] args) throws IOException, URISyntaxException {
        new Deflower().deflower(args[0]);
    }

    /**
     * Runs the .flo file at this classpath-relative path.
     */
    public void deflower(String flowerFile) throws IOException, URISyntaxException {
        deflower(Paths.get(Deflower.class.getResource("/" + flowerFile).toURI()));
    }

    /**
     * Runs the .flo file at this path. Messages name files relative to
     * its directory.
     */
    public void deflower(Path flowerFile) throws IOException {
        try {
            List<Subject> subjects = subjectConfigurer.configure(flowerFile);
            if (subjects.isEmpty()) {
                return;
            }
            prepareOutputDirectory(subjects.get(0).basePath);
            for (Subject subject : subjects) {
                flowAnalyser.analyseCodeFlows(subject);
                subject.dropUnusedIncludes();
                subject.reportDuplicateLabels();
                if (!subject.errors.isEmpty()) {
                    subject.errors.forEach(System.err::println);
                    System.err.println("Errors detected for " + subject.outputFileName + ", not writing output.");
                    continue;
                }
                write(subject);
            }
        } catch (IllegalStateException e) {
            System.err.println(e.getMessage());
        }
    }

    private void write(Subject subject) throws IOException {
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
