package com.laamella.deflower;

import java.io.IOException;
import java.net.URISyntaxException;

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
            for (Subject subject : subjectConfigurer.configure(flowerFile)) {
                flowAnalyser.analyseCodeFlows(subject);
                resultWriter.write(subject);
            }
        } catch (IllegalStateException e) {
            System.err.println(e.getMessage());
        }
    }
}
