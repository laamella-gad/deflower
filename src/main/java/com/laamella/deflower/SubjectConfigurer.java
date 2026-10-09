package com.laamella.deflower;

import java.io.IOException;
import java.net.URISyntaxException;
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

    List<Subject> configure(String flowerFile) throws URISyntaxException, IOException {
        Path path = Paths.get(Deflower.class.getResource("/" + flowerFile).toURI()).toAbsolutePath();
        Path basePath = path.getParent();
        List<Subject> subjects = new ArrayList<>();
        for (DeflowerRun run : floReader.read(path, flowerFile)) {
            Path filename = basePath.resolve(run.targetName);
            System.out.println("Reading " + filename);
            Subject subject = new Subject(basePath);
            subject.outputFileName = outputFileNameFor(run.targetName);
            subjects.add(subject);
            loadMemoryImage(filename, subject);
            run.annotations.forEach(subject::annotate);
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
