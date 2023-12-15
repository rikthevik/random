
import std/algorithm
import std/strutils
import std/sequtils
import std/sets
import std/sugar
import unittest
import eLib
import std/tables
import std/nre

echo "--------------------------------"


let test_input = """
467..114..
...*......
..35..633.
......#...
617*......
.....+.58.
..592.....
......755.
...$.*....
.664.598.."""

let test2_input = """

"""

type
  Grid = object
    w: int
    h: int
    data: Table[Point, char]
  
proc load_points(rows: seq[string]): Table[Point, char] =
  # can we load this up in a single list comprehension?
  var t = initTable[Point, char]()
  for y, row in rows.pairs():
    for x, c in row:
      t[newPoint(x, y)] = c
  return t

proc load_grid(rows: seq[string]): Grid =
  Grid(
    w: rows[0].len(),
    h: rows.len(),
    data: load_points(rows),
  )

proc get(g: Grid, x: int, y: int): char =
  g.data.getOrDefault(Point(x: x, y: y), '.')
  
proc inspect(g: Grid): Grid =
  for y in 0..g.h:
    for x in 0..g.w:
      stdout.write(g.get(x, y))
    echo("")
  return g

proc is_digit(c: char): bool =
  return c >= '0' and c <= '9'

proc is_symbol(c: char): bool =
  # echo c & " :: " & $(not (is_digit(c) or c == '.'))
  return not (is_digit(c) or c == '.')

proc adjacent_numbers(table_map: Table[Point, int], p: Point): seq[int] =
  # hmm how do list comprehensions work
  var found_numbers = initHashSet[int]()
  for x in p.x-1..p.x+1:
    for y in p.y-1..p.y+1:
      let num = table_map.getOrDefault(newPoint(x, y), -1)
      if num >= 0:
        found_numbers.incl(num)
  echo $p & " has points " & $found_numbers 
  found_numbers
    .toSeq()

proc find_numbers(g: Grid): Table[Point, int] =
  var number_map = initTable[Point, int]()
  var current_points: seq[Point] = @[]
  var acc = ""
  for y in 0..g.h: # go one step past the end
    for x in 0..g.w:
      let c = g.get(x, y)
      if is_digit(c):
        acc = acc & $c
        current_points.add(newPoint(x, y))
        # echo "acc=" & c & " adj_symbol=" & $adj_symbol
      else:
        if acc != "":
          for p in current_points:
            number_map[p] = acc.parseInt()
            echo "writing " & acc & " to " & $p
          current_points = @[]
          acc = ""
    # break
    
  return number_map


proc prob1(rows: seq[string]): int =
  let grid = rows
    .load_grid()

  let number_map = grid
    .find_numbers()

  return grid.data
    .pairs()
    .toSeq()
    .filter(kv => is_symbol(kv[1]))
    .inspect()
    .map(kv => adjacent_numbers(number_map, kv[0]))
    .inspect()
    .flatten()
    # .toHashSet()  # when you assume, you make an ass of you and me
    # .toSeq()      # and you get the answer wrong
    .sum()

proc prob2(rows: seq[string]): int =
  let grid = rows
    .load_grid()

  let number_map = grid
    .find_numbers()

  return grid.data
    .pairs()
    .toSeq()
    .filter(kv => kv[1] == '*')
    .map(kv => adjacent_numbers(number_map, kv[0]))
    .filter(nums => nums.len() == 2)
    .map(nums => nums[0] * nums[1])
    .sum()

check 4361 == test_input
  .strip()
  .splitLines()
  .prob1()

check 536202 == "./input/prob03.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob1()

check 467835 == test_input
  .strip()
  .splitLines()
  .prob2()

check 78272573 == "./input/prob03.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob2()


