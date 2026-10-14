## Runs a .flo file through the pipeline: SubjectConfigurer turns it into
## Subjects in two phases - parse the file into runs (flo_reader), then for
## each run load its memory image (loaders) and apply its annotations in
## order (Subject.annotate) - and `deflower` analyses and writes each one.

import std/[algorithm, os, sequtils, strutils, sugar]
import printing, subject, flo_reader, loaders, flow_analyser, finders, result_writer, memory_map, verifier

proc loadMemoryImage(filename: string, subject: Subject) =
  if filename.endsWith("vsf"):
    readViceSnapshot(filename, subject)
  elif filename.endsWith("prg"):
    readPrg(filename, subject)
  else:
    raise newException(CatchableError, "Unsupported input format")

proc outputFileNameFor(targetFileName: string): string =
  let baseName = extractFilename(targetFileName)
  let dot = baseName.rfind('.')
  (if dot > 0: baseName[0 ..< dot] else: baseName) & ".asm"

proc configure*(flowerFile: string, files: var seq[string]): seq[Subject] =
  ## The Subjects of the .flo file. Adds the paths of the files they are made
  ## from, besides the .flo file itself, to `files`, as far as it gets when
  ## it fails: the .flo files it includes from disk and the binaries.
  let path = absolutePath(flowerFile)
  let basePath = parentDir(path)
  for run in readFlo(path, extractFilename(path), files):
    let subject = newSubject(basePath)
    subject.outputFileName = outputFileNameFor(run.targetName)
    result.add subject
    let binary = basePath / run.targetName
    if binary notin files:
      files.add binary
    loadMemoryImage(binary, subject)
    # The banked names first, so an rta line can't trace into the RAM under
    # one (issue 0102). Then the including file's own lines: included ones
    # are weak and only fill in what those leave open (issue 0078).
    # The sort is stable, so the lines keep their order otherwise.
    let annotations = run.annotations.sorted(proc (a, b: Annotation): int =
      cmp((not a.banked, a.included), (not b.banked, b.included)))
    for annotation in annotations:
      subject.annotate(annotation)
    subject.checkBankedCodeEntries()

proc configure*(flowerFile: string): seq[Subject] =
  var files: seq[string]
  configure(flowerFile, files)

proc write(subject: Subject): string =
  ## Writes the .asm, the exported binaries and the .map of the subject, and
  ## returns the path of the .asm.
  let asmFile = subject.outputPath / subject.outputFileName
  printOut("Writing " & relativePath(asmFile, subject.basePath))
  writeFile(asmFile, writeAssembly(subject))
  for region in subject.exports:
    let binFile = subject.outputPath / region.fileName
    printOut("Writing " & relativePath(binFile, subject.basePath))
    writeFile(binFile, cast[string](subject.bytesOf(region)))
  let mapFile = subject.outputPath / subject.outputFileName.dup(removeSuffix(".asm")) & ".map"
  printOut("Writing " & relativePath(mapFile, subject.basePath))
  var map = ""
  for line in mapLines(subject):
    map.add line & "\n"
  writeFile(mapFile, map)
  asmFile

type
  Outcome* = enum
    ## How a run of a .flo file went.
    oFine
      ## Written, and verified when asked.
    oNotVerified
      ## Written, but it doesn't verify.
    oFailed
      ## A run has errors: its output isn't written.

proc analyse(subject: Subject) =
  analyseCodeFlows(subject)
  findAddressSetups(subject)
  findSelfModifications(subject)
  subject.warnUsedSkeletonRanges()
  subject.dropUnusedIncludes()
  subject.reportDuplicateLabels()

proc run*(flowerFile: string, verify: bool, keepOnError: bool, files: var seq[string]): Outcome =
  ## Runs the .flo file at this path and adds the paths of the files it is
  ## made from to `files` (`configure`). With `keepOnError`, an error in any
  ## of its runs leaves `out/` as it was, rather than only skipping that
  ## run's output (issue 0057).
  result = oFine
  try:
    let subjects = configure(flowerFile, files)
    if subjects.len == 0:
      return
    for subject in subjects:
      analyse(subject)
    let writing = not keepOnError or subjects.allIt(it.errors.len == 0)
    # Cleared and recreated once per .flo file, before any of its (possibly
    # several) Subjects are written, so that one deflower line's run doesn't
    # delete another's output.
    if writing:
      let outputDirectory = subjects[0].basePath / "out"
      removeDir(outputDirectory)
      createDir(outputDirectory)
    for subject in subjects:
      let warnings = subject.warnings.sorted(proc (a, b: Warning): int = cmp(a.address, b.address))
      var printed: seq[string]
      for warning in warnings:
        let line = $warning
        if line notin printed:
          printed.add line
          printOut(line)
      if subject.errors.len > 0:
        for error in subject.errors:
          printErr(error)
        printErr("Errors detected for " & subject.outputFileName & ", not writing output.")
        result = oFailed
        continue
      if not writing:
        continue
      let asmFile = write(subject)
      if verify and not verifier.verify(subject, asmFile) and result == oFine:
        result = oNotVerified
  except StateError as e:
    printErr(e.msg)
    result = oFailed

proc deflower*(flowerFile: string, verify = false): bool =
  ## Runs the .flo file at this path. Messages name files relative to its
  ## directory. Returns false when a run has errors or, when verifying,
  ## doesn't verify.
  var files: seq[string]
  run(flowerFile, verify, false, files) == oFine
