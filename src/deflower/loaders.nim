## Loads a memory image into a Subject: a `.prg` file (PrgReader) or the
## 64K RAM of a VICE snapshot (ViceSnapshotReader); and reads one without a
## Subject, for the tools that look at an input file without a `.flo` file
## (MemoryImage).

import std/[options, os, strutils]
import printing, subject, vicevcf

proc readBytes(path: string): seq[byte] =
  cast[seq[byte]](readFile(path))

proc readPrg*(c64File: string, subject: Subject) =
  ## Loads a .prg file (2-byte load address, then the bytes) at its load
  ## address.
  let bytes = readBytes(c64File)
  if bytes.len < 2:
    raise newException(StateError, relativePath(c64File, subject.basePath) & " has no load address.")
  let loadAddress = int(bytes[0]) + 256 * int(bytes[1])
  subject.storeAt(loadAddress, bytes.toOpenArray(2, bytes.high), relativePath(c64File, subject.basePath))

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

proc readViceSnapshot*(c64File: string, subject: Subject) =
  ## Loads the 64K RAM of a VICE snapshot.
  subject.storeAt(0, readSnapshot(c64File).memory.ram, relativePath(c64File, subject.basePath))

proc fromPrg(file: string): seq[int] =
  ## A .prg: the load address, then the bytes. Bytes past $ffff are dropped.
  let prg = readBytes(file)
  if prg.len < 2:
    raise newException(ArgumentError, extractFilename(file) & " has no load address.")
  let load = int(prg[0]) or int(prg[1]) shl 8
  result = newSeq[int](0x10000)
  for i in 0 ..< result.len:
    result[i] = -1
  var i = 2
  while i < prg.len and load + i - 2 < result.len:
    result[load + i - 2] = int(prg[i])
    inc i

proc loadAddress*(prg: openArray[byte]): int =
  int(prg[0]) or int(prg[1]) shl 8

proc readMemoryImage*(file: string): seq[int] =
  ## The 64K a .vsf or .prg file loads, as values 0-255, with -1 for memory
  ## it doesn't load.
  if extractFilename(file).toLowerAscii.endsWith(".prg"):
    return fromPrg(file)
  let ram = readSnapshot(file).memory.ram
  result = newSeq[int](0x10000)
  for i in 0 ..< result.len:
    result[i] = int(ram[i])
