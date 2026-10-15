## Checks a written .asm against the image it came from (issue 0075):
## reassembles it with mpu6502 and reports the differing bytes and the gaps.

import std/[options, os]
import mpu6502
import printing, subject, memory_map

const shownDifferences = 10

proc verify*(subject: Subject, asmFile: string): bool =
  ## True when every emitted byte equals the image and there are no gaps.
  let name = "Verify " & relativePath(asmFile, subject.basePath)
  var segments: seq[Segment]
  try:
    segments = assemble(readFile(asmFile), proc (fileName: string): Option[seq[byte]] =
      let path = subject.outputPath / fileName
      if fileExists(path): some(cast[seq[byte]](readFile(path))) else: none(seq[byte]))
  except CatchableError as e:
    printOut(name & ": doesn't reassemble: " & e.msg)
    return false
  var emitted = 0
  var differences: seq[string]
  for segment in segments:
    for i in 0 ..< segment.data.len:
      let address = segment.loadAddress + i
      inc emitted
      if address > 0xffff or not subject.memory[address].loaded:
        differences.add "differ $" & hexDigits(address, 4) & " expected nothing got $" & hexDigits(int(segment.data[i]), 2)
      elif subject.memory[address].data != int(segment.data[i]):
        differences.add "differ $" & hexDigits(address, 4) & " expected $" &
            hexDigits(subject.memory[address].data, 2) & " got $" & hexDigits(int(segment.data[i]), 2)
  var virtual = 0
  for location in subject.memory:
    if (if location.area != nil: location.area.isVirtual else: location.droppedVirtual):
      inc virtual
  let gaps = gaps(subject)
  printOut(name & ": " & $emitted & " bytes emitted, " & $differences.len & " differ, " & $virtual & " virtual, " &
      $gaps.len & (if gaps.len == 1: " gap" else: " gaps"))
  for i in 0 ..< min(differences.len, shownDifferences):
    printOut(differences[i])
  if differences.len > shownDifferences:
    printOut("... " & $(differences.len - shownDifferences) & " more differ")
  for gap in gaps:
    printOut("gap " & range(gap[0], gap[1]))
  differences.len == 0 and gaps.len == 0
