import std/[os, strutils, unittest]
import snippets_test

let format = snippetFileFormat(">>>", "<<<\n", "", "\n^^^\n", "\n---\n", "\nvvv\n")

suite "snippet test factory":
  runSnippetTests(format, fromSourceDirectory().inSubDirectory("resources/test1"), allFiles(),
      simpleTestCase(proc (input: string): string = input.toUpperAscii))

# The ways a snippet test can go, run in a temporary directory, so a failing
# snippet doesn't fail these tests.

let tmp = getTempDir() / "snippets_test_" & $getCurrentProcessId()
let upperCase = simpleTestCase(proc (input: string): string = input.toUpperAscii)
let multiFormat = snippetFileFormat(">>>", "<<<\n", "\n===\n", "\n^^^\n", "\n~~~\n", "\nvvv\n")

proc snippet(name, content: string): string =
  result = tmp / name
  createDir(result.parentDir)
  writeFile(result, content)

suite "snippet test":
  setup:
    createDir(tmp)
  teardown:
    removeDir(tmp)

  test "matching expectations pass":
    let file = snippet("a.txt", "hi\n^^^\nHI\nvvv\n")
    let outcome = executeSnippetTest(file, format, upperCase, regenerate = false)
    check outcome.kind == soPassed

  test "other expectations fail":
    let file = snippet("a.txt", "hi\n^^^\nHO\nvvv\n")
    let outcome = executeSnippetTest(file, format, upperCase, regenerate = false)
    check outcome.kind == soFailed
    check outcome.expected == "HO"
    check outcome.actual == "HI"
    check readFile(file) == "hi\n^^^\nHO\nvvv\n"

  test "missing expectations are generated":
    let file = snippet("a.txt", ">>> about hi <<<\nhi")
    let outcome = executeSnippetTest(file, format, upperCase, regenerate = false)
    check outcome.kind == soGenerated
    check outcome.actual == "HI"
    check readFile(file) == ">>> about hi <<<\nhi\n^^^\nHI\nvvv\n"

  test "regenerating rewrites the expectations":
    let file = snippet("a.txt", "hi\n^^^\nHO\nvvv\n")
    let outcome = executeSnippetTest(file, format, upperCase, regenerate = true)
    check outcome.kind == soGenerated
    check readFile(file) == "hi\n^^^\nHI\nvvv\n"

  test "several inputs and outputs":
    let file = snippet("a.txt", "a\n===\nb\n^^^\nb\n~~~\na\nvvv\n")
    let reverse = proc (parts: seq[string]): seq[string] = @[parts[1], parts[0]]
    check readSnippetTestFile(file, multiFormat).testCaseParts == @["a", "b"]
    check executeSnippetTest(file, multiFormat, reverse, regenerate = false).kind == soPassed

  test "multi input and multi output test cases":
    let file = snippet("a.txt", "a\n===\nb\n^^^\nab\nvvv\n")
    let joined = multiInputTestCase(proc (inputs: seq[string]): string = inputs.join)
    check executeSnippetTest(file, multiFormat, joined, regenerate = false).kind == soPassed
    let other = snippet("b.txt", "ab\n^^^\nab\n~~~\nAB\nvvv\n")
    let both = multiOutputTestCase(proc (input: string): seq[string] = @[input, input.toUpperAscii])
    check executeSnippetTest(other, multiFormat, both, regenerate = false).kind == soPassed

  test "an error's message is the actual output":
    let file = snippet("a.txt", "hi\n^^^\nbroken\nvvv\n")
    let failing = simpleTestCase(proc (input: string): string = raise newException(ValueError, "broken"))
    check executeSnippetTest(file, format, failing, regenerate = false).kind == soPassed

  test "a simple test case takes one input":
    let file = snippet("a.txt", "a\n===\nb\n^^^\nA\nvvv\n")
    expect SnippetTestFailure:
      discard executeSnippetTest(file, multiFormat, upperCase, regenerate = false)
    try:
      discard executeSnippetTest(file, multiFormat, upperCase, regenerate = false)
    except SnippetTestFailure as e:
      check e.msg == "Simple test case should have only one input, got 2"

  test "a description needs its end":
    let file = snippet("a.txt", ">>> about hi\nhi\n^^^\nHI\nvvv\n")
    try:
      discard readSnippetTestFile(file, format)
      fail()
    except SnippetTestFailure as e:
      check e.msg == "Starting description has no ending."

  test "the files are found in subdirectories, filtered and sorted":
    discard snippet("b.txt", "")
    discard snippet("a/c.txt", "")
    discard snippet("a/d.other", "")
    check snippetTestFiles(fromPath(tmp), filesWithExtension("txt")) == @["a" / "c.txt", "b.txt"]

  test "a missing directory is created and fails":
    let missing = tmp / "missing"
    try:
      discard snippetTestFiles(fromPath(missing), allFiles())
      fail()
    except SnippetTestFailure as e:
      check e.msg == "Created new testcases directory in " & missing
    check dirExists(missing)
