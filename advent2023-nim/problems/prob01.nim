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
7pqrstsixteen
"""

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
  # recursive algorithm, look for matching characters and then keep going
  if s == "":
    # base case, we're done
    return @[]
  else:
    # we could write this as pattern matching in elixir
    for start, val in digit_conversions:
      if s.startsWith(start):
        # only hop forward one char, in case we get e.g eightwo, which should produce 8 and 2.
        let remaining = s.substr(1)
        return @[val] & inner_find_more_digits_in_row(remaining)
    # didn't find anything, discard the first character and keep going
    return inner_find_more_digits_in_row(s.substr(1))

proc find_more_digits_in_row(s: string): seq[int] =
  inner_find_more_digits_in_row(s)

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

check 55902 == "./input/prob01.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob2()
