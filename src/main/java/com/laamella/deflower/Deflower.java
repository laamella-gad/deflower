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
        Subject subject;
        try {
            subject = subjectConfigurer.configure(flowerFile);
        } catch (IllegalStateException e) {
            System.err.println(e.getMessage());
            return;
        }
        flowAnalyser.analyseCodeFlows(subject);
//        do {
            resultWriter.write(subject);
//            System.out.println(System.currentTimeMillis());
//        } while (true);
    }
}
