package com.laamella.deflower;

import java.util.ArrayList;
import java.util.List;

/**
 * One 'deflower &lt;file&gt;' line of a {@code .flo} file and the annotation
 * lines that follow it, up to the next 'deflower' line (issue 0010).
 */
final class DeflowerRun {
    // The memory image to load, as written in the .flo file: relative to
    // the .flo file's directory.
    final String targetName;
    final List<Annotation> annotations = new ArrayList<>();

    DeflowerRun(String targetName) {
        this.targetName = targetName;
    }
}
