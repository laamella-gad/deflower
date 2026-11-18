## Loads the files of a run into a Subject: the 64K RAM of a VICE snapshot,
## a .prg at its load address, a .bin at a given one (issue 0083); and reads
## one without a Subject, for the tools that look at a file without a .flo
## file.

import std/[options, os, strutils]
import printing, subject, vicevcf

proc readBytes(path: string): seq[byte] =
  if not fileExists(path):
    raise newException(StateError, "No such file: " & extractFilename(path))
  cast[seq[byte]](readFile(path))

proc kind(name: string): string =
  name.toLowerAscii.splitFile.ext

proc isSnapshot*(name: string): bool =
  name.kind == ".vsf"

proc imageFile*(name: string): ImageFile =
  ## A file without options.
  ImageFile(name: name, address: -1, first: -1, last: -1)

proc imageProblem*(image: ImageFile, loaded: bool): string =
  ## What is wrong with loading this file with these options, or "": a .vsf
  ## as it is and only as the main file, a .prg at its own address or the
  ## 'at' one, a .bin 'at' an address, a part of either (issue 0133).
  ## `loaded` for a file loaded on top of the main one.
  let kind = image.name.kind
  if image.problem.len > 0:
    image.problem
  elif kind notin [".vsf", ".prg", ".bin"]:
    "can't load " & image.name & ": not a .vsf, .prg or .bin file"
  elif kind == ".vsf" and loaded:
    "can't load a snapshot on top, only on the deflower line"
  elif kind == ".vsf" and image.address != -1:
    "a .vsf loads where it was, without at"
  elif kind == ".vsf" and image.first != -1 and (image.first shr 16) != (max(image.last, image.first + 1) - 1) shr 16:
    "a part of a .vsf is in one bank: $" & hex(image.first) & "-$" & hex(image.last) & " isn't"
  elif kind == ".bin" and image.address == -1:
    image.name & " needs at <address>: a .bin has no load address"
  elif image.address > 0xffff:
    "at $" & hex(image.address) & " is past $ffff"
  elif image.last != -1 and image.last <= image.first:
    "the part $" & hex(image.first) & "-$" & hex(image.last) & " is empty"
  else:
    ""

proc loadAddress*(prg: openArray[byte]): int =
  int(prg[0]) or int(prg[1]) shl 8

proc imageBytes*(path: string, image: ImageFile): tuple[address: int, bytes: seq[byte]] =
  ## Where a .prg or .bin file loads, and the bytes it loads there. Raises a
  ## StateError when the file is too short for that.
  let bytes = readBytes(path)
  let name = image.name
  if name.kind == ".bin":
    let first = max(image.first, 0)
    let last = if image.last == -1: bytes.len else: image.last
    if first >= bytes.len or last > bytes.len:
      raise newException(StateError, name & " has $" & hex(bytes.len) & " bytes, too few for $" & hex(first) &
          "-$" & hex(last))
    return (image.address, bytes[first ..< last])
  if bytes.len < 2:
    raise newException(StateError, name & " has no load address.")
  let load = loadAddress(bytes)
  if image.first == -1:
    return ((if image.address == -1: load else: image.address), bytes[2 .. ^1])
  # Issue 0133: the part in a range of its addresses, at 'at' or where it is.
  let finish = load + bytes.len - 2
  let last = if image.last == -1: finish else: image.last
  if image.first < load or last > finish:
    raise newException(StateError, name & " loads at $" & hexDigits(load, 4) & "-$" & hexDigits(finish, 4) &
        ", not all of $" & hexDigits(image.first, 4) & "-$" & hexDigits(last, 4))
  ((if image.address == -1: image.first else: image.address), bytes[2 + image.first - load ..< 2 + last - load])

proc readSnapshot*(file: string): ViceVcfFile =
  ## Reads the snapshot, with the modules Deflower knows: memory, CPU,
  ## VIC-II and CIAs.
  result = readVcf(readBytes(file))
  if result.header.machineName notin ["C64", "C64SC", "C128"]:
    raise newException(ArgumentError, "Only C64 and C128 snapshots are supported.")

proc isC128*(file: ViceVcfFile): bool =
  file.header.machineName == "C128"

proc memory*(file: ViceVcfFile): Module =
  let module = file.module("C64MEM", mkC64Mem)
  if module.isNone:
    raise newException(ArgumentError, "No C64MEM found.")
  module.get

proc c128Memory*(file: ViceVcfFile): Module =
  let module = file.module("C128MEM", mkC128Mem)
  if module.isNone or module.get.banks.len < 2:
    raise newException(ArgumentError, "No C128MEM found.")
  module.get

proc sharedRam*(mmu: Module): seq[Slice[int]] =
  ## The RAM all banks share, which is bank 0's, as the MMU's RAM
  ## configuration register ($d506) sets it: 1K, 4K, 8K or 16K at the
  ## bottom, the top or both.
  let rcr = mmu.mmu[6]
  let size = [0x400, 0x1000, 0x2000, 0x4000][rcr and 3]
  if (rcr and 4) != 0:
    result.add 0 ..< size
  if (rcr and 8) != 0:
    result.add 0x10000 - size ..< 0x10000

proc bank*(image: ImageFile): int =
  ## The bank a snapshot's part is in: its address above the low 16 bits.
  max(image.first, 0) shr 16

proc ram*(file: ViceVcfFile, bank: int): seq[byte] =
  ## The 64K a snapshot run loads: a C64's RAM, or a C128's bank as the CPU
  ## sees it (issue 0132): bank 1 with the shared RAM from bank 0.
  if not file.isC128:
    if bank > 0:
      raise newException(StateError, "bank " & $bank & ": a C64 snapshot has one 64K bank")
    return file.memory.ram
  if bank > 1:
    raise newException(StateError, "bank " & $bank & ": a C128 has RAM banks 0 and 1")
  let memory = file.c128Memory
  result = memory.banks[bank]
  if bank == 1:
    for shared in memory.sharedRam:
      for address in shared:
        result[address] = memory.banks[0][address]

proc loadImage*(path: string, image: ImageFile, subject: Subject) =
  ## Loads the file at `path`, which `image` names, into the subject's
  ## memory.
  if image.name.isSnapshot:
    let ram = readSnapshot(path).ram(image.bank)
    let first = max(image.first, 0) and 0xffff
    let last = if image.last == -1: 0x10000 else: ((image.last - 1) and 0xffff) + 1
    subject.storeAt(first, ram[first ..< last], image.name)
  else:
    let (address, bytes) = imageBytes(path, image)
    subject.storeAt(address, bytes, image.name)
    subject.loadedFiles.add LoadedFile(name: image.name, start: address, finish: address + bytes.len,
        plainPrg: image.name.kind == ".prg" and image.address == -1 and image.first == -1)

proc readMemoryImage*(file: string, image: ImageFile): seq[int] =
  ## The 64K the file loads with the options of `image`, as values 0-255,
  ## with -1 for memory it doesn't load. Bytes past $ffff are dropped. Raises
  ## an ArgumentError when the file is missing or the options don't fit it.
  let problem = imageProblem(image, false)
  if problem.len > 0:
    raise newException(ArgumentError, problem)
  result = newSeq[int](0x10000)
  try:
    if image.name.isSnapshot:
      let ram = readSnapshot(file).ram(image.bank)
      let first = max(image.first, 0) and 0xffff
      let last = if image.last == -1: 0x10000 else: ((image.last - 1) and 0xffff) + 1
      for i in 0 ..< result.len:
        result[i] = if i >= first and i < last: int(ram[i]) else: -1
      return
    for i in 0 ..< result.len:
      result[i] = -1
    let (address, bytes) = imageBytes(file, image)
    for i in 0 ..< min(bytes.len, 0x10000 - address):
      result[address + i] = int(bytes[i])
  except StateError as e:
    raise newException(ArgumentError, e.msg)

proc readMemoryImage*(file: string): seq[int] =
  ## The 64K a .vsf or .prg file loads.
  readMemoryImage(file, imageFile(extractFilename(file)))
