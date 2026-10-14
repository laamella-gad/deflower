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
requires "npeg >= 1.3.0"
