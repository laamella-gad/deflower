## Snippet tests on top of `std/unittest`, ported from the core of the Java
## snippets-test-junit5.
##
## A snippet file holds one test: an optional description, the test case's
## input parts, and the expectations, the output the test case should give.
## `runSnippetTests` makes one unittest test per snippet file in a directory.
## A file without expectations gets the actual output written into it, and
## its test fails once, so the output can be reviewed. With the environment
## variable `REGENERATE_EXPECTATIONS` set, every file gets its expectations
## rewritten that way.

import std/[algorithm, options, os, strutils, unittest]

export options

type
  SnippetFileFormat* = object
    ## The strings that organize a snippet file.
    descriptionStartString*: string
      ## Starts the optional description. It has to be the very first text in
      ## the file, else the file has no description.
    descriptionEndString*: string
      ## Ends the description. You probably want to end it with a "\n".
    separatorBetweenTestCases*: string
      ## Goes between the test case's input parts. When it is empty, the
      ## input is one part.
    separatorAfterTestCase*: string
      ## Comes right after the input parts. When it is missing, the file has
      ## no expectations yet, and the actual output is written into it.
    separatorBetweenExpectations*: string
      ## Goes between the expectations, in the order the test case gives them.
    expectationsEndString*: string
      ## The last text in the file.

  SnippetTestFailure* = object of CatchableError
    ## A snippet test that can't run as it is set up. It fails the test,
    ## instead of becoming the test's actual output as other errors do.

  TestCase* = proc (testCaseParts: seq[string]): seq[string]
    ## Takes the input parts found in a snippet file, runs the test, and
    ## gives the actual output, compared with the file's expectations. An
    ## error's message becomes the actual output.

  TestCaseFilenameFilter* = proc (path: string): bool
    ## Selects snippet files by their absolute path.

  BasePath* = object
    ## Builds the path to a directory of snippet files.
    path: string

  SnippetTestFile* = object
    ## A snippet file split into its description, input parts and expectations.
    description*: Option[string]
      ## Includes its start string, not its end string.
    testCaseParts*: seq[string]
    expected*: Option[string]
      ## The expectations, joined by their separator. None when the file has none yet.

  SnippetOutcomeKind* = enum
    soPassed, soFailed, soGenerated

  SnippetOutcome* = object
    kind*: SnippetOutcomeKind
    expected*: string
      ## The expectations the file held; empty for a generated one.
    actual*: string

proc snippetFileFormat*(descriptionStartString, descriptionEndString, separatorBetweenTestCases,
    separatorAfterTestCase, separatorBetweenExpectations, expectationsEndString: string): SnippetFileFormat =
  SnippetFileFormat(
    descriptionStartString: descriptionStartString,
    descriptionEndString: descriptionEndString,
    separatorBetweenTestCases: separatorBetweenTestCases,
    separatorAfterTestCase: separatorAfterTestCase,
    separatorBetweenExpectations: separatorBetweenExpectations,
    expectationsEndString: expectationsEndString)

proc splitParts*(str, pattern: string): seq[string] =
  ## Splits on every occurrence of the pattern. Unlike `strutils.split`, an
  ## empty string gives no parts and an empty pattern gives the whole string
  ## as one part. A pattern at the end gives an empty last part.
  if pattern.len == 0:
    return @[str]
  var fromIndex = 0
  while fromIndex < str.len:
    let matchIndex = str.find(pattern, fromIndex)
    if matchIndex < 0:
      result.add str[fromIndex .. ^1]
      break
    result.add str[fromIndex ..< matchIndex]
    fromIndex = matchIndex + pattern.len
    if fromIndex == str.len:
      result.add ""

# Test cases.

proc checkOneInput(testCaseParts: seq[string]) =
  if testCaseParts.len != 1:
    raise newException(SnippetTestFailure,
        "Simple test case should have only one input, got " & $testCaseParts.len)

proc simpleTestCase*(testCase: proc (input: string): string): TestCase =
  ## A test case with one input and one output.
  result = proc (testCaseParts: seq[string]): seq[string] =
    checkOneInput(testCaseParts)
    @[testCase(testCaseParts[0])]

proc multiInputTestCase*(testCase: proc (inputs: seq[string]): string): TestCase =
  ## A test case with several inputs and one output.
  result = proc (testCaseParts: seq[string]): seq[string] =
    @[testCase(testCaseParts)]

proc multiOutputTestCase*(testCase: proc (input: string): seq[string]): TestCase =
  ## A test case with one input and several outputs.
  result = proc (testCaseParts: seq[string]): seq[string] =
    checkOneInput(testCaseParts)
    testCase(testCaseParts[0])

# File name filters.

proc allFiles*(): TestCaseFilenameFilter =
  result = proc (path: string): bool = true

proc filesWithExtension*(extension: string): TestCaseFilenameFilter =
  ## The files whose name ends in the extension, with a dot in front of it
  ## whether it is given or not.
  let extensionWithDot = if extension.startsWith('.'): extension else: '.' & extension
  result = proc (path: string): bool = path.endsWith(extensionWithDot)

# Base paths.

proc fromPath*(path: string): BasePath =
  BasePath(path: path)

template fromSourceDirectory*(): BasePath =
  ## The directory of the source file this is written in.
  fromPath(parentDir(instantiationInfo(-1, true).filename))

proc inSubDirectory*(basePath: BasePath, subDirectory: string): BasePath =
  ## A directory below this one. It may be several levels down, as "a/b".
  BasePath(path: basePath.path / subDirectory)

proc toPath*(basePath: BasePath): string =
  basePath.path

# Snippet files.

proc readSnippetTestFile*(file: string, format: SnippetFileFormat): SnippetTestFile =
  let completeFile = readFile(file)
  var fileAfterDescription = completeFile
  if completeFile.startsWith(format.descriptionStartString):
    let descriptionEndPosition = completeFile.find(format.descriptionEndString)
    if descriptionEndPosition == -1:
      raise newException(SnippetTestFailure, "Starting description has no ending.")
    result.description = some(completeFile[0 ..< descriptionEndPosition])
    fileAfterDescription = completeFile[descriptionEndPosition + format.descriptionEndString.len .. ^1]
  var testCase = fileAfterDescription
  let expectationsPosition = fileAfterDescription.find(format.separatorAfterTestCase)
  if expectationsPosition != -1:
    testCase = fileAfterDescription[0 ..< expectationsPosition]
    let expectedStart = expectationsPosition + format.separatorAfterTestCase.len
    let expectedEnd = fileAfterDescription.len - format.expectationsEndString.len
    if expectedEnd < expectedStart:
      raise newException(SnippetTestFailure, "The expectations are shorter than their end string.")
    result.expected = some(fileAfterDescription[expectedStart ..< expectedEnd])
  result.testCaseParts = splitParts(testCase, format.separatorBetweenTestCases)

proc writeSnippetTestFile*(file: string, format: SnippetFileFormat, snippet: SnippetTestFile) =
  ## Writes the snippet, with empty expectations when it has none.
  var content = snippet.testCaseParts.join(format.separatorBetweenTestCases) &
      format.separatorAfterTestCase & snippet.expected.get("") & format.expectationsEndString
  if snippet.description.isSome:
    content = snippet.description.get & format.descriptionEndString & content
  writeFile(file, content)

proc shouldRegenerate*(): bool =
  existsEnv("REGENERATE_EXPECTATIONS")

proc executeSnippetTest*(file: string, format: SnippetFileFormat, testCase: TestCase,
    regenerate: bool): SnippetOutcome =
  ## Runs the test case on the snippet file's input parts and compares the
  ## output with the file's expectations. When there are none, or when
  ## regenerating, it writes the output into the file instead.
  var snippet = readSnippetTestFile(file, format)
  var actual: string
  try:
    actual = testCase(snippet.testCaseParts).join(format.separatorBetweenExpectations)
  except SnippetTestFailure:
    raise
  except CatchableError as e:
    actual = e.msg
  if snippet.expected.isNone or regenerate:
    snippet.expected = some(actual)
    writeSnippetTestFile(file, format, snippet)
    SnippetOutcome(kind: soGenerated, actual: actual)
  else:
    let expected = snippet.expected.get
    SnippetOutcome(kind: if expected == actual: soPassed else: soFailed, expected: expected, actual: actual)

proc snippetTestFiles*(basePath: BasePath, filter: TestCaseFilenameFilter): seq[string] =
  ## The snippet files in the directory and its subdirectories, relative to
  ## it, sorted. A missing directory is created, and fails.
  let testCasesPath = absolutePath(basePath.path)
  if not dirExists(testCasesPath):
    createDir(testCasesPath)
    raise newException(SnippetTestFailure, "Created new testcases directory in " & testCasesPath)
  for file in walkDirRec(testCasesPath, relative = true):
    if filter(testCasesPath / file):
      result.add file
  result.sort()

proc firstDifferentLine(expected, actual: string): int =
  ## The number of the first line that differs, from 1.
  let expectedLines = expected.splitLines
  let actualLines = actual.splitLines
  result = 1
  while result <= expectedLines.len and result <= actualLines.len and
      expectedLines[result - 1] == actualLines[result - 1]:
    inc result

proc runSnippetTests*(format: SnippetFileFormat, basePath: BasePath, filter: TestCaseFilenameFilter,
    testCase: TestCase) =
  ## Makes one unittest test per snippet file the filter accepts in the
  ## directory and its subdirectories, named by its path relative to the
  ## directory. The test case gets each file's input parts, and its output
  ## is compared with the file's expectations.
  var files: seq[string]
  try:
    files = snippetTestFiles(basePath, filter)
  except SnippetTestFailure as e:
    let message = e.msg
    test basePath.path:
      checkpoint message
      fail()
    return
  let regenerate = shouldRegenerate()
  for file in files:
    test file:
      let outcome = executeSnippetTest(basePath.path / file, format, testCase, regenerate)
      case outcome.kind
      of soPassed:
        discard
      of soFailed:
        checkpoint "Expected:\n" & outcome.expected & "\nActual:\n" & outcome.actual &
            "\nFirst difference on line " & $firstDifferentLine(outcome.expected, outcome.actual) & "."
        fail()
      of soGenerated:
        checkpoint "No expectation found. Generated one."
        fail()
