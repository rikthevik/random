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
    for checky in range(1, 301):
        print("y=", checky)
        for checkx in range(1, 301):
            totals[(checkx, checky, 1)] = cells[(checkx, checky)]
            for sqsize in range(2, 302 - max(checkx, checky)):
#                 print(checkx, checky, sqsize)
#                 print("adding value from", checkx+sqsize-1, checky+sqsize-1)
#                 print("adding horiz_values", [ (checkx+i, checky+sqsize-1) for i in range(sqsize-1) ])
#                 print("adding vert_values", [ (checkx+sqsize-1, checky+i) for i in range(sqsize-1) ])
                totals[(checkx, checky, sqsize)] = (
                    totals[(checkx, checky, sqsize-1)] + 
                    cells[(checkx+sqsize-1, checky+sqsize-1)] + 
                    sum( cells[(checkx+i, checky+sqsize-1)] for i in range(sqsize-1) ) +
                    sum( cells[(checkx+sqsize-1, checky+i)] for i in range(sqsize-1) )
                )

    for s in sorted(totals.items(), key=lambda t: t[1], reverse=True)[:10]:
        print(s)


def main():
    for l in inputstr.strip().splitlines():
        go(int(l))
        break

if __name__ == '__main__':
    main()
