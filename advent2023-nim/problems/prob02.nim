
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
Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
"""

let test2_input = """

"""

type
  Game = object
    num: int
    rounds: seq[Round]
  Round = object
    r: int
    g: int
    b: int

proc parse_round(s: string): Round =
  var t = initTable[string, int]()
  # some way to zip this into a table in one line?
  for num_color in s.split(", "):
    let bits = num_color.split(" ") 
    t[bits[1]] = bits[0].parseInt()
  Round(
    r: t.getOrDefault("red", 0),
    g: t.getOrDefault("green", 0),
    b: t.getOrDefault("blue", 0)
  )

proc parse_game(s: string): Game =
  let halves = s.split(": ", maxsplit=1)
  return Game(
    num: halves[0].substr(5).parseInt(),
    rounds: halves[1].split("; ").map(parse_round)
  )

proc is_prob1_valid_round(r: Round): bool =
  r.r <= 12 and r.g <= 13 and r.b <= 14

proc is_prob1_valid_game(g: Game): bool =
  g.rounds.all(is_prob1_valid_round)

proc prob1(rows: seq[string]): int =
  rows
    .map(parse_game)
    .filter(is_prob1_valid_game)
    .map(g => g.num)
    .sum()

proc prob2_sub(game: Game): int =
  let r = game.rounds.map(r => r.r).filter(i => i > 0).max()
  let g = game.rounds.map(r => r.g).filter(i => i > 0).max()
  let b = game.rounds.map(r => r.b).filter(i => i > 0).max()
  return (r * g * b)
    
proc prob2(rows: seq[string]): int =
  rows
    .map(parse_game)
    .map(prob2_sub)
    .sum()

check 8 == test_input
  .strip()
  .splitLines()
  .prob1()

check 2505 == "./input/prob02.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob1()

check 2286 == test_input
  .strip()
  .splitLines()
  .prob2()

check 2505 == "./input/prob02.txt"
  .readFile()
  .strip()
  .splitLines()
  .prob2()


