import std/algorithm
import std/strutils
import std/sequtils
import unittest


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