
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
seeds: 79 14 55 13

seed-to-soil map:
50 98 2
52 50 48

soil-to-fertilizer map:
0 15 37
37 52 2
39 0 15

fertilizer-to-water map:
49 53 8
0 11 42
42 0 7
57 7 4

water-to-light map:
88 18 7
18 25 70

light-to-temperature map:
45 77 23
81 45 19
68 64 13

temperature-to-humidity map:
0 69 1
1 0 69

humidity-to-location map:
60 56 37
56 93 4"""

type
  Row = object
    pass


proc parse_row(row: string): Row =
  let bits = row.split(re" *[:|] *")
  return Row(
    wins: bits[1].parse_ints(),
    haves: bits[2].parse_ints(),
  )

proc prob1(rows: seq[string]): int =
  return rows
    .map(parse_row)
    .map(matches_for_row)
    .map(score_for_matches)
    .inspect()
    .sum()

proc prob2(str_rows: seq[string]): int =
  let rows = str_rows.map(parse_row)
  var cards_per = collect(newSeq): (for r in rows: 1)
  echo ""
  echo $cards_per
  for i in 0..<rows.len():
    for w in 1..matches_for_row(rows[i]):
      cards_per[i+w] += cards_per[i]
    echo $cards_per
  return cards_per.sum()

check 13 == test_input
  .strip()
  .splitLines()
  .inspect()
  .prob1()

check 26426 == "./input/prob05.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob1()

check 30 == test_input
  .strip()
  .splitLines()
  .prob2()

check 6227972 == "./input/prob05.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob2()


