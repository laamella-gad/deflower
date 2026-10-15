# Package

version       = "0.1.0"
author        = "Laamella Gad"
description   = "Semi-automatic 6502 disassembler"
license       = "BSD-3-Clause"
srcDir        = "src"
bin           = @["deflower"]
binDir        = "bin"

# Dependencies

requires "nim >= 2.2.0"

task flo, "Regenerate the .flo parser from src/deflower/flo/flo.ldb with lindeboom":
  # lindeboom's sources: LINDEBOOM_SRC, or next to this project.
  let lindeboom = getEnv("LINDEBOOM_SRC", thisDir() & "/../nim_parser_generator")
  exec "nim c -d:release --hints:off -o:" & thisDir() & "/bin/lindeboom " & lindeboom & "/src/nim_parser_generator.nim"
  exec thisDir() & "/bin/lindeboom gen --standalone -o " & thisDir() & "/src/deflower/flo " &
    thisDir() & "/src/deflower/flo/flo.ldb"
