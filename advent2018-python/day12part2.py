#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """


inputstr = """
initial state: #..#.#..##......###...###

...## => #
..#.. => #
.#... => #
.#.#. => #
.#.## => #
.##.. => #
.#### => #
#.#.# => #
#.### => #
##.#. => #
##.## => #
###.. => #
###.# => #
####. => #
"""

inputstr = """
initial state: ##.###.......#..#.##..#####...#...#######....##.##.##.##..#.#.##########...##.##..##.##...####..####

#.#.# => #
.##.. => .
#.#.. => .
..### => #
.#..# => #
..#.. => .
####. => #
###.. => #
#.... => .
.#.#. => #
....# => .
#...# => #
..#.# => #
#..#. => #
.#... => #
##..# => .
##... => .
#..## => .
.#.## => #
.##.# => .
#.##. => #
.#### => .
.###. => .
..##. => .
##.#. => .
...## => #
...#. => .
..... => .
##.## => .
###.# => #
##### => #
#.### => .
"""


import re, collections, itertools
Node = collections.namedtuple('Node', 'a children metadata')

regex = re.compile('^(\d+) players; last marble is worth (\d+) points')
    
    
def main():
    lines = inputstr.strip().splitlines()
    initial_state = lines[0][15:]
    rules = [ s.split(" => ") for s in lines[2:] ]
    rules = [ (m, r) for m, r in rules if r == '#' ]

    print("INITIAL", initial_state)

    # Let's try a set of all of the potted indexes.
    state = set( i for i, c in enumerate(initial_state) if c == '#' )

    generations = 50000000000

    # closed form, yeah!
    diffs = [-57, -52, -47, -38, -33, -16, -10, -5, 0, 5, 14, 20, 30, 36, 42, 47, 53, 59, 66, 71, 77, 82, 90]
    total = 23 * generations + sum(diffs)
    total = 23 * (generations+1) + 434
    print(total)
    return

    for r in range(1, generations+1):
        if r % 10000 == 0:
            print(r)
        print("minstate", min(state), "maxstate", max(state))
        print("round", r, "size", len(state), sorted([ s - r for s in state ]), "SUM=", sum(state) )
        newstate = set()
        # print("!!", min(state.keys()), max(state.keys()))
        for i in range(min(state)-4, max(state)+4):
            s = "".join('#' if i+j in state else '.' for j in range(-2, 3))
            for match, result in rules:
                if match == s:
                    newstate.add(i)
                    break
        state = newstate
        
    print(sum(state)) 



if __name__ == '__main__':
    main()
