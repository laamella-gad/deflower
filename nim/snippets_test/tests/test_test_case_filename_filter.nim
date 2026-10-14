import std/unittest
import snippets_test

suite "test case filename filter":
  test "all files":
    let filter = allFiles()
    check filter("/a/b/c")
    check filter("c.txt")

  test "extension with a dot":
    let koeFilter = filesWithExtension(".koe")
    check koeFilter("/a/b/c.koe")
    check not koeFilter("koe")

  test "extension without a dot":
    let koeFilter = filesWithExtension("koe")
    check koeFilter("/a/b/c.koe")
    # A leading dot is enforced.
    check not koeFilter("koe")
