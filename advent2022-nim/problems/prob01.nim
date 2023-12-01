
import std/strutils
import std/sequtils
import unittest

func sum(s: seq[int]): int =
  s.foldl(a + b)

proc prob1_imperative(rows: seq[string]): int =
  # Writing this in a (highly coupled) imperative style.
  var acc = newSeq[string]()
  var maxval = -1
  for row in rows:
    if row == "":
      maxval = max(maxval, sum(map(acc, parseInt)))
      acc.setLen(0)
    else:
      acc.add(row)
  maxval
  
let test1_input = """
1000
2000
3000

4000

5000
6000

7000
8000
9000

10000
"""

check 24000 == prob1_imperative(splitLines(test1_input))
check 69177 == prob1_imperative(splitLines(readFile("./inputs/prob01.txt")))
