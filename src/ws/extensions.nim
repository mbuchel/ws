import miniz
import sugar

type
  ## The compression level for the permessage deflate extension.
  # TODO: This can also be an integer from 0-9
  PermessageDeflateLevel* = enum
    pdlZNoCompression, pdlZBestSpeed,
    pdlZBestCompression, pdlZDefaultCompression

  ## How much memory the compression can allocate
  # TODO: This can also be an integer from 1-9
  # TODO: Use this as well in compression and decompression
  PermessageDeflateMemlevel* = enum
    pdmZMinMemlevel, pdmZMaxMemlevel,
    pdmZDefaultMemlevel

  ## Compression strategy
  # TODO: Use this as well in compression and decompression
  PermessageDeflateStrategy* = enum
    pdsZFiltered, pdsZHuffmanOnly,
    pdsZRLE, pdsZFixed, pdsZDefaultStrategy

  ## Currently the only extension supported is the permessage-deflate
  WebSocketExtension* = enum
    wsePermessageDeflate

  # TODO: Make this more robust and handle better negotiations
  Extension* = ref object
    case ext*: WebSocketExtension
    of wsePermessageDeflate:
      level*: PermessageDeflateLevel
      memlevel*: PermessageDeflateMemlevel
      strategy*: PermessageDeflateStrategy

  Extensions* = seq[Extension]

proc `$`*(e: Extension): string =
  result = "Extension:\n\tkind: " & $e.ext & "\n\tlevel: " & $e.level &
    "\n\tmemlevel: " & $e.memlevel & "\n\tstrategy: " & $e.strategy

proc pndExt*(level: PermessageDeflateLevel = pdlZDefaultCompression,
             memlevel: PermessageDeflateMemlevel = pdmZDefaultMemlevel,
             strategy: PermessageDeflateStrategy = pdsZDefaultStrategy):
               Extension =
    result = Extension(
      ext: wsePermessageDeflate, level: level,
      memlevel: memlevel, strategy: strategy
    )

proc createHeader*(e: Extension): string =
  case e.ext:
    of wsePermessageDeflate:
      # TODO: Handle different parameters in the permessage deflate
      result = "permessage-deflate"

# May move this into another file later
proc permessageDeflateCompress*(text: string, e: Extension): string =
  let compressText: (int) -> string = (x: int) => compress(
    text, level = x
  )
  case e.level:
    of pdlZNoCompression:
      result = compressText(Z_NO_COMPRESSION)
    of pdlZBestSpeed:
      result = compressText(Z_BEST_SPEED)
    of pdlZBestCompression:
      result = compressText(Z_BEST_COMPRESSION)
    of pdlZDefaultCompression:
      result = compressText(Z_DEFAULT_COMPRESSION)

proc permessageDeflateDecompress*(text: string): string =
  uncompress(text)
