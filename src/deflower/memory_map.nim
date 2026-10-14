## What covers each part of memory, one line per piece, written to
## out/<binary>.map on every run (issue 0075). Ranges are $start-$end with
## the end exclusive, as in a .flo file:
##
## ```
## $c000-$c007 code entry
## $c007-$c009 word table
## $c009-$c00d virtual word[2] table + $2
## $c00d-$c010 gap
## ```
##
## Code runs split at every routine label (not at local ones), arrays are
## one line, and a gap is loaded memory no area covers. Memory the image
## doesn't load and no area covers isn't listed, and neither are the
## included virtual areas the output leaves out as unused.

import printing, subject

proc isGap*(location: MemoryLocation): bool =
  ## Loaded memory that no area covers. An included virtual area dropped
  ## as unused still covers its memory.
  location.loaded and location.area == nil and not location.droppedVirtual

proc range*(start, finish: int): string =
  "$" & hexDigits(start, 4) & "-$" & hexDigits(finish, 4)

proc startsRoutine(location: MemoryLocation): bool =
  location.label != nil and not location.label.local

proc describe(area: Area, count: int): string =
  let typeName = if area.dataType == dtUnknown: "untyped" else: $area.dataType
  (if area.isVirtual: " virtual " else: " ") & typeName &
    (if count > 1: "[" & $count & "]" else: "") &
    (if area.exported != nil: " export " & area.exported.fileName else: "")

proc label(name: string): string =
  if name.len > 0: " " & name else: ""

proc mapLines*(subject: Subject): seq[string] =
  let memory = subject.memory
  var address = 0
  while address < memorySize:
    let area = memory[address].area
    let start = address
    if area.isInstruction:
      address = area.address + area.size
      while address < memorySize and memory[address].area.isInstruction and
          memory[address].area.address == address and not startsRoutine(memory[address]):
        address += memory[address].area.size
      result.add range(start, address) & " code" & label(memory[start].labelName)
    elif area.isData:
      let first = area
      var last = first
      var count = 1
      address = first.address + first.size
      while address < memorySize and memory[address].area.isData and
          memory[address].area.address == address and
          last.isInSameArray(memory[address].area, last.indexInArray + 1) and
          memory[address].area.isVirtual == first.isVirtual and
          memory[address].area.exported == first.exported:
        last = memory[address].area
        inc count
        address += last.size
      result.add range(first.address, address) & describe(first, count) & label(first.labelFor(first.address, subject))
    else:
      let gap = isGap(memory[start])
      while address < memorySize and memory[address].area == nil and isGap(memory[address]) == gap:
        inc address
      if gap:
        result.add range(start, address) & " gap"

proc gaps*(subject: Subject): seq[(int, int)] =
  ## The gaps: loaded memory no area covers, as (start, end) with the end
  ## exclusive.
  var address = 0
  while address < memorySize:
    if isGap(subject.memory[address]):
      let start = address
      while address < memorySize and isGap(subject.memory[address]):
        inc address
      result.add (start, address)
    else:
      inc address
