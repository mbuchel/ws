#
# Author: Michael Buchel
# Reason: Compression library tests.
#
import base64
import sequtils
import strutils
import sugar
import zip/zlib

import tables
import unittest

suite "Zlib Deflate":
  test "Server response":
    let
      response = "Hi, how are you?"
      encoded = @[
        242, 200, 212, 81, 200, 200,
        47, 87, 72, 44, 74, 85, 168,
        204, 47, 181, 7, 0
      ]

    var
      encodedStr = (map(encoded, (x: int) => char(x)))
    echo encodedStr
    echo len(encodedStr)
