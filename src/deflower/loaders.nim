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
  ImageFile(name: name, address: -1, offset: -1, size: -1)

proc imageProblem*(image: ImageFile, loaded: bool): string =
  ## What is wrong with loading this file with these options, or "": a .vsf
  ## as it is and only as the main file, a .prg at its own address or the
  ## 'at' one, a .bin 'at' an address, 'from' and 'size' picking a part of
  ## it. `loaded` for a file loaded on top of the main one.
  let kind = image.name.kind
  if kind notin [".vsf", ".prg", ".bin"]:
    "can't load " & image.name & ": not a .vsf, .prg or .bin file"
  elif kind == ".vsf" and loaded:
    "can't load a snapshot on top, only on the deflower line"
  elif kind == ".vsf" and (image.address != -1 or image.offset != -1 or image.size != -1):
    "a .vsf takes no at, from or size"
  elif kind == ".bin" and image.address == -1:
    image.name & " needs at <address>: a .bin has no load address"
  elif kind == ".prg" and (image.offset != -1 or image.size != -1):
    "from and size are for a .bin, not a .prg"
  elif image.address > 0xffff:
    "at $" & hex(image.address) & " is past $ffff"
  elif image.size == 0:
    "size 0 loads nothing"
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
    let offset = max(image.offset, 0)
    let size = if image.size == -1: bytes.len - offset else: image.size
    if offset > bytes.len or offset + size > bytes.len:
      raise newException(StateError, name & " has $" & hex(bytes.len) & " bytes, too few for from $" & hex(offset) &
          " size $" & hex(size))
    (image.address, bytes[offset ..< offset + size])
  else:
    if bytes.len < 2:
      raise newException(StateError, name & " has no load address.")
    ((if image.address == -1: loadAddress(bytes) else: image.address), bytes[2 .. ^1])

proc readSnapshot*(c64File: string): ViceVcfFile =
  ## Reads the snapshot, with the modules Deflower knows: memory, CPU,
  ## VIC-II and CIAs.
  result = readVcf(readBytes(c64File))
  if result.header.machineName notin ["C64", "C64SC"]:
    raise newException(ArgumentError, "Only C64 dumps supported.")

proc memory*(file: ViceVcfFile): Module =
  let module = file.module("C64MEM", mkC64Mem)
  if module.isNone:
    raise newException(ArgumentError, "No C64MEM found.")
  module.get

proc loadImage*(path: string, image: ImageFile, subject: Subject) =
  ## Loads the file at `path`, which `image` names, into the subject's
  ## memory.
  if image.name.isSnapshot:
    subject.storeAt(0, readSnapshot(path).memory.ram, image.name)
  else:
    let (address, bytes) = imageBytes(path, image)
    subject.storeAt(address, bytes, image.name)

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
      let ram = readSnapshot(file).memory.ram
      for i in 0 ..< result.len:
        result[i] = int(ram[i])
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
