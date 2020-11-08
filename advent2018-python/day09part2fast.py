#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/8

Well shit, I thought Python lists were implemented as linked lists.
Gotta use a deque, which is actually a doubly linked list.

This isn't correct, but it's close and much much faster.

"""

inputstr = """
9 players; last marble is worth 25 points: high score is 32
10 players; last marble is worth 1618 points: high score is 8317
476 players; last marble is worth 71657 points
13 players; last marble is worth 7999 points: high score is 146373
476 players; last marble is worth 7165700 points
17 players; last marble is worth 1104 points: high score is 2764
21 players; last marble is worth 6111 points: high score is 54718
30 players; last marble is worth 5807 points: high score is 37305
"""

import re, collections, itertools
Node = collections.namedtuple('Node', 'a children metadata')

regex = re.compile('^(\d+) players; last marble is worth (\d+) points')

def go(num_players, last_marble):
    marble_gen = itertools.count(0)
    player_gen = itertools.cycle(range(num_players))
    scores = [ 0 for i in range(num_players) ]
    print(num_players, last_marble)
    marbles = collections.deque() 
    marbles.append(next(marble_gen))
    for turn in range(last_marble):
        if turn % 100000 == 0:
            print(turn, last_marble)
        player_idx = next(player_gen)

        a_new_marble = next(marble_gen)
        if a_new_marble % 23 == 0:
            marbles.rotate(-7)
            old_marble = marbles.popleft()
            print("player", player_idx, old_marble)
            marble_score = a_new_marble + old_marble 
            scores[player_idx] += marble_score
        else:
            print("@", marbles)
            marbles.rotate(2)
            print("?", marbles)
            marbles.appendleft(a_new_marble)
            print("!", marbles)
            print()

    print(scores)
    print(max(scores))

def main():
    for l in inputstr.strip().splitlines():
        num_players, last_marble = map(int, regex.match(l).groups())
        go(num_players, last_marble)
        break

if __name__ == '__main__':
    main()
