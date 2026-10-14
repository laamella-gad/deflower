## Hex formatting and the errors that stop a run.

import std/strutils

type
  StateError* = object of CatchableError
    ## Something that stops the run, like Java's IllegalStateException:
    ## its message is printed and the run fails.
  ArgumentError* = object of CatchableError
    ## Bad arguments, like Java's IllegalArgumentException.

proc assertState*(condition: bool, problem: string) =
  if not condition:
    raise newException(StateError, problem)

proc assertArgument*(condition: bool, problem: string) =
  if not condition:
    raise newException(ArgumentError, problem)

proc hexDigits*(value: int, digits: int): string =
  ## `value` in lower case hex, at least `digits` long.
  result = toLowerAscii(toHex(value, 16)).strip(trailing = false, chars = {'0'})
  while result.len < digits:
    result = "0" & result

proc hex*(value: int): string =
  ## `value` in lower case hex, as Java's "%x".
  hexDigits(value, 1)

proc asAddress*(address: int): string =
  assertState(address >= 0 and address <= 0xFFFF, "Invalid address " & $address)
  "$" & hexDigits(address, 4)

proc asHexByte*(value: int): string =
  assertState(value >= 0 and value <= 0xFF, "Invalid byte " & $value)
  "$" & hexDigits(value, 2)

proc asHexWord*(value: int): string =
  assertState(value >= 0 and value <= 0xFFFF, "Invalid word " & $value)
  "$" & hexDigits(value, 4)

proc asHexLong*(value: int): string =
  assertState(value >= 0 and value <= 0xFFFFFF, "Invalid long " & $value)
  "$" & hexDigits(value, 6)

proc asHexDword*(value: int): string =
  assertState(value >= 0 and value <= 0xFFFFFFFF, "Invalid dword " & $value)
  "$" & hexDigits(value, 8)

var
  printOut*: proc (line: string) = proc (line: string) = stdout.writeLine(line)
    ## Prints a line of the run's output.
  printErr*: proc (line: string) = proc (line: string) = stderr.writeLine(line)
    ## Prints a line about an error.
