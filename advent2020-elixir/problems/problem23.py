
# I know I worked most of this out in Elixir, but
# boy does Python make some things easy.  Or at least
# my thoughts have been shaped using it.

import collections

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
    print "part1 %r => %r" % (cupstr, resultstr)
    return resultstr


def play(cups, times, max_val):
    t = 0
    while t < times:
        # print "move", t, ", cups=", cups
        c = cups.popleft()
        # print "c=", c
        pickup = [ cups.popleft() for i in range(3) ]
        
        cups.appendleft(c)

        dest = find_dest(c-1, pickup, max_val)
        # print "dest=", dest
        steps_left = 0
        while True:
            # print "deq=", cups
            p = cups.popleft()
            cups.append(p)
            # print "steps_left=%d p=%d" % (steps_left, p)
            steps_left += 1
            if p == dest:
                # print "break"
                # print "before", cups
                cups.extend(pickup)
                # print "after", cups
                total_steps_left = steps_left+3-1
                cups.rotate(total_steps_left)
                # print "postortato %d" % total_steps_left, cups
                break

        # print " ", cups
        # print
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




