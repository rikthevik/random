
import std/algorithm
import std/strutils
import std/sequtils
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
  Point = object
    x: int
    y: int
  Grid = object
    w: int
    h: int
    data: Table[Point, char]
  
proc load_points(rows: seq[string]): Table[Point, char] =
  # can we load this up in a single list comprehension?
  var t = initTable[Point, char]()
  for y, row in rows.pairs():
    for x, c in row:
      t[Point(x:x, y:y)] = c
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

proc has_adjacent_symbol(g: Grid, mx: int, my: int): bool =
  # hmm how do list comprehensions work
  for x in mx-1..mx+1:
    for y in my-1..my+1:
      if is_symbol(g.get(x, y)):
        return true
  return false

proc find_numbers(g: Grid): seq[int] =
  var valid_numbers: seq[int] = @[]
  var acc = ""
  var adj_symbol = false
  for y in 0..g.h:
    for x in 0..g.w:
      let c = g.get(x, y)
      if is_digit(c):
        acc = acc & $c
        adj_symbol = adj_symbol or has_adjacent_symbol(g, x, y)
        # echo "acc=" & c & " adj_symbol=" & $adj_symbol
      else:
        if acc != "" and adj_symbol:
          valid_numbers.add(acc.parseInt())
        acc = ""
        adj_symbol = false
    acc = ""
    adj_symbol = false
    # break
  return valid_numbers


proc prob1(rows: seq[string]): int =
  rows
    .load_grid()
    .find_numbers()
    .inspect()
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

# check 2286 == test_input
#   .strip()
#   .splitLines()
#   .prob2()

# check 2505 == "./input/prob02.txt"
#   .readFile()
#   .strip()
#   .splitLines()
#   .prob2()


