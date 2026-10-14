## Small conversions between bytes, signed bytes and words.

func toByte*(v: int): int =
  ## The low byte of `v`.
  v and 0xff

func toSignedByte*(v: int): int =
  ## The low byte of `v` read as a signed byte, -128 to 127.
  int(cast[int8](v and 0xff))

func word*(lo, hi: int): int =
  ## The word with these low and high bytes.
  (toByte(hi) shl 8) + toByte(lo)
