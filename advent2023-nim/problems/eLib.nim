import std/algorithm
import std/strutils
import std/sequtils
import std/re
import unittest
import std/sugar


func sum*(s: seq[int]): int =
  s.foldl(a + b)

proc inspect*[T](i: T): T =
  echo $i
  return i

type
  Point* = object
      x*: int
      y*: int

func newPoint*(x: int, y: int): Point =
  Point(x: x, y: y)

# yoinked from github
proc flatten*[T](a: seq[seq[T]]): seq[T] =
  var aFlat = newSeq[T](0)
  for subseq in a:
    aFlat &= subseq
  return aFlat

proc parse_ints*(s: string): seq[int] =
  s
    .strip()
    .split(re" +")
    .map(s => s.parseInt())

proc split_rows_on_empty*(rows: seq[string]): seq[seq[string]] =
  # do this with iterators?
  var total = newSeq[seq[string]]()
  var acc = newSeq[string]()
  for r in rows:
    if r == "":
      total.add(acc)
      acc = newSeq[string]()
    else:
      acc.add(r)
  if acc.len() > 0:
    total.add(acc)
  return total

check @[@["a"], @["b"]] == split_rows_on_empty(@["a", "", "b"])
check @[@["a"], @["b"]] == split_rows_on_empty(@["a", "", "b", ""])
check @[@["a"], @["b", "c"]] == split_rows_on_empty(@["a", "", "b", "c"])

