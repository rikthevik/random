import std/algorithm
import std/strutils
import std/sequtils
import unittest


func sum*(s: seq[int]): int =
  s.foldl(a + b)