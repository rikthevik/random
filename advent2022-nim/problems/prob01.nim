import std/algorithm
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
  
proc prob2_imperative(rows: seq[string]): int =
  # Because we did prob1 in a coupled style, we can't reuse too much.
  var summed = newSeq[int]()
  var acc = newSeq[string]()
  for row in rows:
    if row == "":
      summed.add(sum(map(acc, parseInt)))
      acc.setLen(0)
    else:
      acc.add(row)
  summed.sort(Descending)
  sum(summed[0..2])


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

check 24000 == test1_input
  .splitLines()
  .prob1_imperative()
check 69177 == readFile("./inputs/prob01.txt")
  .splitLines()
  .prob1_imperative()

check 45000 == test1_input
  .splitLines()
  .prob2_imperative()
check 207456 == readFile("./inputs/prob01.txt")
  .splitLines()
  .prob2_imperative()

# Thought for later
# iterator splitWhile[T](items: seq[T], predicate: proc(a: T): bool): seq[seq[T]] =
#   var acc = newSeq[T]()
#   for item in items:
#     if predicate(item):
#       acc.add(item)
#     else:
#       yield acc
#       acc.setLen(0)
