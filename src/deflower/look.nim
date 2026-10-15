## The tools that look at an input file without a .flo file: `--dump`
## (Dumper), `--find` (Finder) and `--strings` (TextFinder).

import std/[algorithm, os, sets, strutils, unicode]
import printing, loaders, subject

# Dumper: hex-dumps a memory range of a .vsf or .prg file (issue 0097): 16
# bytes a line, from the start of the range, then the bytes as PETSCII and
# as screen codes, to spot text. Both text columns read the bytes with the
# lower/upper character set and show every character that has a printable
# counterpart, graphics as dots. Memory the file doesn't load shows as `..`.

const
  bytesPerLine = 16
  screenCodes = toRunes("@abcdefghijklmnopqrstuvwxyz[£]↑← !\"#$%&'()*+,-./0123456789:;<=>?")
    ## The lower/upper character set's characters that have a printable
    ## counterpart, from screen code $00 to $3f; graphics are dots. The set
    ## holds lowercase letters at $01-$1a and uppercase at $41-$5a.
  noCharacter = Rune(0)
  minCharacters* = 6

proc javaParseInt(text: string, radix: int): int =
  ## The number in `text`, as Java's Integer.parseInt reads it.
  let problem = "For input string: \"" & text & "\"" & (if radix == 10: "" else: " under radix " & $radix)
  var position = 0
  var negative = false
  if text.len > 0 and text[0] in {'+', '-'}:
    negative = text[0] == '-'
    position = 1
  if position >= text.len:
    raise newException(ValueError, problem)
  var value = 0
  for character in text[position .. ^1]:
    let digit =
      if character in Digits: ord(character) - ord('0')
      elif character in {'a' .. 'z'}: ord(character) - ord('a') + 10
      elif character in {'A' .. 'Z'}: ord(character) - ord('A') + 10
      else: radix
    if digit >= radix:
      raise newException(ValueError, problem)
    value = value * radix + digit
    if value > 0x80000000:
      raise newException(ValueError, problem)
  if negative: -value
  elif value > 0x7fffffff: raise newException(ValueError, problem)
  else: value

proc number*(text: string): int =
  ## A number as in a .flo file: decimal, or hex after a `$`. Raises a
  ## ValueError, like Java's NumberFormatException.
  if text.startsWith("$"): javaParseInt(text[1 .. ^1], 16) else: javaParseInt(text, 10)

proc isRangeNumber(text: string): bool =
  if text.startsWith("$"):
    text.len > 1 and text[1 .. ^1].allCharsInSet(HexDigits)
  else:
    text.len > 0 and text.allCharsInSet(Digits)

proc range*(text: string): (int, int) =
  ## A range as in a .flo file, end exclusive: $c540-$c560 or 49472-49504.
  let dash = text.find('-')
  if dash < 0 or not isRangeNumber(text[0 ..< dash]) or not isRangeNumber(text[dash + 1 .. ^1]):
    raise newException(ArgumentError, "Not a range: " & text & ", expected e.g. $c540-$c560")
  var start, finish: int
  try:
    start = number(text[0 ..< dash])
    finish = number(text[dash + 1 .. ^1])
  except ValueError as e:
    raise newException(ArgumentError, e.msg)
  if start >= finish or finish > 0x10000:
    raise newException(ArgumentError, "Not a range inside $0000-$10000: " & text)
  (start, finish)

proc petsciiCharacter*(value: int): Rune =
  ## A PETSCII byte as the lower/upper character set shows it, or 0 for a
  ## control code or a graphic.
  if value >= 0x20 and value <= 0x3f:
    return screenCodes[value]
  if value >= 0x40 and value <= 0x5f:
    return screenCodes[value - 0x40]
  if value >= 0x61 and value <= 0x7a or value >= 0xc1 and value <= 0xda:
    return Rune((value and 0x1f) - 1 + ord('A'))
  if value == 0xa0 or value == 0xe0: Rune(ord(' ')) else: noCharacter

proc screenCodeCharacter*(value: int): Rune =
  ## A screen code as the lower/upper character set shows it, or 0 for a
  ## graphic or a reversed character.
  if value >= 0x80:
    return noCharacter
  if value < 0x40:
    return screenCodes[value]
  if value >= 0x41 and value <= 0x5a:
    return Rune(value - 0x41 + ord('A'))
  if value == 0x60: Rune(ord(' ')) else: noCharacter

proc orDot(character: Rune): string =
  if character == noCharacter: "." else: $character

proc dump*(file: string, image: ImageFile, rangeText: string): seq[string] =
  let (start, finish) = range(rangeText)
  let memory = readMemoryImage(file, image)
  var line = start
  while line < finish:
    var hex = asHexWord(line)[1 .. ^1] & ":"
    var petscii = ""
    var screenCode = ""
    for address in line ..< line + bytesPerLine:
      if address >= finish:
        hex.add "   "
        petscii.add ' '
      elif memory[address] < 0:
        hex.add " .."
        petscii.add ' '
        screenCode.add ' '
      else:
        let value = memory[address]
        hex.add " " & hexDigits(value, 2)
        petscii.add orDot(petsciiCharacter(value))
        screenCode.add orDot(screenCodeCharacter(value and 0x7f))
    result.add (hex & "  " & petscii & "  " & screenCode).strip(leading = false)
    line += bytesPerLine

# Finder: searches the memory of a .vsf or .prg file (issue 0099). A pattern
# of one number above $ff, or of one hex number with 3 or 4 digits, is an
# address: found as a little-endian word (`addr`), as the address minus one
# (`rta`, as an `rts` dispatch table holds it), and as its low and high byte
# at the same index in two tables at most 256 bytes apart (`lo/hi`). Any
# other pattern is a sequence of bytes. Memory the file doesn't load never
# matches.

const
  context = 8
  maxTableDistance = 256

proc findNumber(text: string): int =
  try:
    number(text)
  except ValueError:
    raise newException(ArgumentError, "Not a number: " & text & ", expected e.g. $c540 or $a9 $00")

proc isAddress(text: string): bool =
  (text.len in 4 .. 5 and text.startsWith("$") and text[1 .. ^1].allCharsInSet(HexDigits)) or
    not text.startsWith("$") and findNumber(text) > 0xff

proc byteValue(text: string): int =
  result = findNumber(text)
  if result > 0xff:
    raise newException(ArgumentError, "Not a byte: " & text & ", an address is searched for on its own")

proc matches(memory: seq[int], at, finish: int, bytes: openArray[int]): bool =
  if at + bytes.len > finish:
    return false
  for i in 0 ..< bytes.len:
    if memory[at + i] != bytes[i]:
      return false
  true

proc hit(memory: seq[int], at: int, kind: string): string =
  ## The address and kind of a hit, then the bytes from it on, as `--dump`
  ## prints them.
  result = asHexWord(at) & " " & kind.alignLeft(6)
  var address = at
  while address < at + context and address < memory.len:
    result.add(if memory[address] < 0: " .." else: " " & hexDigits(memory[address], 2))
    inc address

proc word(value: int): array[2, int] =
  [value and 0xff, value shr 8]

proc sameTable(memory: seq[int], bounds: (int, int), lo, distance, high: int): bool =
  let hi = lo + distance
  lo >= bounds[0] and hi < bounds[1] and memory[lo] >= 0 and memory[hi] >= 0 and abs(memory[hi] - high) <= 1

proc splitTables(memory: seq[int], bounds: (int, int), address: int): seq[string] =
  ## The low byte at `lo` and the high byte at `lo + distance`, for a
  ## distance of 2 to 256 (1 is a plain word). A neighbouring pair at the
  ## same distance has to look like an entry of the same table: its high
  ## byte within 1 of this one. Without that, any low byte with the high
  ## byte somewhere after it would match. A high byte table often repeats a
  ## byte, which matches at each distance, so one line lists the high bytes
  ## of a low byte, runs as ranges (end exclusive).
  let low = address and 0xff
  let high = address shr 8
  for lo in bounds[0] ..< bounds[1]:
    if memory[lo] != low:
      continue
    var highs: seq[string]
    var runStart = -1
    for distance in 2 .. maxTableDistance + 1:
      let hi = lo + distance
      let match = distance <= maxTableDistance and hi < bounds[1] and memory[hi] == high and
          (sameTable(memory, bounds, lo - 1, distance, high) or sameTable(memory, bounds, lo + 1, distance, high))
      if match and runStart < 0:
        runStart = hi
      elif not match and runStart >= 0:
        highs.add(if runStart == hi - 1: asHexWord(runStart) else: asHexWord(runStart) & "-$" & hexDigits(hi, 4))
        runStart = -1
    if highs.len > 0:
      result.add asHexWord(lo) & " lo/hi  high byte at " & highs.join(", ")

proc find*(file: string, image: ImageFile, pattern: seq[string], rangeText: string): seq[string] =
  ## `rangeText` is "" for all of memory.
  let bounds = if rangeText.len == 0: (0, 0x10000) else: range(rangeText)
  let memory = readMemoryImage(file, image)
  if pattern.len == 1 and isAddress(pattern[0]):
    let address = findNumber(pattern[0])
    if address > 0xffff:
      raise newException(ArgumentError, "Not an address: " & pattern[0])
    for at in bounds[0] ..< bounds[1]:
      if matches(memory, at, bounds[1], word(address)):
        result.add hit(memory, at, "addr")
      if matches(memory, at, bounds[1], word((address - 1) and 0xffff)):
        result.add hit(memory, at, "rta")
    result.add splitTables(memory, bounds, address)
    result.sort()
  else:
    var bytes: seq[int]
    for text in pattern:
      bytes.add byteValue(text)
    for at in bounds[0] ..< bounds[1]:
      if matches(memory, at, bounds[1], bytes):
        result.add hit(memory, at, "bytes")

# TextFinder: lists the stretches of memory of a .vsf or .prg file that read
# as text (issue 0100), in PETSCII (`ascii` in a .flo file) and in screen
# codes (`screencode`), with the characters `--dump` shows. A stretch has at
# least 6 characters besides spaces (or the minimum asked for), at least
# half of them letters and at least half of them different, with the
# letters in one case apart from a capital at the start of a word; spaces at
# either end are left out. Shorter or looser stretches are mostly bytes of
# code, tables and graphics. A stretch followed by $00 or $ff prints as
# `[until $xx]`, one preceded by its length as `[lengthbyte]`, so the line
# can be pasted into a .flo file. Reversed screen codes don't count: the
# `screencode` type can't print them.

type Decoder = proc (value: int): Rune {.nimcall.}

proc character(memory: seq[int], address: int, decode: Decoder): Rune =
  ## The character at this address, or 0 when it isn't text: unloaded, not
  ## a character, or `@`, which is the zero byte in screen codes.
  let character = if memory[address] < 0: noCharacter else: decode(memory[address])
  if character == Rune(ord('@')): noCharacter else: character

proc oneCase(text: seq[Rune]): bool =
  ## Whether the letters share one case, apart from a capital at the start
  ## of a word. Bytes of code and tables mix the cases at random.
  var lower = 0
  var upper = 0
  for i, character in text:
    let startOfWord = i == 0 or not text[i - 1].isAlpha
    if character.isLower:
      inc lower
    elif character.isUpper and not startOfWord:
      inc upper
  lower == 0 or upper == 0

proc text(memory: seq[int], first, last: int, bounds: (int, int), minimum: int, kind: string,
    decode: Decoder): string =
  ## The line for the stretch, or "" when it isn't text.
  var start = first
  var finish = last
  var trimmedEnd = false
  let space = Rune(ord(' '))
  while start < finish and character(memory, start, decode) == space:
    inc start
  while finish > start and character(memory, finish - 1, decode) == space:
    dec finish
    trimmedEnd = true
  var text: seq[Rune]
  var characters = 0
  var letters = 0
  var different = initHashSet[Rune]()
  for address in start ..< finish:
    let character = character(memory, address, decode)
    text.add character
    if character != space:
      inc characters
      different.incl character
    if character.isAlpha:
      inc letters
  if characters < minimum or letters * 2 < characters or different.len * 2 < characters or not oneCase(text):
    return ""
  let quoted = "\"" & $text & "\""
  if not trimmedEnd and finish < bounds[1] and (memory[finish] == 0x00 or memory[finish] == 0xff):
    return asHexWord(start) & " " & kind & "[until " & asHexByte(memory[finish]) & "]  " & quoted
  if start > bounds[0] and memory[start - 1] == finish - start:
    return asHexWord(start - 1) & " " & kind & "[lengthbyte]  " & quoted
  asHexWord(start) & "-$" & hexDigits(finish, 4) & " " & kind & "  " & quoted

proc findText(memory: seq[int], bounds: (int, int), minimum: int, kind: string, decode: Decoder,
    lines: var seq[string]) =
  var at = bounds[0]
  while at < bounds[1]:
    var finish = at
    while finish < bounds[1] and character(memory, finish, decode) != noCharacter:
      inc finish
    if finish > at:
      let line = text(memory, at, finish, bounds, minimum, kind, decode)
      if line.len > 0:
        lines.add line
      at = finish
    else:
      inc at

proc strings*(file: string, image: ImageFile, rangeText: string, minimum: int): seq[string] =
  ## `rangeText` is "" for all of memory.
  if minimum < 1:
    raise newException(ArgumentError, "Not a minimum length: " & $minimum)
  let bounds = if rangeText.len == 0: (0, 0x10000) else: range(rangeText)
  let memory = readMemoryImage(file, image)
  findText(memory, bounds, minimum, "ascii", petsciiCharacter, result)
  findText(memory, bounds, minimum, "screencode", screenCodeCharacter, result)
  result.sort()

# Running one of them.

proc takeOption(arguments: var seq[string], keyword: string): string =
  ## Removes "<keyword> <value>" from the end of the arguments, and returns
  ## the value, or "" when they don't end that way.
  let size = arguments.len
  if size < 2 or arguments[size - 2] != keyword:
    return ""
  result = arguments[size - 1]
  arguments.setLen(size - 2)

proc takeImage*(file: string, arguments: var seq[string]): ImageFile =
  ## The file with the "at", "from" and "size" options that come first in
  ## the arguments, as on a .flo file's deflower line (issue 0117); removes
  ## them from the arguments.
  result = imageFile(extractFilename(file))
  while arguments.len >= 2 and arguments[0] in ["at", "from", "size"]:
    var value: int
    try:
      value = number(arguments[1])
    except ValueError:
      raise newException(ArgumentError, "Not a number for " & arguments[0] & ": " & arguments[1])
    case arguments[0]
    of "at": result.address = value
    of "from": result.offset = value
    else: result.size = value
    arguments = arguments[2 .. ^1]

proc minimumLength(text: string): int =
  try:
    number(text)
  except ValueError:
    raise newException(ArgumentError, "Not a minimum length: " & text)

proc look*(flag, file: string, arguments: seq[string]): seq[string] =
  ## Runs a tool that looks at an input file without a .flo file: `--dump`,
  ## `--find` or `--strings`, with the arguments after the file. Bad
  ## arguments raise an ArgumentError.
  var rest = arguments
  let image = takeImage(file, rest)
  case flag
  of "--dump":
    if rest.len == 1:
      return dump(file, image, rest[0])
  of "--find":
    let range = takeOption(rest, "in")
    if rest.len > 0:
      return find(file, image, rest, range)
  of "--strings":
    let minimum = takeOption(rest, "min")
    if rest.len <= 1:
      return strings(file, image, if rest.len == 0: "" else: rest[0],
          if minimum.len == 0: minCharacters else: minimumLength(minimum))
  else:
    discard
  raise newException(ArgumentError, "Wrong arguments for " & flag & ": " & arguments.join(" "))
