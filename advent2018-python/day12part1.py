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
    
    
def display_state(r, state):
    print("%02d: (%04d)" % (r, sum(state)), end='')
    for i in range(-40, 100):
        print('#' if i in state else '.', end='')
    print()

def main():
    lines = inputstr.strip().splitlines()
    initial_state = lines[0][15:]
    rules = [ s.split(" => ") for s in lines[2:] ]
    rules = [ (m, r) for m, r in rules if r == '#' ]

    print("INITIAL", initial_state)

    # Let's try a set of all of the potted indexes.
    state = set( i for i, c in enumerate(initial_state) if c == '#' )
    display_state(0, state)

    last = 0
    for r in range(1, 500000):
        newstate = set()
        # print("!!", min(state.keys()), max(state.keys()))
        print("now=", sum(state), "last=", last, "diff=", (sum(state)-last))
        
        if r > 200:
            predicted = 23 * r + 434
            assert predicted == sum(state)

        last = sum(state)


        for i in range(min(state)-4, max(state)+4):
            s = "".join('#' if i+j in state else '.' for j in range(-2, 3))
            for match, result in rules:
                if match == s:
                    newstate.add(i)
                    break
        state = newstate
        display_state(r, state)
        
    print(sum(state)) 



if __name__ == '__main__':
    main()
