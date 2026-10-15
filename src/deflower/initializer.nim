## Starts a disassembly: makes a .flo skeleton for a .vsf, .prg or .bin file
## (issue 0072), with what is of interest for disassembling it. The facts
## come as comments, then a `deflower` line, the code entries found, the
## memory that still holds VICE's power-on pattern or only zeroes, and the
## includes that match the banking.

import std/[bitops, options, os, strutils]
import printing, loaders, subject, vicevcf

const
  vectorNames = ["irq", "brk", "nmi", "open", "close", "chkin", "chkout", "clrchn",
      "chrin", "chrout", "stop", "getin", "clall", "user", "load", "save"]
    ## The KERNAL vectors at $0314-$0333, in order, and their defaults.
  vectorDefaults = [0xea31, 0xfe66, 0xfe47, 0xf34a, 0xf291, 0xf20e, 0xf250, 0xf333,
      0xf157, 0xf1ca, 0xf6ed, 0xf13e, 0xf32f, 0xfe66, 0xf4a5, 0xf5ed]
  chrget = 0x73
    ## CHRGET as the KERNAL copies it to $73; the bytes at $7a/$7b are its
    ## text pointer.
  chrgetDefault = [0xe6, 0x7a, 0xd0, 0x02, 0xe6, 0x7b, 0xad, -1, -1, 0xc9, 0x3a, 0xb0,
      0x0a, 0xc9, 0x20, 0xf0, 0xef, 0x38, 0xe9, 0x30, 0x38, 0xe9, 0xd0, 0x60]
  vicModes = ["text", "multicolor text", "bitmap", "multicolor bitmap",
      "extended color text", "invalid", "invalid", "invalid"]
  minPowerOnRun = 64
    ## The power-on pattern is only recognised in runs at least this long.
  minZeroRun = 256
    ## Zeroes inside a power-on run are a range of their own from this long
    ## on, longer than any period of the pattern.
  minRange = 16
    ## What is left of a run beside the zeroes in it is a range from this
    ## long on.
  minShare = 8
    ## A power-on run holds at least this share (1/n) of both $00 and $ff.

type Initializer = object
  lines: seq[string]
  codeEntries: seq[(int, string)]
    ## In the order they were found.
  rangeLines: seq[string]
  patternRanges: seq[(int, int)]
    ## The ranges in rangeLines that hold the power-on pattern or zeroes.
  memory: seq[int]
  basic, kernal, io, characterRom: bool

proc h(value, digits: int): string =
  ## `value` as Java's "%0<digits>x" prints it: a negative one as 32 bits.
  if value < 0: toLowerAscii(toHex(uint32(cast[uint32](int32(value)))))
  else: hexDigits(value, digits)

proc word(s: Initializer, address: int): int =
  ## The little-endian word here, or -1 when a byte of it isn't loaded.
  if address + 1 >= 0x10000 or s.memory[address] < 0 or s.memory[address + 1] < 0:
    return -1
  s.memory[address] or s.memory[address + 1] shl 8

proc isRam(s: Initializer, address: int): bool =
  if address >= 0xa000 and address < 0xc000:
    return not s.basic
  if address >= 0xd000 and address < 0xe000:
    return not s.io and not s.characterRom
  if address >= 0xe000:
    return not s.kernal
  true

proc where(s: Initializer, address: int): string =
  if not s.isRam(address):
    return "ROM"
  for range in s.patternRanges:
    if address >= range[0] and address < range[1]:
      return "RAM, untouched"
  "RAM"

proc codeEntry(s: var Initializer, address: int, label: string) =
  ## Adds a code entry, unless the address is in ROM, the zero page, the
  ## hardware vectors or memory the program never touched, like a vector
  ## left pointing into RAM under the KERNAL.
  if address >= 0x100 and address < 0xfffa and s.where(address) == "RAM":
    for entry in s.codeEntries:
      if entry[0] == address:
        return
    s.codeEntries.add (address, label)

proc sysAddress(s: Initializer, start, to: int): int =
  ## The number after the first SYS token between these addresses, or -1.
  var address = start
  while address < to and address < 0x10000:
    if s.memory[address] == 0x9e:
      var number = -1
      inc address
      while address < to and address < 0x10000:
        let c = s.memory[address]
        if c >= ord('0') and c <= ord('9'):
          number = (if number < 0: 0 else: number * 10) + c - ord('0')
        elif c != ord(' ') and c != ord('(') or number >= 0:
          break
        inc address
      return if number >= 0 and number < 0x10000: number else: -1
    inc address
  -1

proc basicStub(s: Initializer, start: int): Option[(int, int)] =
  ## The end of the BASIC program at `start` and the address its first line
  ## SYSes to, or none when it has no such line.
  var line = start
  var sys = -1
  for lineCount in 0 ..< 100:
    let link = s.word(line)
    if link < 0:
      return none((int, int))
    if link == 0:
      return if sys < 0: none((int, int)) else: some((line + 2, sys))
    if link <= line:
      return none((int, int))
    if lineCount == 0:
      sys = s.sysAddress(line + 4, link)
      if sys < 0:
        return none((int, int))
    line = link
  none((int, int))

proc readProgram(s: var Initializer, file: string, image: ImageFile) =
  s.memory = readMemoryImage(file, image)
  let (load, bytes) = imageBytes(file, image)
  let finish = load + bytes.len
  s.lines.add "; " & image.name & ": loads at $" & h(load, 4) & "-$" & h(finish, 4)
  if finish > 0x10000:
    s.lines.add "; the load runs past $ffff"
  let stub = s.basicStub(load)
  if stub.isSome:
    s.lines.add "; BASIC stub: SYS " & $stub.get[1]
    s.rangeLines.add "$" & h(load, 4) & "-$" & h(stub.get[0], 4) & " byte basic_stub"
    s.codeEntries.add (stub.get[1], "start")

proc stack(s: var Initializer, sp: int) =
  if sp == 0xff:
    s.lines.add "; the stack is empty"
    return
  var bytes: seq[string]
  for address in 0x100 + sp + 1 ..< min(0x200, 0x100 + sp + 17):
    bytes.add h(s.memory[address], 2)
  s.lines.add "; stack $" & h(0x100 + sp + 1, 4) & "-$0200: " & bytes.join(" ") & (if sp < 0xef: " ..." else: "")
  if sp <= 0xfd:
    s.lines.add "; top of stack as a jsr return address: $" & h((s.word(0x100 + sp + 1) + 1) and 0xffff, 4)
  if sp <= 0xfc:
    s.lines.add "; top of stack as an interrupt's return address: $" & h(s.word(0x100 + sp + 2), 4)

proc vectors(s: var Initializer) =
  var changed: seq[string]
  for i in 0 ..< vectorNames.len:
    let vector = 0x314 + 2 * i
    let target = s.word(vector)
    let line = vectorNames[i].toUpperAscii & " $" & h(vector, 4) & " -> $" & h(target, 4) & " (" & s.where(target) & ")"
    if i < 3:
      s.lines.add "; " & line
    elif target != vectorDefaults[i]:
      changed.add line
    if i < 3 or target != vectorDefaults[i]:
      s.codeEntry(target, if i < 3: vectorNames[i] else: vectorNames[i] & "_handler")
  if changed.len > 0:
    s.lines.add "; changed KERNAL vectors: " & changed.join(", ")
  if not s.kernal:
    const names = ["NMI", "reset", "IRQ"]
    const labels = ["hardware_nmi", "reset", "hardware_irq"]
    var hardware: seq[string]
    for i in 0 ..< 3:
      let target = s.word(0xfffa + 2 * i)
      hardware.add names[i] & " $" & h(target, 4) & " (" & s.where(target) & ")"
      s.codeEntry(target, labels[i])
    s.lines.add "; hardware vectors in RAM at $fffa: " & hardware.join(", ")

proc unread(file: ViceVcfFile, moduleTypes: varargs[string]): string =
  ## The modules of these that no handler read, with their versions, like
  ## "VIC-II 1.1".
  var unread: seq[string]
  for module in file.modules:
    if module.kind == mkUnhandled and module.moduleType in moduleTypes:
      unread.add module.moduleType & " " & $module.version.major & "." & $module.version.minor
  unread.join(", ")

proc video(s: var Initializer, file: ViceVcfFile) =
  let vic = file.module("VIC-II", mkVicII)
  let cia2 = file.module("CIA2", mkCia)
  if vic.isNone or cia2.isNone:
    s.lines.add "; video unknown: " & unread(file, "VIC-II", "CIA2") & " isn't read"
    return
  let r = vic.get.registers
  let bankNumber = 3 - ((cia2.get.portA or not cia2.get.directionA) and 3)
  let bank = bankNumber * 0x4000
  let mode = (r[0x11] shr 4 and 2) or (r[0x16] shr 4 and 1) or (r[0x11] shr 4 and 4)
  let screen = bank + (r[0x18] shr 4) * 0x400
  var line = "; VIC bank " & $bankNumber & " ($" & h(bank, 4) & "-$" & h(bank + 0x3fff, 4) & "), " &
      vicModes[mode] & ", screen $" & h(screen, 4)
  if (r[0x11] and 0x20) != 0:
    line.add ", bitmap $" & h(bank + (r[0x18] and 8) * 0x400, 4)
  else:
    let charset = (r[0x18] and 0xe) * 0x400
    let rom = (bankNumber and 1) == 0 and (charset == 0x1000 or charset == 0x1800)
    line.add ", charset $" & h(bank + charset, 4) & (if rom: " (ROM)" else: "")
  if (r[0x11] and 0x10) == 0:
    line.add ", display off"
  s.lines.add line
  if r[0x15] != 0:
    var sprites: seq[string]
    for i in 0 ..< 8:
      if (r[0x15] and 1 shl i) != 0:
        sprites.add $i & " $" & h(bank + s.memory[screen + 0x3f8 + i] * 0x40, 4)
    s.lines.add "; sprites on, pointers at $" & h(screen + 0x3f8, 4) & ": " & sprites.join(", ")

proc interrupts(s: var Initializer, file: ViceVcfFile, cpu: Option[Module]) =
  var sources: seq[string]
  let vic = file.module("VIC-II", mkVicII)
  if vic.isSome:
    let r = vic.get.registers
    let vicSources = ["raster at line $" & h(r[0x12] or (r[0x11] and 0x80) shl 1, 3),
        "sprite-background collision", "sprite-sprite collision", "light pen"]
    for i in 0 ..< vicSources.len:
      if (r[0x1a] and 1 shl i) != 0:
        sources.add "VIC " & vicSources[i]
  const ciaSources = ["timer A", "timer B", "TOD alarm", "serial port", "FLAG line"]
  for ciaName in ["CIA1", "CIA2"]:
    let cia = file.module(ciaName, mkCia)
    if cia.isSome:
      for i in 0 ..< ciaSources.len:
        if (cia.get.interruptMask and 1 shl i) != 0:
          sources.add ciaName & " " & ciaSources[i] & " (" & (if ciaName == "CIA1": "IRQ" else: "NMI") & ")"
  let masked = if cpu.isSome and (cpu.get.status and 4) != 0: ", IRQs masked by the I flag" else: ""
  let unknown = unread(file, "VIC-II", "CIA1", "CIA2")
  s.lines.add "; interrupt sources: " & (if sources.len == 0: "none" else: sources.join(", ")) & masked &
      (if unknown.len == 0: "" else: ", unknown for " & unknown)

proc basicProgram(s: var Initializer) =
  let start = s.word(0x2b)
  let finish = s.word(0x2d)
  var line = "; BASIC program $" & h(start, 4) & "-$" & h(finish, 4)
  let stub = s.basicStub(start)
  if stub.isSome:
    line.add ", SYS " & $stub.get[1] & " ($" & h(stub.get[1], 4) & ")"
  s.lines.add line

proc chrgetPatch(s: var Initializer) =
  var patched = false
  for i in 0 ..< chrgetDefault.len:
    if chrgetDefault[i] >= 0 and s.memory[chrget + i] != chrgetDefault[i]:
      patched = true
  if not patched:
    return
  if s.memory[chrget] == 0x4c:
    let target = s.word(chrget + 1)
    s.lines.add "; CHRGET at $" & h(chrget, 4) & " patched: jmp $" & h(target, 4)
    s.codeEntry(target, "chrget_patch")
  else:
    s.lines.add "; CHRGET at $" & h(chrget, 4) & " differs from the KERNAL's"

proc exactPattern(s: Initializer, address: int): bool =
  s.memory[address] == 0 or s.memory[address] == 0xff

proc inPattern(s: Initializer, address: int): bool =
  ## $00 or $ff, or one bit off from it next to one that is: VICE flips a
  ## bit now and then, but a run of values with one bit set, like a screen
  ## of spaces, isn't the pattern.
  if s.exactPattern(address):
    return true
  let bits = popcount(uint32(cast[uint32](int32(s.memory[address]))))
  (bits == 1 or bits == 7) and
    (address > 0 and s.exactPattern(address - 1) or address < 0xffff and s.exactPattern(address + 1))

proc noise(s: Initializer, start, address: int): bool =
  ## Any byte between two exact ones, in a run already long enough: VICE
  ## sets a byte at random now and then, which shouldn't split a long run
  ## of the pattern (issue 0103).
  address - start >= minPowerOnRun and address < 0xffff and
    s.exactPattern(address - 1) and s.exactPattern(address + 1)

proc balanced(s: Initializer, start, finish: int): bool =
  ## Whether the run holds enough of both $00 and $ff to be the power-on
  ## pattern: mostly zeroes with a few other bytes is more likely sparse
  ## data, like a sprite (issue 0103).
  var zeroes = 0
  var ones = 0
  for address in start ..< finish:
    if s.memory[address] == 0:
      inc zeroes
    elif s.memory[address] == 0xff:
      inc ones
  let least = (finish - start) div minShare
  zeroes >= least and ones >= least

proc addRange(s: var Initializer, start, finish: int, kind: string) =
  if finish - start >= minRange:
    s.patternRanges.add (start, finish)
    s.rangeLines.add "$" & h(start, 4) & "-$" & h(finish, 4) & " virtual byte " & kind & "_" & h(start, 4)

proc zeroes(s: var Initializer, start, finish: int) =
  ## Adds the runs of only zeroes in the run as unused.
  var address = start
  while address < finish:
    if s.memory[address] != 0:
      inc address
      continue
    let zeroes = address
    while address < finish and s.memory[address] == 0:
      inc address
    if address - zeroes >= minPowerOnRun:
      s.addRange(zeroes, address, "unused")

proc splitZeroes(s: var Initializer, start, finish: int) =
  ## Adds the run as untouched, apart from the long runs of zeroes in it.
  var untouched = start
  var address = start
  while address < finish:
    if s.memory[address] != 0:
      inc address
      continue
    let zeroes = address
    while address < finish and s.memory[address] == 0:
      inc address
    let wholeRun = zeroes == start and address == finish
    if wholeRun or address - zeroes >= minZeroRun:
      s.addRange(untouched, zeroes, "untouched")
      s.addRange(zeroes, address, "unused")
      untouched = address
  s.addRange(untouched, finish, "untouched")

proc powerOnPattern(s: var Initializer, start, to: int) =
  var address = start
  while address < to:
    if not s.inPattern(address):
      inc address
      continue
    var first = address
    var finish = address
    while finish < to and (s.inPattern(finish) or s.noise(first, finish)):
      inc finish
    address = finish + 1
    # A byte one bit off at an edge may as well be the neighbour's data
    # (issue 0103).
    while first < finish and not s.exactPattern(first):
      inc first
    while finish > first and not s.exactPattern(finish - 1):
      dec finish
    if finish - first < minPowerOnRun:
      continue
    if s.balanced(first, finish):
      s.splitZeroes(first, finish)
    else:
      s.zeroes(first, finish)

proc powerOnPattern(s: var Initializer) =
  ## Adds a line for each range that still holds VICE's power-on pattern
  ## (runs of $00 and $ff, with now and then a flipped bit) or only zeroes.
  ## Memory below $0400 belongs to the system and is left out, like the I/O
  ## area while I/O is banked in and the hardware vectors while the KERNAL
  ## is banked out. Ranges end where a visible ROM starts, so they don't
  ## cover its labels.
  var bounds = @[0x400]
  if s.basic:
    bounds.add [0xa000, 0xc000]
  if s.io or s.characterRom:
    bounds.add [0xd000, 0xe000]
  elif s.kernal:
    bounds.add 0xe000
  if not s.kernal:
    bounds.add 0xfffa
  bounds.add 0x10000
  for i in 0 ..< bounds.len - 1:
    let start = bounds[i]
    if not (start == 0xd000 and (s.io or s.characterRom)) and start != 0xfffa:
      s.powerOnPattern(start, bounds[i + 1])

proc readSnapshot(s: var Initializer, file, name: string) =
  let vcfFile = readSnapshot(file)
  let c64Memory = vcfFile.memory
  s.memory = newSeq[int](0x10000)
  for i in 0 ..< 0x10000:
    s.memory[i] = int(c64Memory.ram[i])
  s.lines.add "; " & name & ": VICE snapshot of a " & vcfFile.header.machineName

  let cpu = vcfFile.module("MAINCPU", mkMainCpu)
  let port = (c64Memory.cpuData or not c64Memory.cpuDir) and 7
  let loram = (port and 1) != 0
  let hiram = (port and 2) != 0
  let charen = (port and 4) != 0
  s.basic = loram and hiram
  s.kernal = hiram
  s.io = (loram or hiram) and charen
  s.characterRom = (loram or hiram) and not charen
  s.lines.add "; $01 = $" & h(c64Memory.cpuData, 2) & ": BASIC " & (if s.basic: "in" else: "out") &
      ", KERNAL " & (if s.kernal: "in" else: "out") & ", " &
      (if s.io: "I/O in" elif s.characterRom: "character ROM in" else: "I/O out")
  s.powerOnPattern()

  if cpu.isSome:
    let c = cpu.get
    s.lines.add "; CPU: PC $" & h(c.pc, 4) & " A $" & h(c.a, 2) & " X $" & h(c.x, 2) & " Y $" & h(c.y, 2) &
        " SP $" & h(c.sp, 2) & " P $" & h(c.status, 2)
    if s.isRam(c.pc):
      s.codeEntry(c.pc, "snapshot_pc")
    else:
      s.lines.add "; the PC is in ROM"
    s.stack(c.sp)
  else:
    s.lines.add "; CPU state unknown: " & unread(vcfFile, "MAINCPU") & " isn't read"

  s.vectors()
  s.video(vcfFile)
  s.interrupts(vcfFile, cpu)
  s.basicProgram()
  s.chrgetPatch()

proc text(image: ImageFile): string =
  ## The file with its options, as a deflower line takes them.
  result = image.name
  if image.address != -1:
    result.add " at $" & h(image.address, 4)
  if image.offset != -1:
    result.add " from $" & hex(image.offset)
  if image.size != -1:
    result.add " size $" & hex(image.size)

proc skeleton*(file: string, image: ImageFile): seq[string] =
  ## The skeleton for this file, loaded with the options of `image`, one
  ## line per element.
  var s = Initializer(basic: true, kernal: true, io: true)
  discard readMemoryImage(file, image)
  if image.name.isSnapshot:
    s.readSnapshot(file, image.name)
  else:
    s.readProgram(file, image)
  s.lines.add "deflower " & image.text
  for (address, label) in s.codeEntries:
    s.lines.add "$" & h(address, 4) & " code " & label
  s.lines.add s.rangeLines
  if s.basic and s.kernal and s.io:
    s.lines.add "include c64.flo"
  else:
    s.lines.add "include c64_zeropage.flo"
    s.lines.add "include c64_system.flo"
    if s.basic:
      s.lines.add "include c64_basic.flo"
    if s.io:
      s.lines.add "include c64_io.flo"
    if s.kernal:
      s.lines.add "include c64_kernal.flo"
  s.lines

proc skeleton*(file: string): seq[string] =
  ## The skeleton for this file without options.
  skeleton(file, imageFile(extractFilename(file)))

proc writeSkeleton*(file: string, image: ImageFile): bool =
  ## Writes the skeleton as `<name>.flo` next to the file, unless that
  ## exists. Returns false when it does.
  let name = extractFilename(file)
  let dot = name.rfind('.')
  let flowerName = (if dot >= 0: name[0 ..< dot] else: name) & ".flo"
  let directory = splitPath(file).head
  let flowerFile = if directory.len == 0: flowerName else: directory / flowerName
  if fileExists(flowerFile):
    printErr(flowerFile & " already exists, not overwriting it.")
    return false
  var text = ""
  for line in skeleton(file, image):
    text.add line & "\n"
  printOut("Writing " & flowerFile)
  writeFile(flowerFile, text)
  true
