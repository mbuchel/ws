import asyncdispatch, ws
import sequtils, sugar

proc main() {.async.} =
  let e = pndExt(
    level = pdlZDefaultCompression,
    memlevel = pdmZDefaultMemlevel,
    strategy = pdsZDefaultStrategy
  )
  echo e
  var ws = await newWebSocket("ws://127.0.0.1:9000", extensions = @[])
  await ws.send("Hi, how are you?")
  var response = await ws.receiveStrPacket()
  let data = @response
  echo response
  echo map(data, (x: char) => ord(x))
  ws.close()

try:
  waitFor main()
except:
  echo "Compliance test failed"
