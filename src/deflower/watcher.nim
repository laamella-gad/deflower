## Keeps running a .flo file (issue 0057): one run at the start, then one
## more whenever a file it is made from changes - the .flo file, the .flo
## files it includes from disk, the binaries it loads. Changes are found by
## polling the modification times, and a run starts once they have settled,
## as an editor saves in several steps. A run with errors leaves `out/` as it
## was. After each run comes a status line: the time, the outcome and the
## file being watched.

import std/[os, times]
import printing, runner

const pollInterval* = 200
  ## Milliseconds between two looks at the modification times.

type
  Watcher* = object
    flowerFile: string
    verify: bool
    files: seq[string]
      ## The files to watch, the .flo file first.
    stamps: seq[Time]
      ## Their modification times when the last run started.
    runs: int

proc stamp(file: string): Time =
  ## The file's modification time, or the epoch when it is missing or can't
  ## be read, so that it appearing counts as a change.
  try:
    getLastModificationTime(file)
  except OSError:
    fromUnix(0)

proc stamps(files: seq[string]): seq[Time] =
  for file in files:
    result.add stamp(file)

proc newWatcher*(flowerFile: string, verify: bool): Watcher =
  Watcher(flowerFile: flowerFile, verify: verify, files: @[absolutePath(flowerFile)])

proc changed*(watcher: Watcher): bool =
  ## Whether a watched file changed since the last run started.
  stamps(watcher.files) != watcher.stamps

proc run*(watcher: var Watcher): Outcome =
  ## Runs the .flo file once and prints the status line. The modification
  ## times are taken before the run, so a change during it brings one more.
  if watcher.runs > 0:
    printOut("")
  inc watcher.runs
  let before = stamps(watcher.files)
  var found: seq[string]
  try:
    result = run(watcher.flowerFile, watcher.verify, true, found)
  except CatchableError as e:
    # A missing or unreadable binary, say: wait for the next change.
    printErr(e.msg)
    result = oFailed
  var files = @[watcher.files[0]]
  if result == oFailed:
    # The run may have stopped before it found all of its files.
    for file in watcher.files:
      if file notin files:
        files.add file
  for file in found:
    if file notin files:
      files.add file
  var stamps: seq[Time]
  for file in files:
    let known = watcher.files.find(file)
    stamps.add(if known >= 0: before[known] else: stamp(file))
  watcher.files = files
  watcher.stamps = stamps
  let outcome = case result
    of oFine: "ok"
    of oNotVerified: "doesn't verify"
    of oFailed: "failed, out/ unchanged"
  printOut(now().format("HH:mm:ss") & " " & outcome & ", watching " & extractFilename(watcher.flowerFile))

proc settle(watcher: Watcher) =
  ## Waits until the watched files stop changing.
  var last = stamps(watcher.files)
  while true:
    sleep(pollInterval)
    let current = stamps(watcher.files)
    if current == last:
      return
    last = current

proc watch*(flowerFile: string, verify: bool) =
  ## Runs the .flo file, then again after every change, until interrupted.
  var watcher = newWatcher(flowerFile, verify)
  discard watcher.run()
  stdout.flushFile()
  while true:
    sleep(pollInterval)
    if watcher.changed:
      watcher.settle()
      discard watcher.run()
      # Shows the run at once when the output goes to a pipe or a file.
      stdout.flushFile()
