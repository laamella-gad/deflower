package com.laamella.deflower;

import java.io.IOException;
import java.net.URISyntaxException;
import java.util.List;

public class Deflower {
    private final SubjectConfigurer subjectConfigurer = new SubjectConfigurer();
    private final FlowAnalyser flowAnalyser = new FlowAnalyser();
    private final ResultWriter resultWriter = new ResultWriter();

    public Deflower() {
    }

    public static void main(String[] args) throws IOException, URISyntaxException {
        new Deflower().deflower(args[0]);
    }

    public void deflower(String flowerFile) throws IOException, URISyntaxException {
        try {
            List<Subject> subjects = subjectConfigurer.configure(flowerFile);
            if (subjects.isEmpty()) {
                return;
            }
            resultWriter.prepareOutputDirectory(subjects.get(0).basePath);
            for (Subject subject : subjects) {
                flowAnalyser.analyseCodeFlows(subject);
                if (!subject.errors.isEmpty()) {
                    subject.errors.forEach(System.err::println);
                    System.err.println("Errors detected for " + subject.outputFileName + ", not writing output.");
                    continue;
                }
                resultWriter.write(subject);
            }
        } catch (IllegalStateException e) {
            System.err.println(e.getMessage());
        }
    }
}
