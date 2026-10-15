## The memory being disassembled and everything known about it: per address
## the byte, the area it belongs to, a label and a comment; the code entries
## still to trace; and the errors and warnings found so far.

import std/[algorithm, os, sequtils, sets, strutils, tables]
import mpu6502
import printing

type
  DataType* = enum
    ## The type of a data element, with its size in bytes (`sizeInBytes`).
    dtScreencode = "screencode"
      ## Text (issue 0094) in Commodore screen codes (64tass's "screen").
    dtAscii = "ascii"
      ## Text in Commodore ASCII (64tass's "none").
    dtByte = "byte"
    dtWord = "word"
    dtLong = "long"
    dtDword = "dword"
    dtAddr = "addr"
    dtRta = "rta"
      ## A return address (issue 0038): an address minus one, as an rts
      ## dispatch table holds it, printed as 64tass's `.rta`. The address it
      ## returns to is traced as code.
    dtSbyte = "sbyte"
      ## Signed (two's-complement) numbers (issue 0037), printed as 64tass's
      ## `.char`, `.sint`, `.lint` (issue 0064) and `.dint`.
    dtSword = "sword"
    dtSlong = "slong"
    dtSdword = "sdword"
    dtUnknown = "unknown"
      ## A placeholder for memory that isn't understood yet (issue 0031): a
      ## `.flo` line with no explicit type keyword. Prints exactly like
      ## `dtByte`, but `isPlaceholder` marks it as fair game for any later,
      ## more specific annotation to silently narrow.

  LineType* = enum
    ## The kind of a `.flo` annotation line: a data type, code, or no type.
    ltScreencode, ltAscii, ltByte, ltCode, ltWord, ltLong, ltDword, ltAddr, ltRta,
    ltSbyte, ltSword, ltSlong, ltSdword,
    ltUnknown
      ## The default when a line has no explicit type keyword (issue 0031) - a
      ## placeholder for memory that isn't understood yet, printed as plain
      ## bytes but freely narrowable by any later, more specific annotation.

  Label* = ref object
    ## The label on one address: its name, and whether it is local, an auto
    ## label on a branch or jmp target that no jsr calls - a place inside a
    ## routine rather than the start of one (issue 0084) - and whether it
    ## came from an included file.
    name*: string
    local*: bool
    included*: bool
      ## True for a label from an included file (issue 0078).
    auto*: bool
      ## True for a label Deflower made up (lXXXX, dXXXX, aXXXX), false for
      ## one from a .flo file (issue 0077).

  Parameter* = object
    ## One parameter in a routine's parameter list (issue 0068): data that
    ## follows each jsr to the routine, like `char[until $ff] text`.
    dataType*: DataType
    amount*: int
      ## The number of elements, when the size is fixed.
    terminator*: int
      ## The value of the last element, for a size like "until $ff": the
      ## data runs up to and including the first element that equals it.
      ## -1 for a fixed size.
    lengthByte*: bool
      ## True for a size like "char[lengthbyte]" (issue 0094): a length
      ## byte, then that many elements.
    name*: string
      ## Empty when the parameter has no name.

  Routine* = ref object
    ## What a code line says about calls to its address (issue 0068): the
    ## data that follows each jsr to it, and whether the call returns at all.
    parameters*: seq[Parameter]
    noReturn*: bool
      ## True when a jsr to the routine doesn't return: nothing after the
      ## call (or after its data) is traced.

  ExportRegion* = ref object
    ## Memory a `.flo` line exports to a binary file of its own (issue
    ## 0022): written to `out/<name>`, and included in the generated
    ## assembly with `.binary` instead of being printed as data. A `.prg`
    ## file starts with the region's start address as its load address.
    fileName*: string
    start*: int
    finish*: int
      ## Exclusive.

  CodeEntry* = object
    ## An address to trace from, and where the flow came from (issue 0077):
    ## the instruction that jumps, branches or calls there, or falls through
    ## to it, the rta element that returns there, or -1 for a .flo code line.
    address*: int
    source*: int
    fallsThrough*: bool

  Warning* = object
    ## A suspect spot the analysis found (issue 0077), printed after the run
    ## as "warning: $addr: text".
    address*: int
    text*: string

  Annotation* = object
    ## One annotation line of a `.flo` file, as parsed: what to mark at
    ## which address. Applied to memory by `annotate`.
    address*: int
    addressEnd*: int
      ## The (exclusive) end of a memory range like "$2800-$2ff9", or -1
      ## when the line gives a single address.
    lineType*: LineType
    virtual*: bool
    amount*: int
      ## The number of elements: an array size like "byte[8]" or
      ## "byte[40*21]". Ignored when addressEnd is given.
    name*: string
      ## Empty when the line has no label.
    comment*: seq[string]
      ## The standalone comment lines right above this line, if any.
    included*: bool
      ## True for a line from an included file (issue 0078): weak, so the
      ## including file's own lines win over it.
    exportFile*: string
      ## The file this line's memory is exported to, like "font.bin" (issue
      ## 0022), or empty.
    terminator*: int
      ## For a size like "char[until $ff]" (issue 0068): the value of the
      ## last element. -1 for a fixed size.
    lengthByte*: bool
      ## For a size like "char[lengthbyte]" (issue 0094): a length byte,
      ## then that many elements.
    hasParameters*: bool
    parameters*: seq[Parameter]
      ## A code line's parameter list (issue 0068), when it has one.
    noReturn*: bool
      ## True for a code line marked "noreturn" (issue 0068).
    banked*: bool
      ## True for a "banked" line (issue 0102): a flow target in memory
      ## banked in over the RAM, named but not traced.
    selfMod*: bool
      ## True for a "selfmod" line (issue 0106): the label the operand of the
      ## self-modified instruction at the address names.

  ImageFile* = object
    ## A file to load into memory, as a 'deflower' or 'load' line gives it
    ## (issue 0083): a .vsf, a .prg or a .bin. -1 for an option not given.
    name*: string
      ## Relative to the .flo file's directory.
    address*: int
      ## 'at': where it loads; a .prg's own load address otherwise.
    offset*: int
      ## 'from': the first byte of a .bin to load.
    size*: int
      ## 'size': how many bytes of a .bin to load.

  DeflowerRun* = ref object
    ## One 'deflower <file>' line of a `.flo` file and the annotation lines
    ## that follow it, up to the next 'deflower' line (issue 0010).
    image*: ImageFile
      ## The memory image to load.
    loads*: seq[ImageFile]
      ## The files its 'load' lines load on top of it, in order.
    annotations*: seq[Annotation]

  AreaKind* = enum
    akData, akInstruction

  Area* = ref object
    ## The memory one data element or one instruction covers. Each address
    ## belongs to at most one area.
    address*: int
    size*: int
    case kind*: AreaKind
    of akData:
      dataType*: DataType
      virtual*: bool
      arrayLabel*: string
        ## The label of the array this element belongs to (empty if the .flo
        ## line that declared it had no name), and this element's index
        ## within that array. Baked in at creation time (issue 0033) so
        ## labelFor can compute a reference directly instead of scanning
        ## neighboring MemoryLocations for the nearest label.
      indexInArray*: int
      included*: bool
        ## True for an element an included file declared (issue 0078).
      exported*: ExportRegion
        ## The binary file this element is exported to (issue 0022), or nil.
      terminator*: int
        ## The value an [until n] size ended the array at (issue 0068), or -1.
      lengthByte*: bool
        ## True for an array sized by [lengthbyte] (issue 0094).
    of akInstruction:
      instruction*: Instruction

  MemoryLocation* = ref object
    address*: int
    data*: int
    loaded*: bool
      ## True when the image put this byte here; memory it doesn't load is
      ## unknown, not zero (issue 0065).
    area*: Area
    label*: Label
    comment*: seq[string]
      ## The comment lines from the .flo file, if any.
    commentIncluded*: bool
      ## True when the comment came from an included file (issue 0078).
    droppedVirtual*: bool
      ## True when an included virtual area covered this byte but was
      ## dropped as unused: still covered, not a gap (issue 0075).
    banked*: Label
      ## The name of what is banked in over the RAM here when a jsr, jmp or
      ## branch goes here (issue 0102), or nil, and its comment lines.
    bankedComment*: seq[string]

  Subject* = ref object
    outputPath*: string
    memory*: seq[MemoryLocation]
    basePath*: string
    potentialCodeLocations*: seq[CodeEntry]
      ## A stack: the last one is traced first.
    outputFileName*: string
    errors*: seq[string]
    warnings*: seq[Warning]
      ## Suspect spots, by address; they don't stop the output (issue 0077).
    exports*: seq[ExportRegion]
      ## The regions exported to binary files of their own (issue 0022).
    routines*: Table[int, Routine]
      ## What the .flo code lines say about calls to their address, by that
      ## address (issue 0068).
    callComments*: Table[int, string]
      ## The parameter names to print after each jsr whose inline data a
      ## parameter list declared, by the jsr's address (issue 0068).
    callsByReturnAddress*: Table[int, int]
      ## The jsr each call with inline data returns from, by the address it
      ## returns to, after the data (issue 0068).
    lowByteSetups*: Table[int, int]
      ## The address an address setup (issue 0074) builds, by the address of
      ## the immediate load of its low byte, and of its high byte.
    highByteSetups*: Table[int, int]
    usedBanked*: HashSet[int]
      ## The banked targets (issue 0102) a jsr, jmp, branch or rta goes to.
    operandWriters*: Table[int, seq[int]]
      ## The instructions that write or modify an instruction's operand
      ## (issue 0106), by the address of the instruction they change, sorted.
    selfModNames*: Table[int, string]
      ## The label a selfmod line (issue 0106) names, by the address of the
      ## instruction, and the address of that label once it is found.
    selfModLabels*: Table[int, int]

const memorySize* = 0x10000

func sizeInBytes*(dataType: DataType): int =
  case dataType
  of dtWord, dtAddr, dtRta, dtSword: 2
  of dtLong, dtSlong: 3
  of dtDword, dtSdword: 4
  else: 1

func dataType*(lineType: LineType): DataType =
  ## The data type of a data line; code has none.
  case lineType
  of ltScreencode: dtScreencode
  of ltAscii: dtAscii
  of ltByte: dtByte
  of ltWord: dtWord
  of ltLong: dtLong
  of ltDword: dtDword
  of ltAddr: dtAddr
  of ltRta: dtRta
  of ltSbyte: dtSbyte
  of ltSword: dtSword
  of ltSlong: dtSlong
  of ltSdword: dtSdword
  of ltUnknown: dtUnknown
  of ltCode: raise newException(Defect, "code has no data type")

proc newAutoLabel*(name: string, local: bool): Label =
  Label(name: name, local: local, auto: true)

proc newLabel*(name: string, local, included: bool): Label =
  ## A label from a .flo file.
  Label(name: name, local: local, included: included)

func headerSize*(region: ExportRegion): int =
  ## The size of the load address header in front of the bytes: 2 for a
  ## `.prg` file, 0 for a plain binary.
  if region.fileName.endsWith(".prg"): 2 else: 0

func `$`*(warning: Warning): string =
  "warning: " & asHexWord(warning.address) & ": " & warning.text

# Areas.

proc newDataArea*(address: int, dataType: DataType, isVirtual: bool, arrayLabel: string, indexInArray: int,
    included = false, region: ExportRegion = nil, terminator = -1, lengthByte = false): Area =
  Area(kind: akData, address: address, size: dataType.sizeInBytes, dataType: dataType, virtual: isVirtual,
      arrayLabel: arrayLabel, indexInArray: indexInArray, included: included, exported: region,
      terminator: terminator, lengthByte: lengthByte)

proc newInstructionArea*(address: int, instruction: Instruction): Area =
  Area(kind: akInstruction, address: address, size: instruction.addressingMode.totalBytes, instruction: instruction)

func lastOccupiedAddress*(area: Area): int =
  area.address + area.size - 1

func isData*(area: Area): bool =
  area != nil and area.kind == akData

func isInstruction*(area: Area): bool =
  area != nil and area.kind == akInstruction

func exportFileName(area: Area): string =
  if area.exported != nil: area.exported.fileName else: ""

proc `$`*(area: Area): string =
  result = asAddress(area.address) & " " & $area.size
  case area.kind
  of akData:
    result.add " " & $area.dataType
    if area.virtual:
      result.add " virtual"
    if area.exported != nil:
      result.add " export " & area.exported.fileName
  of akInstruction:
    result.add " " & toLowerAscii($area.instruction.opcode)

proc sameArea*(a, b: Area): bool =
  ## Two areas are equal when they describe the same memory the same way
  ## (same kind, address, size, and whatever else the kind adds), so a
  ## redundant re-annotation isn't flagged as a conflict in `registerArea`.
  if a == b:
    return true
  if a == nil or b == nil or a.kind != b.kind or a.address != b.address or a.size != b.size:
    return false
  case a.kind
  of akData:
    a.dataType == b.dataType and a.virtual == b.virtual and a.exportFileName == b.exportFileName
  of akInstruction:
    a.instruction.nr == b.instruction.nr

func isPlaceholder*(area: Area): bool =
  ## True for an area that only marks memory as "not yet understood" - a
  ## `.flo` line with no explicit type keyword (issue 0031). A placeholder
  ## may be silently narrowed by any later, more specific annotation
  ## (`registerArea`), and the flow analyser may decode straight through
  ## one. An exported range is fixed data, even without a type.
  area.kind == akData and area.dataType == dtUnknown and area.exported == nil

func isVirtual*(area: Area): bool =
  ## True for an area declared `virtual` in the `.flo` file: memory the
  ## code uses but whose contents aren't part of the program. Its contents
  ## are never dumped; it's emitted as a 64tass `.virtual` reservation
  ## instead (issues 0045, 0046).
  area.kind == akData and area.virtual

func endsFlow*(area: Area): bool =
  ## True when execution can't fall through to the next instruction: jmp,
  ## rts, rti and brk (issue 0073).
  area.kind == akInstruction and area.instruction.opcode in {Opcode.JMP, Opcode.RTS, Opcode.RTI, Opcode.BRK}

func arrayStart*(area: Area): int =
  ## The address of the first element of the array this element belongs to.
  area.address - area.indexInArray * area.size

func isInSameArray*(area: Area, other: Area, index: int): bool =
  ## True when `other` is element `index` of the same array as `area`.
  other.isData and other.dataType == area.dataType and other.indexInArray == index and
      other.arrayLabel == area.arrayLabel

func labelName*(location: MemoryLocation): string =
  ## The label's name, or empty when there is no label here.
  if location.label != nil: location.label.name else: ""

proc labelFor*(area: Area, address: int, subject: Subject): string =
  ## The name an operand refers to `address` inside the area by, or empty.
  ##
  ## A label on the address itself always wins. Else a data element names
  ## it by its array's label plus the offset (issue 0033), and an
  ## instruction by the label on its first byte plus the offset (issue
  ## 0067).
  let directLabel = subject.memory[address].labelName
  if directLabel.len > 0:
    return directLabel
  case area.kind
  of akData:
    if area.arrayLabel.len == 0:
      return ""
    let offset = area.indexInArray * area.size + (address - area.address)
    if offset == 0:
      return area.arrayLabel
    area.arrayLabel & " + $" & hex(offset)
  of akInstruction:
    let offset = address - area.address
    let label = subject.memory[area.address].labelName
    if label.len == 0:
      return ""
    if offset == 0:
      return label
    label & " + " & $offset

proc labelAddressFor*(area: Area, address: int, subject: Subject): int =
  ## The address of the label `labelFor` names `address` by, or -1 when it
  ## has none: the place a reference to `address` is listed as a
  ## cross-reference (issue 0076).
  if subject.memory[address].label != nil:
    return address
  case area.kind
  of akData:
    if area.arrayLabel.len > 0: area.arrayStart else: -1
  of akInstruction:
    if subject.memory[area.address].label != nil: area.address else: -1

# The subject.

proc newSubject*(basePath: string): Subject =
  result = Subject(basePath: basePath, outputPath: basePath / "out", outputFileName: "deflowered.asm")
  result.memory = newSeq[MemoryLocation](memorySize)
  for i in 0 ..< memorySize:
    result.memory[i] = MemoryLocation(address: i)

proc storeAt*(subject: Subject, startAddress: int, bytes: openArray[byte], source: string) =
  ## Copies `bytes`, read from `source`, into memory from `startAddress`
  ## on. Rejects an image that runs past $FFFF (issue 0014).
  assertState(startAddress + bytes.len <= memorySize,
      source & ": " & $bytes.len & " bytes loaded at " & asHexWord(startAddress) & " run past $ffff")
  for i in 0 ..< bytes.len:
    subject.memory[startAddress + i] = MemoryLocation(address: startAddress + i, data: int(bytes[i]), loaded: true)

proc peek*(subject: Subject, address: int): Area =
  subject.memory[address].area

proc byteAt*(subject: Subject, address: int): int =
  subject.memory[address].data

proc wordAt*(subject: Subject, address: int): int =
  subject.byteAt(address) + 256 * subject.byteAt(address + 1)

proc longAt*(subject: Subject, address: int): int =
  subject.wordAt(address) + 256 * 256 * subject.byteAt(address + 2)

proc dwordAt*(subject: Subject, address: int): int =
  ## Signed, as a Java int: a value from $80000000 on is negative.
  int(cast[int32](uint32(subject.wordAt(address) + 256 * 256 * subject.wordAt(address + 2))))

proc warn*(subject: Subject, address: int, text: string) =
  subject.warnings.add Warning(address: address, text: text)

proc isLoaded(subject: Subject, address, size: int): bool =
  ## True when the image loaded all `size` bytes from `address` on.
  for a in address ..< address + size:
    if a >= memorySize or not subject.memory[a].loaded:
      return false
  true

proc countUntil*(subject: Subject, start, elementSize, terminator: int): int =
  ## The number of `elementSize`-byte elements from `start` on, up to and
  ## including the first one that holds `terminator` (issue 0068), or -1
  ## when memory the image doesn't load comes first.
  var address = start
  var count = 1
  while subject.isLoaded(address, elementSize):
    var value = 0
    for i in countdown(elementSize - 1, 0):
      value = value * 256 + subject.byteAt(address + i)
    if value == terminator:
      return count
    address += elementSize
    inc count
  -1

proc registerArea*(subject: Subject, area: Area) =
  for a in 0 ..< area.size:
    let address = a + area.address
    let existing = subject.memory[address].area
    if existing != nil and not sameArea(existing, area) and not existing.isPlaceholder:
      subject.errors.add "Area conflict at " & asHexWord(address) & ": " & $area & " overwrites " & $existing
    subject.memory[address].area = area

proc ensureLabelled(subject: Subject, address: int, contentHint: string, local: bool) =
  let location = subject.memory[address]
  if location.label == nil:
    location.label = newAutoLabel(contentHint & toUpperAscii(hexDigits(address, 4)), local)

proc ensureLabelled*(subject: Subject, address: int, contentHint: string, referencedFromAddress: int) =
  subject.ensureLabelled(address, contentHint, false)

proc labelDataReference*(subject: Subject, target: int, referencingAddress: int) =
  ## Labels the target of a data reference, unless it is free memory, an
  ## area from an included file, or already has a name.
  let area = subject.peek(target)
  if area == nil or area.isData and area.included or area.labelFor(target, subject).len > 0:
    return
  subject.ensureLabelled(target, "d", referencingAddress)

proc addPotentialCodeLocation*(subject: Subject, address: int, labelIt: bool, referencingAddress: int) =
  ## Code to trace at `address`, reached from the instruction at
  ## `referencingAddress`. Pushed even onto memory an area covers, so the
  ## analyser can warn about a jump into data or into the middle of an
  ## instruction (issue 0077); it only decodes free memory and placeholders
  ## (issue 0055).
  if labelIt and subject.memory[address].banked != nil:
    # Something else is banked in there (issue 0102).
    subject.usedBanked.incl address
    return
  if labelIt:
    subject.ensureLabelled(address, "l", true)
  subject.potentialCodeLocations.add CodeEntry(address: address, source: referencingAddress,
      fallsThrough: not labelIt)

proc addCallTarget*(subject: Subject, address: int, referencingAddress: int) =
  ## A jsr target: code to trace, and the start of a routine, so its label
  ## isn't local even when a branch or jmp labelled it first.
  subject.addPotentialCodeLocation(address, true, referencingAddress)
  let location = subject.memory[address]
  if location.banked == nil and location.label.local:
    location.label = newAutoLabel(location.label.name, false)

proc returnAddressAt*(subject: Subject, address: int): int =
  ## The address an rts returns to through the rta value at `address`.
  (subject.wordAt(address) + 1) and 0xffff

proc addReturnAddress*(subject: Subject, area: Area) =
  ## Traces where an rta element (issue 0038) returns to, as the start of a
  ## routine: an rts dispatch table's entries are its handlers.
  if area.dataType == dtRta and not area.isVirtual:
    subject.addCallTarget(subject.returnAddressAt(area.address), area.address)

proc exportRegion(subject: Subject, fileName: string, start, finish: int): ExportRegion =
  ## Registers the region from `start` to `finish` (exclusive) for export
  ## to `fileName` (issue 0022), or reports why it can't be, giving nil:
  ## the file must hold bytes the image loaded.
  if finish > memorySize:
    subject.errors.add "Exported " & fileName & " at " & asHexWord(start) & " runs past $ffff"
    return nil
  for address in start ..< finish:
    if not subject.memory[address].loaded:
      subject.errors.add "Exported " & fileName & " at " & asHexWord(start) &
          " holds memory the image doesn't load, at " & asHexWord(address)
      return nil
  result = ExportRegion(fileName: fileName, start: start, finish: finish)
  subject.exports.add result

proc bytesOf*(subject: Subject, region: ExportRegion): seq[byte] =
  ## The contents of `region`'s file: the bytes as the image loaded them,
  ## after the start address for a .prg file.
  let header = region.headerSize
  result = newSeq[byte](header + region.finish - region.start)
  if header == 2:
    result[0] = byte(region.start and 0xff)
    result[1] = byte((region.start shr 8) and 0xff)
  for i in header ..< result.len:
    result[i] = byte(subject.byteAt(region.start + i - header))

proc insideOwnArea(subject: Subject, address: int): bool =
  ## True when an area of the including file covers `address` but starts
  ## before it, like the high byte of a word: an included name there would
  ## replace the word's own name in the operands.
  let area = subject.memory[address].area
  area != nil and area.address != address and not (area.isData and area.included)

proc overlapsOwnArea(subject: Subject, area: Area): bool =
  ## True when part of `area` is already covered by an area that isn't
  ## from an included file.
  var a = area.address
  while a < area.address + area.size and a < memorySize:
    let existing = subject.memory[a].area
    if existing != nil and not (existing.isData and existing.included):
      return true
    inc a
  false

proc annotateBanked(subject: Subject, annotation: Annotation, location: MemoryLocation) =
  ## Names what is banked in at the address for the flow that goes there
  ## (issue 0102). An included one is weak: it loses to a banked line or a
  ## code line of the including file at the same address.
  if annotation.included and location.banked != nil:
    return
  location.banked = newLabel(annotation.name, false, annotation.included)
  location.bankedComment = annotation.comment

proc annotate*(subject: Subject, annotation: Annotation) =
  ## Applies one `.flo` annotation line: its label and comment go onto its
  ## address, a code entry becomes a place to start the flow analysis from,
  ## and a data line registers one data area per element.
  ##
  ## An included line (issue 0078) is weak, and must be applied after the
  ## including file's own lines: its label and comment only go where there
  ## are none yet, and an element that overlaps an area of the including
  ## file is dropped.
  let address = annotation.address
  let location = subject.memory[address]
  if annotation.banked:
    subject.annotateBanked(annotation, location)
    return
  if annotation.selfMod:
    # The including file's own lines come first.
    if address notin subject.selfModNames:
      subject.selfModNames[address] = annotation.name
    if location.comment.len == 0:
      location.comment = annotation.comment
      location.commentIncluded = annotation.included
    return
  # An included comment describes the included label, so it only goes
  # where that label does. An included label with the banked name of its
  # address names the same routine in the ROM (issue 0102).
  let weakLosesLabel = annotation.included and (location.label != nil and not location.label.included or
      subject.insideOwnArea(address) or
      location.banked != nil and location.banked.name == annotation.name)
  if annotation.name.len > 0 and (not annotation.included or location.label == nil and not weakLosesLabel):
    location.label = newLabel(annotation.name, false, annotation.included)
  if annotation.comment.len > 0 and not weakLosesLabel and (not annotation.included or location.comment.len == 0):
    location.comment = annotation.comment
    location.commentIncluded = annotation.included
  let lineType = annotation.lineType
  if lineType == ltUnknown and annotation.addressEnd == -1:
    # No type and no size: just a label or comment for an address (issue
    # 0028), which can sit inside an area another line declared, like a
    # high score on the screen.
    if annotation.virtual:
      subject.errors.add "Virtual address " & asHexWord(address) & " needs a type or a range"
    return
  if lineType == ltCode:
    subject.potentialCodeLocations.add CodeEntry(address: address, source: -1, fallsThrough: false)
    if annotation.hasParameters or annotation.noReturn:
      # The included lines come last, so they don't replace what the
      # including file says.
      if address notin subject.routines:
        subject.routines[address] = Routine(parameters: annotation.parameters, noReturn: annotation.noReturn)
    return
  let dataType = lineType.dataType
  let size = dataType.sizeInBytes
  var amount = if annotation.addressEnd != -1: (annotation.addressEnd - address) div size
               else: annotation.amount
  if annotation.addressEnd == -1 and annotation.terminator != -1:
    amount = subject.countUntil(address, size, annotation.terminator)
    if amount == -1:
      subject.errors.add "No " & $dataType & " ending in $" & hexDigits(annotation.terminator, 2) & " at " &
          asHexWord(address) & " before memory the image doesn't load"
      return
  if annotation.addressEnd == -1 and annotation.lengthByte:
    if not subject.isLoaded(address, 1):
      subject.errors.add "No length byte for " & $dataType & " at " & asHexWord(address) &
          ": memory the image doesn't load"
      return
    amount = 1 + subject.byteAt(address)
  if amount <= 0:
    # Issue 0044: an empty array, or a range too short to hold one element
    # (e.g. $c006-$c007 word: the end is exclusive), is a mistake, not a
    # no-op.
    subject.errors.add "Zero-size " & $dataType & " at " & asHexWord(address)
    return
  var region: ExportRegion = nil
  if annotation.exportFile.len > 0:
    region = subject.exportRegion(annotation.exportFile, address, address + amount * size)
    if region == nil:
      return
  # Issue 0087: an element the image doesn't (fully) load is virtual, so
  # its bytes aren't printed as zeroes.
  var unloaded: seq[string]
  var unloadedStart = -1
  for i in 0 ..< amount:
    let elementAddress = address + i * size
    let loaded = subject.isLoaded(elementAddress, size)
    if not loaded and not annotation.virtual and unloadedStart == -1:
      unloadedStart = elementAddress
    elif loaded and unloadedStart != -1:
      unloaded.add asHexWord(unloadedStart) & "-" & asHexWord(elementAddress)
      unloadedStart = -1
    let area = newDataArea(elementAddress, dataType, annotation.virtual or not loaded, annotation.name, i,
        annotation.included, region, annotation.terminator, annotation.lengthByte)
    if not annotation.included or not subject.overlapsOwnArea(area):
      subject.registerArea(area)
      subject.addReturnAddress(area)
  if unloadedStart != -1:
    unloaded.add asHexWord(unloadedStart) & "-" & asHexWord(address + amount * size)
  if unloaded.len > 0 and not annotation.included:
    subject.warn(address, $dataType & (if annotation.name.len == 0: "" else: " " & annotation.name) &
        ": the image doesn't load " & unloaded.join(", ") & ", printed as virtual")

proc target*(area: Area, subject: Subject): int =
  ## The address the operand of the instruction in `area` names, or -1 for
  ## an instruction without one. For an indirect mode that is the pointer,
  ## not where it points.
  let byte1 = subject.byteAt(area.address + 1)
  case area.instruction.addressingMode
  of AddressingMode.ZeroPage, AddressingMode.ZeroPageX, AddressingMode.ZeroPageY, AddressingMode.IndX,
      AddressingMode.IndY:
    byte1
  of AddressingMode.Absolute, AddressingMode.AbsoluteX, AddressingMode.AbsoluteY, AddressingMode.Indirect:
    word(byte1, subject.byteAt(area.address + 2))
  of AddressingMode.Relative:
    area.address + toSignedByte(byte1) + 2
  of AddressingMode.Immediate, AddressingMode.Jam, AddressingMode.Accumulator, AddressingMode.None:
    -1

proc checkBankedCodeEntries*(subject: Subject) =
  ## Settles the banked names (issue 0102) after all lines are applied. A
  ## label of the including file with the same name at the same address,
  ## like a virtual KERNAL jump table of its own, already names the
  ## routine, so an included banked name gives way. So does one at a code
  ## line of the including file, which is an error next to a banked line of
  ## its own.
  for location in subject.memory:
    if location.banked != nil and location.banked.included and location.label != nil and
        not location.label.included and location.label.name == location.banked.name:
      location.banked = nil
      location.bankedComment = @[]
  for entry in subject.potentialCodeLocations:
    let location = subject.memory[entry.address]
    if entry.source != -1 or location.banked == nil:
      continue
    if location.banked.included:
      location.banked = nil
      location.bankedComment = @[]
    else:
      subject.errors.add "Banked " & location.banked.name & " at " & asHexWord(entry.address) &
          " is also a code entry"

proc bankedTarget*(subject: Subject, area: Area): int =
  ## The target of the jsr, jmp or branch in `area` when a banked line names
  ## it (issue 0102), or -1: the flow goes to what is banked in there, not
  ## to the RAM.
  let mode = area.instruction.addressingMode
  let flow = mode == AddressingMode.Relative or
      mode == AddressingMode.Absolute and area.instruction.opcode in {Opcode.JSR, Opcode.JMP}
  let target = if flow: area.target(subject) else: -1
  if target != -1 and subject.memory[target].banked != nil: target else: -1

proc isVirtualAt*(subject: Subject, address: int): bool =
  let area = subject.peek(address)
  area != nil and area.isVirtual

proc isAnnotated*(subject: Subject, address: int): bool =
  ## True when a label or comment is attached to `address`.
  subject.memory[address].label != nil or subject.memory[address].comment.len > 0

proc firstAnnotatedAddressInside*(subject: Subject, start, finish: int): int =
  ## The first address after `start` and before `finish` with a label or
  ## comment, or `finish` when there is none.
  for address in start + 1 ..< finish:
    if subject.isAnnotated(address):
      return address
  finish

proc continuesRun*(subject: Subject, area: Area, address: int): bool =
  ## True when the run of data `area` is part of carries on at `address`:
  ## an element of the same type, virtual or not like `area`, starts there,
  ## and no label or comment interrupts the run.
  if address >= memorySize or subject.isAnnotated(address):
    return false
  let next = subject.peek(address)
  next.isData and next.address == address and next.dataType == area.dataType and
      next.isVirtual == area.isVirtual

proc continuesArray*(subject: Subject, area: Area, address: int): bool =
  ## True when the next element of the array `area` belongs to starts at
  ## `address`. A label there doesn't interrupt the array's dump: it is
  ## printed as an address define after the array (issue 0028). A comment
  ## without a label still does.
  if address >= memorySize or (subject.memory[address].comment.len > 0 and subject.memory[address].label == nil):
    return false
  let next = subject.peek(address)
  next != nil and next.address == address and next.isVirtual == area.isVirtual and
      area.isInSameArray(next, area.indexInArray + 1)

proc endOfRun*(subject: Subject, first: Area): int =
  ## The (exclusive) end of the run of same-type elements starting at
  ## `first`: it stops before an element that differs or carries its own
  ## label/comment, and after an element with a label/comment somewhere
  ## inside it, so that annotation can still be printed.
  result = first.address + first.size
  while subject.firstAnnotatedAddressInside(result - first.size, result) == result and
      subject.continuesRun(first, result):
    result += first.size

proc endOfArray*(subject: Subject, element: Area): int =
  ## The (exclusive) end of the array `element` belongs to: the elements one
  ## `.flo` line declared.
  result = element.arrayStart
  var index = 0
  while result < memorySize and element.isInSameArray(subject.peek(result), index):
    result += element.size
    inc index

proc isPrintedBanked*(subject: Subject, address: int): bool =
  ## True when the banked name at `address` (issue 0102) is printed: one of
  ## the .flo file's own, or an included one the flow goes to.
  let banked = subject.memory[address].banked
  banked != nil and (not banked.included or address in subject.usedBanked)

proc reportDuplicateLabels*(subject: Subject) =
  ## Reports every label that is defined at more than one address (issue
  ## 0043): the assembler would reject it, or code references would resolve
  ## to the wrong one. Run after the flow analysis, so the auto-generated
  ## labels are checked too.
  var firstAddressByLabel: Table[string, int]
  for location in subject.memory:
    for label in [location.label, if subject.isPrintedBanked(location.address): location.banked else: nil]:
      if label == nil:
        continue
      if label.name in firstAddressByLabel:
        subject.errors.add "Duplicate label " & label.name & " at " & asHexWord(location.address) &
            ", already defined at " & asHexWord(firstAddressByLabel[label.name])
      else:
        firstAddressByLabel[label.name] = location.address

proc operandModified*(subject: Subject, address: int): bool =
  ## True when another instruction writes the operand of the instruction at
  ## `address` (issue 0106), so it names nothing.
  address in subject.operandWriters

proc exactLabel*(subject: Subject, address: int): string =
  ## The label on `address` itself, or empty, also for "label + offset".
  let area = subject.memory[address].area
  let label = if area == nil: subject.memory[address].labelName else: area.labelFor(address, subject)
  if ' ' in label: "" else: label

proc bankedValueName*(subject: Subject, address: int): string =
  ## The banked name for an address as a value (issue 0102): an .addr value
  ## or what an address setup builds, like the KERNAL's IRQ handler put in
  ## the IRQ vector. Empty when there is none, or when the RAM has a label
  ## on the address itself, which wins.
  let banked = subject.memory[address].banked
  if banked == nil or subject.exactLabel(address).len > 0: "" else: banked.name

proc referencedAddresses*(subject: Subject): HashSet[int] =
  ## Every address an instruction's operand names, a (not virtual) .addr
  ## value holds, an .rta value returns to, and the address an address
  ## setup builds when its label would be on that address itself.
  for location in subject.memory:
    let area = location.area
    if area == nil or area.address != location.address:
      continue
    if area.kind == akInstruction:
      let target = area.target(subject)
      if area.address in subject.selfModLabels:
        result.incl subject.selfModLabels[area.address]
      elif target != -1 and subject.bankedTarget(area) == -1 and not subject.operandModified(area.address):
        result.incl target
    elif area.dataType == dtAddr and not area.isVirtual:
      result.incl subject.wordAt(area.address)
    elif area.dataType == dtRta and not area.isVirtual:
      result.incl subject.returnAddressAt(area.address)
  for built in subject.lowByteSetups.values:
    # Only a label on the address itself prints (issue 0034).
    let area = subject.peek(built)
    if area == nil or area.labelAddressFor(built, subject) == built:
      result.incl built

proc includedVirtualArea(subject: Subject, address: int): Area =
  let area = subject.memory[address].area
  if area.isData and area.included and area.isVirtual: area else: nil

proc dropUnusedIncludes*(subject: Subject) =
  ## Drops what included files declared but nothing uses (issue 0078),
  ## after the flow analysis: a virtual array without a name or that no
  ## instruction operand or .addr value points into, and a label no operand
  ## or .addr value prints. An included comment goes with its label.
  ## Included areas still stopped the tracing before this.
  let targets = subject.referencedAddresses()
  var usedArrays: HashSet[int]
  for target in targets:
    let area = subject.includedVirtualArea(target)
    if area != nil and area.arrayLabel.len > 0:
      usedArrays.incl area.arrayStart
  for address in 0 ..< memorySize:
    let area = subject.includedVirtualArea(address)
    if area != nil and area.arrayStart notin usedArrays:
      subject.memory[address].area = nil
      subject.memory[address].droppedVirtual = true
  var labelAddresses: HashSet[int]
  for target in targets:
    let area = subject.peek(target)
    labelAddresses.incl(if area != nil: area.labelAddressFor(target, subject) else: target)
  for location in subject.memory:
    let area = location.area
    let onIncludedArea = area.isData and area.included and not area.isVirtual
    if location.label != nil and location.label.included and not onIncludedArea and
        location.address notin labelAddresses:
      location.label = nil
    if location.commentIncluded and (location.label == nil or not location.label.included) and not onIncludedArea:
      location.comment = @[]
      location.commentIncluded = false
  for built in subject.lowByteSetups.values:
    if subject.bankedValueName(built).len > 0:
      subject.usedBanked.incl built
  for location in subject.memory:
    let area = location.area
    if area.isData and area.dataType == dtAddr and area.address == location.address and
        not area.isVirtual and subject.bankedValueName(subject.wordAt(area.address)).len > 0:
      subject.usedBanked.incl subject.wordAt(area.address)

proc isSkeletonRange(area: Area): bool =
  area.isVirtual and not area.included and area.arrayLabel.len > 0 and
      (area.arrayLabel.startsWith("untouched_") or area.arrayLabel.startsWith("unused_"))

proc warnUsedSkeletonRanges*(subject: Subject) =
  ## Warns about the untouched_ and unused_ ranges of an --init skeleton
  ## that an instruction's operand names (issue 0103): they are virtual, so
  ## a wrong one hides what the program uses there.
  var users: Table[int, seq[string]]
  for location in subject.memory:
    let area = location.area
    if not area.isInstruction or area.address != location.address:
      continue
    let target = area.target(subject)
    if target == -1 or subject.bankedTarget(area) != -1 or subject.operandModified(area.address) or
        area.address in subject.selfModLabels:
      continue
    # An included label names what is really there, like a KERNAL routine
    # in the ROM over the RAM.
    let label = subject.memory[target].label
    let targetArea = subject.memory[target].area
    if targetArea.isData and targetArea.isSkeletonRange and (label == nil or not label.included):
      let user = asHexWord(area.address)
      let users = addr users.mgetOrPut(targetArea.arrayStart, @[])
      if user notin users[]:
        users[].add user
  var starts = toSeq(users.keys)
  starts.sort()
  for start in starts:
    subject.warn(start, subject.memory[start].area.arrayLabel & " is used by " & users[start].join(", "))
