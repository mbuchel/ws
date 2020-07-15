import asyncdispatch, ws, zip/zlib

echo uncompress(compress("hello", stream=RAW_DEFLATE), stream=RAW_DEFLATE)

proc main() {.async.} =
  let e = pndExt(
    level = pdlZDefaultCompression,
    memlevel = pdmZDefaultMemlevel,
    strategy = pdsZDefaultStrategy
  )
  echo e
  var ws = await newWebSocket("ws://127.0.0.1:9000", extensions = @[e])
  await ws.send("Hi, how are you?")
  let response = await ws.receiveStrPacket()
  echo uncompress(response, stream=RAW_DEFLATE)
  ws.close()

waitFor main()

try:
  waitFor main()
except:
  echo "Compliance test failed"
