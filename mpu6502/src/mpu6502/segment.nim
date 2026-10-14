## A run of assembled bytes and the address they load at.

import std/strutils

type Segment* = object
  loadAddress*: int
  data*: seq[byte]

func `$`*(segment: Segment): string =
  result = "$" & toHex(segment.loadAddress, 4) & " "
  for b in segment.data:
    result.add toHex(b) & " "
