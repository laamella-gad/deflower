package com.laamella.deflower;

import java.io.IOException;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.ArrayList;
import java.util.List;

/**
 * Turns a {@code .flo} file into Subjects, in two phases: parse the file
 * into runs ({@link FloReader}), then for each run load its memory image
 * ({@link ViceSnapshotReader}, {@link PrgReader}) and apply its annotations in order
 * ({@link Subject#annotate}).
 */
class SubjectConfigurer {
    private final FloReader floReader = new FloReader();
    private final ViceSnapshotReader viceSnapshotReader = new ViceSnapshotReader();
    private final PrgReader prgReader = new PrgReader();

    List<Subject> configure(Path flowerFile) throws IOException {
        Path path = flowerFile.toAbsolutePath();
        Path basePath = path.getParent();
        List<Subject> subjects = new ArrayList<>();
        for (DeflowerRun run : floReader.read(path, path.getFileName().toString())) {
            Path filename = basePath.resolve(run.targetName);
            System.out.println("Reading " + run.targetName);
            Subject subject = new Subject(basePath);
            subject.outputFileName = outputFileNameFor(run.targetName);
            subjects.add(subject);
            loadMemoryImage(filename, subject);
            // The including file's own lines first: included ones are weak
            // and only fill in what those leave open (issue 0078).
            run.annotations.stream().filter(a -> !a.included).forEach(subject::annotate);
            run.annotations.stream().filter(a -> a.included).forEach(subject::annotate);
        }
        return subjects;
    }

    private void loadMemoryImage(Path filename, Subject subject) {
        String filenameString = filename.toString();
        if (filenameString.endsWith("vsf")) {
            viceSnapshotReader.read(filename, subject);
        } else if (filenameString.endsWith("prg")) {
            prgReader.read(filename, subject);
        } else {
            throw new RuntimeException("Unsupported input format");
        }
    }

    private static String outputFileNameFor(String targetFileName) {
        String baseName = Paths.get(targetFileName).getFileName().toString();
        int dot = baseName.lastIndexOf('.');
        return (dot > 0 ? baseName.substring(0, dot) : baseName) + ".asm";
    }
}
