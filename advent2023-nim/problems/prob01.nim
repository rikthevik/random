import std/algorithm
import std/strutils
import std/sequtils
import std/sugar
import unittest
import eLib
import std/tables

echo "--------------------------------"


let test_input = """
1abc2
pqr3stu8vwx
a1b2c3d4e5f
treb7uchet
"""

let test2_input = """
two1nine
eightwothree
abcone2threexyz
xtwone3four
4nineeightseven2
zoneight234
7pqrstsixteen"""

proc find_digits_in_row(s: string): seq[int] =
  s
    .filter(isDigit)
    .map(c => parseInt($c))

proc first_and_last_digits_to_int(ints: seq[int]): int =
  ints[0] * 10 + ints[^1]

proc prob1(rows: seq[string]): int =
  rows
    .map(find_digits_in_row)
    .map(first_and_last_digits_to_int)
    .sum()


let digit_conversions = {
  "0": 0,
  "zero": 0,
  "1": 1,
  "one": 1,
  "2": 2,
  "two": 2,
  "3": 3,
  "three": 3,
  "4": 4,
  "four": 4,
  "5": 5,
  "five": 5,
  "6": 6,
  "six": 6,
  "7": 7,
  "seven": 7,
  "8": 8,
  "eight": 8,
  "9": 9,
  "nine": 9,
}.toTable


proc inner_find_more_digits_in_row(s: string): seq[int] =
  if s == "":
    return @[]
  else:
    for start, val in digit_conversions:
      if s.startsWith(start):
        let remaining = s.substr(start.len())
        return @[val] & inner_find_more_digits_in_row(remaining)
    return inner_find_more_digits_in_row(s.substr(1))

proc find_more_digits_in_row(s: string): seq[int] =
  let r = inner_find_more_digits_in_row(s)
  echo "find_more_digits " & s & " :: " & $r
  return r


proc prob2(rows: seq[string]): int =
  rows
    .map(find_more_digits_in_row)
    .map(first_and_last_digits_to_int)
    .sum()


check 142 == test_input
  .strip()
  .splitLines()
  .prob1()

check 56465 == "./input/prob01.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob1()

check 281 == test2_input
  .strip()
  .splitLines()
  .prob2()

check 55929 == "./input/prob01.txt"
  .readFile()
  .strip()
  .inspect()
  .splitLines()
  .prob2()
