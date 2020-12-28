#!/usr/bin/env python3.8

# I know I worked most of this out in Elixir, but
# boy does Python make some things easy.  Or at least
# my thoughts have been shaped using it.

import collections, time

def part1(cupstr, times):
    cups = collections.deque()
    for s in cupstr.strip():
        cups.append(int(s))

    # print "=" * 80
    # print cups
    
    cups = play(cups, times, max(cups))
    cups = list(cups)
    idx = cups.index(1)
    result = cups[idx+1:] + cups[:idx]
    # print "".join(map(str, result))
    resultstr = "".join(map(str, result))
    print("part1 %r => %r" % (cupstr, resultstr))
    return resultstr

def part2(cupstr, times):
    cups = collections.deque()
    for s in cupstr.strip():
        cups.append(int(s))
    cups.extend(range(max(cups), 1000001))

    max_val = 1000000
    cups = play(cups, times, max_val)

    idx = cups.index(1)
    cups.rotate(-idx)
    cups.popleft() # get the 1 out of there
    return cups.popleft() * cups.popleft()



def play(cups, times, max_val):
    t = 0
    restlen = len(cups) - 3
    t0 = time.time()
    while t < times:
        if t % 1000 == 1:
            print("move", t, "elapsed=", time.time() - t0)
            t0 = time.time()
        # print("move", t, ", cups=", cups)
        c = cups.popleft()
        pickup = [ cups.popleft() for i in range(3) ]
        # print("c=", c, "pickup=", pickup)
        
        dest = find_dest(c-1, pickup, max_val)
        # print("dest=", dest)

        # Old method was to rotate through the deque to find c
        # In python3.5 they added a .index() method that
        # returns the index of the element, hopefully without 
        # moving the list around too much.  Then it should be
        # one rotation - but how does that perform internally?

        idx = cups.index(dest)
        [ cups.insert(idx+1, p) for p in reversed(pickup) ]

        cups.append(c)

        # Bunch of rotation stuff
        # rotate_right = restlen - idx - 1
        # print("FOUND IDX", idx, cups, "rotate_right=", rotate_right)
        # cups.rotate(+rotate_right)
        # print("AFTER ROTATE", cups)
        # cups.extend(pickup)
        # print("AFTER EXTEND", cups)
        # cups.rotate(-(rotate_right+1))
        # print("AFTER 2ROTATE", cups)

        # print(" ", cups)
        # print()
        t += 1
        
    return cups


def find_dest(c, pickup, max_val):
    if c == 0:
        return find_dest(max_val, pickup, max_val)
    elif c in pickup:
        return find_dest(c - 1, pickup, max_val)
    else:
        return c


assert part1("389125467", 1) == "54673289"
assert part1("389125467", 2) == "32546789"
assert part1("389125467", 3) == "34672589"
assert part1("389125467", 10) == "92658374"
assert part1("389125467", 100) == "67384529"
assert part1("368195742", 100) == "95648732"
# assert part2("389125467", 0) == 10

# It takes about 12s per 1k rotations.
# So that's about 3h20m to see if this thing is correct.
assert part2("389125467", 1000000) == 149245887792
# print(part2("368195742", 10000000))




