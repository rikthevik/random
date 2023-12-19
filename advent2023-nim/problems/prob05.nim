
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
  Range = object
    dst: int
    src: int
    len: int
    diff: int
  Prob = object
    seeds: seq[int]
    maps: TableRef[string, seq[Range]]

proc load_range(s: string): Range =
  let ints = s.split(" ").map(i => i.parseInt())
  Range(dst: ints[0], src: ints[1], len: ints[2], diff: ints[0] - ints[1])

proc load_prob(rows: seq[string]): Prob =
  let row_chunks = split_rows_on_empty(rows)
  let seeds = parse_ints(row_chunks[0][0].split(re": ")[1])
  var maps = newTable[string, seq[Range]]()
  for chunk in row_chunks[1..^1]:
    let name = chunk[0].split(re" ")[0]
    let ranges = chunk[1..^1].map(load_range)
    maps[name] = ranges
  return Prob(seeds: seeds, maps: maps)

proc next_val(val: int, ranges: seq[Range]): int =
  for r in ranges:
    if val >= r.src and (val - r.src) < r.len:
      return val + r.diff
  return val

let map_keys = @["seed-to-soil", "soil-to-fertilizer", "fertilizer-to-water", "water-to-light", "light-to-temperature", "temperature-to-humidity", "humidity-to-location"]

proc prob1(rows: seq[string]): int =
  let prob = load_prob(rows).inspect()
  var locations = collect(newSeq):
    for seed in prob.seeds:
      var val = seed
      for map_key in map_keys:
        val = next_val(val, prob.maps[map_key])
        # echo "after " & map_key & " val => " & $val
      val
  return locations.min()
    
proc find_seed_pairs(l: seq[int]): seq[(int, int)] =
  var s = newSeq[(int, int)]()
  var i = 0
  while i < l.len():
    s.add((l[i], l[i+1]))
    i += 2
  return s

proc prob2(rows: seq[string]): int =
  # naive solution to start
  let prob = load_prob(rows).inspect()
  var minval = high(int)
  for (seedmin, seedlen) in find_seed_pairs(prob.seeds).inspect():
    for seed in seedmin..(seedmin+seedlen-1):
      var val = seed
      for map_key in map_keys:
        val = next_val(val, prob.maps[map_key])
        # echo "after " & map_key & " val => " & $val
      minval = min(minval, val)
  return minval
  

check 35 == test_input
  .strip()
  .splitLines()
  .prob1()

check 484023871 == "./input/prob05.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob1()

check 46 == test_input
  .strip()
  .splitLines()
  .prob2()

# check 123 == "./input/prob05.txt"
#   .readFile()
#   .strip()
#   .splitLines()
#   .prob2()


