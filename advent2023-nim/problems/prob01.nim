import std/algorithm
import std/strutils
import std/sequtils
import std/sugar
import unittest
import eLib

echo "--------------------------------"


let test_input = """
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"""

proc find_digits_in_row(s: string): seq[int] =
  s
    .filter(isDigit)
    .map(c => parseInt($c))

proc first_and_last_digits_to_int(ints: seq[int]): int =
  echo $ints
  ints[0] * 10 + ints[ints.len()-1]

proc prob1(rows: seq[string]): int =
  rows
    .map(find_digits_in_row)
    .map(first_and_last_digits_to_int)
    .sum()

check 142 == test_input
  .strip()
  .splitLines()
  .prob1()

check 142 == "./input/prob01.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob1()

echo "DONE"
