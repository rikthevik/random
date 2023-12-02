
import std/algorithm
import std/strutils
import std/sequtils
import std/sugar
import unittest
import eLib
import std/tables

echo "--------------------------------"


let test_input = """
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""

let test2_input = """

"""


proc prob1(rows: seq[string]): int =
  rows
    .len()

check 8 == test_input
  .strip()
  .splitLines()
  .prob1()

# check 56465 == "./input/prob01.txt"
#   .readFile()
#   .strip()
#   .splitLines()
#   .prob1()

