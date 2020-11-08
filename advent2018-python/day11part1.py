#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """


inputstr = """
6303
18
8
42
"""

import re, collections, itertools
Node = collections.namedtuple('Node', 'a children metadata')

regex = re.compile('^(\d+) players; last marble is worth (\d+) points')

def go(serial):
    print("serial", serial)
    cells = {}
    for y in range(1, 301):
        for x in range(1, 301):
            rack_id = x + 10
            power_level = ((((rack_id * y + serial) * rack_id) % 1000) // 100) - 5
            cells[(x, y)] = power_level

    totals = {}
    for checky in range(1, 301-3):
        for checkx in range(1, 301-3):
            totals[(checkx, checky)] = sum( cells[(checkx+i, checky+j)] for (i, j) in itertools.product(range(3), range(3)) )

    for s in sorted(totals.items(), key=lambda t: t[1], reverse=True)[:10]:
        print(s)


def main():
    for l in inputstr.strip().splitlines():
        go(int(l))
        break

if __name__ == '__main__':
    main()
