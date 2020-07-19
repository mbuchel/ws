#
# Author: Michael Buchel
# Reason: Huffman tree encoder/decoder.
#
import heapqueue
import tables
import options
import sequtils
import sugar

type
  ## Huffman encoded value, this is simpler than the other approach.
  HuffCode* = seq[int]

  ## Node for the huffman tree.
  HuffNode* = ref object
    freq: int
    case isLeaf: bool
    of true:
      c: char
    else:
      left: HuffNode
      right: HuffNode

  HuffTree* = object
    topNode: Option[HuffNode]
    edict: Table[char, HuffCode]
    ddict: Table[char, char]

proc `<`(a, b: HuffNode): bool =
  a.freq <= b.freq

proc `$`(hc: HuffCode): string =
  result = ""
  for symbol in hc:
    result &= $symbol

proc `$`*(t: HuffTree): string =
  result = $t.edict

proc createQueue(ct: CountTable[char]): HeapQueue[HuffNode] =
  result = initHeapQueue[HuffNode]()
  for k, v in pairs(ct):
    let node: HuffNode = HuffNode(freq: v, isLeaf: true, c: k)
    push(result, node)

proc createInternalNode(hq: var HeapQueue[HuffNode]): Option[HuffNode] =
  if len(hq) == 0:
    result = none(HuffNode)
  elif len(hq) == 1:
    result = some(pop(hq))
  else:
    let
      lower = pop(hq)
      higher = pop(hq)
      node = HuffNode(
        freq: lower.freq + higher.freq, isLeaf: false, left: lower,
        right: higher
      )
    push(hq, node)
    result = createInternalNode(hq)

proc convertEncoded*(hc: HuffCode): int =
  result = 0
  for i in hc:
    result = (result shl 1) xor i
   
proc generateCodes(node: HuffNode, edict: var Table[char, HuffCode],
                   ddict: var Table[char, char], encoded: HuffCode = @[]) =
  if node.isLeaf:
    edict[node.c] = encoded
    ddict[char(convertEncoded(encoded))] = node.c
  else:
    let
      left = node.left
      right = node.right

    generateCodes(left, edict, ddict, @[0] & encoded)
    generateCodes(right, edict, ddict, @[1] & encoded)

proc createHuffmanTree*(s: string): HuffTree =
  var queue: HeapQueue[HuffNode] = createQueue(toCountTable(s))

  result.topNode = createInternalNode(queue)
  result.edict = initTable[char, HuffCode]()
  result.ddict = initTable[char, char]()

  if isSome(result.topNode):
    let node = get(result.topNode)
    if node.isLeaf:
      generateCodes(node, result.edict, result.ddict, @[1])
    else:
      generateCodes(node, result.edict, result.ddict)

proc huffmanEncode*(s: string, tree: HuffTree): string =
  result = ""
  for i in s:
    result &= char(convertEncoded(tree.edict[i]))

proc huffmanDecode*(s: string, tree: HuffTree): string =
  result = ""
  for i in s:
    result &= tree.ddict[i]
