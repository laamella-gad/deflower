## Reads VICE snapshot files (`.vsf`): a header, then modules, of which
## the ones Deflower knows are read into objects of their own: memory, CPU,
## VIC-II and CIAs. Other modules and versions are kept unhandled.

import std/options

type
  Version* = object
    major*: int
    minor*: int

  Header* = object
    machineName*: string
    version*: Version

  ModuleKind* = enum
    mkUnhandled, mkC64Mem, mkMainCpu, mkVicII, mkCia

  Module* = ref object
    moduleType*: string
    version*: Version
    case kind*: ModuleKind
    of mkUnhandled:
      data*: seq[byte]
    of mkC64Mem:
      cpuData*: int
      cpuDir*: int
      exrom*: int
      game*: int
      ram*: seq[byte]
    of mkMainCpu:
      a*, x*, y*, sp*, pc*, status*: int
    of mkVicII:
      registers*: array[0x40, int]
        ## The registers $d000-$d03f, as last written.
    of mkCia:
      portA*, portB*, directionA*, directionB*: int
      interruptMask*: int
        ## The interrupt sources that are enabled: bit 0 timer A, 1 timer B,
        ## 2 the TOD alarm, 3 the serial port, 4 the FLAG line.

  ViceVcfFile* = object
    header*: Header
    modules*: seq[Module]

  Reader = object
    bytes: seq[byte]
    position: int

  VcfError* = object of CatchableError

proc getByte(reader: var Reader): int =
  if reader.position >= reader.bytes.len:
    raise newException(VcfError, "Snapshot ends too early")
  result = int(reader.bytes[reader.position])
  inc reader.position

proc readWord(reader: var Reader): int =
  let lo = reader.getByte()
  let hi = reader.getByte()
  (hi shl 8) + lo

proc readDword(reader: var Reader): int =
  let lo = reader.readWord()
  let hi = reader.readWord()
  int(cast[int32](uint32((hi shl 16) + lo)))

proc getBytes(reader: var Reader, size: int): seq[byte] =
  if size < 0 or reader.position + size > reader.bytes.len:
    raise newException(VcfError, "Snapshot ends too early")
  result = reader.bytes[reader.position ..< reader.position + size]
  reader.position += size

proc paddedString(bytes: openArray[byte], pad: int): string =
  ## The text in `bytes`, without the `pad` bytes at its end.
  var finish = bytes.len
  while finish > 0 and int(bytes[finish - 1]) == pad:
    dec finish
  for i in 0 ..< finish:
    result.add char(bytes[i])

proc readVersion(reader: var Reader): Version =
  # Java read them as signed bytes.
  Version(major: int(cast[int8](reader.getByte())), minor: int(cast[int8](reader.getByte())))

proc handle(name: string, version: Version, content: seq[byte]): Module =
  ## The module as one of the kinds Deflower knows, or nil.
  if name == "C64MEM":
    var reader = Reader(bytes: content)
    result = Module(kind: mkC64Mem, moduleType: name, version: version)
    result.cpuData = reader.getByte()
    result.cpuDir = reader.getByte()
    result.exrom = reader.getByte()
    result.game = reader.getByte()
    result.ram = reader.getBytes(0x10000)
  elif name == "MAINCPU" and version.major == 1 and version.minor in [1, 4]:
    # The clock: 4 bytes in version 1.1 (VICE 1.x), 8 in 1.4 (VICE 3.x).
    var reader = Reader(bytes: content, position: if version.minor == 1: 4 else: 8)
    result = Module(kind: mkMainCpu, moduleType: name, version: version)
    result.a = reader.getByte()
    result.x = reader.getByte()
    result.y = reader.getByte()
    result.sp = reader.getByte()
    result.pc = reader.readWord()
    result.status = reader.getByte()
  elif name == "VIC-II" and version.major == 1 and version.minor == 3:
    # x64sc's layout in VICE 3.x: one byte, then the 64 registers.
    result = Module(kind: mkVicII, moduleType: name, version: version)
    var reader = Reader(bytes: content, position: 1)
    for i in 0 ..< 0x40:
      result.registers[i] = reader.getByte()
  elif name in ["CIA1", "CIA2"] and version.major == 2:
    # The ports, their data directions, the timers (4 bytes), the time of
    # day (4 bytes), the serial data register and then the interrupt mask.
    var reader = Reader(bytes: content)
    result = Module(kind: mkCia, moduleType: name, version: version)
    result.portA = reader.getByte()
    result.portB = reader.getByte()
    result.directionA = reader.getByte()
    result.directionB = reader.getByte()
    reader.position = 13
    result.interruptMask = reader.getByte()

proc readModule(reader: var Reader): Module =
  let moduleType = paddedString(reader.getBytes(16), 0)
  let version = reader.readVersion()
  let size = reader.readDword() - 22
  let content = reader.getBytes(size)
  result = handle(moduleType, version, content)
  if result == nil:
    result = Module(kind: mkUnhandled, moduleType: moduleType, version: version, data: content)

proc readHeader(reader: var Reader): Header =
  const expectedFormat = "VICE Snapshot File\x1a"
  if paddedString(reader.getBytes(expectedFormat.len), -1) != expectedFormat:
    raise newException(VcfError, "Not a VICE snapshot file")
  result.version = reader.readVersion()
  result.machineName = paddedString(reader.getBytes(16), 0)
  # VICE snapshot format 2.0+ has a "VICE Version" block here. Older
  # snapshots (format 1.x, as produced by e.g. VICE 1.x) go straight into
  # the first module, so what was just read is that module's header and
  # has to be put back.
  const expectedViceVersion = "VICE Version\x1a"
  if paddedString(reader.getBytes(expectedViceVersion.len), -1) == expectedViceVersion:
    discard reader.readDword()
    discard reader.readDword()
  else:
    reader.position -= expectedViceVersion.len

proc readVcf*(bytes: seq[byte]): ViceVcfFile =
  var reader = Reader(bytes: bytes)
  result.header = reader.readHeader()
  while reader.position < reader.bytes.len:
    result.modules.add reader.readModule()

proc module*(file: ViceVcfFile, moduleType: string, kind: ModuleKind): Option[Module] =
  ## The module with this name, if it was read as this kind.
  for module in file.modules:
    if module.moduleType == moduleType and module.kind == kind:
      return some(module)
  none(Module)
