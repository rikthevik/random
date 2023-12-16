
import std/algorithm
import std/strutils
import std/sequtils
import std/sets
import std/math
import std/sugar
import unittest
import eLib
import std/tables
import std/nre

echo "--------------------------------"


let test_input = """
Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11"""

type
  Row = object
    wins: seq[int]
    haves: seq[int]

proc parse_ints(s: string): seq[int] =
  s
    .strip()
    .split(re" +")
    .map(s => s.parseInt())

proc parse_row(row: string): Row =
  let bits = row.split(re" *[:|] *")
  return Row(
    wins: bits[1].parse_ints(),
    haves: bits[2].parse_ints(),
  )

proc score_for_matches(matches: int): int =
  if matches <= 0:
    return 0
  else: 
    return 2 ^ (matches - 1)
  
proc matches_for_row(row: Row): int =
  return toHashSet(row.wins)
    .intersection(toHashSet(row.haves))
    .len()

proc prob1(rows: seq[string]): int =
  return rows
    .map(parse_row)
    .map(matches_for_row)
    .map(score_for_matches)
    .inspect()
    .sum()

check 13 == test_input
  .strip()
  .splitLines()
  .inspect()
  .prob1()

check 536202 == "./input/prob04.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob1()

# check 467835 == test_input
#   .strip()
#   .splitLines()
#   .prob2()

# check 78272573 == "./input/prob04.txt"
#   .readFile()
#   .strip()
#   .splitLines()
#   .prob2()


