package com.laamella.deflower;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.URISyntaxException;

class DeflowerTest {
    @Test
    void run() throws IOException, URISyntaxException {
        new Deflower().deflower("squirm.flo");
    }
}