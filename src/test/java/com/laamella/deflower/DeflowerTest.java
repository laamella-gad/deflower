package com.laamella.deflower;

import org.junit.jupiter.api.Test;

import java.io.IOException;
import java.net.URISyntaxException;

class DeflowerTest {
    @Test
    void deflowerSquirm() throws IOException, URISyntaxException {
        new Deflower().deflower("squirm/squirm.flo");
    }

    @Test
    void deflowerTCMine() throws IOException, URISyntaxException {
        new Deflower().deflower("tcmine/tcmine.flo");
    }

    @Test
    void deflowerZwark() throws IOException, URISyntaxException {
        new Deflower().deflower("zwark/zwark.flo");
    }
}