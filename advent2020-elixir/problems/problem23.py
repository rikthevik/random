
# I know I worked most of this out in Elixir, but
# boy does Python make some things easy.  Or at least
# my thoughts have been shaped using it.


def part1(cupstr, times):
    cups = [ int(s) for s in cupstr.strip() ]
    print cups
    cups = play(cups, times, max(cups))
    idx = cups.index(1)
    result = cups[idx+1:] + cups[:idx]
    return "".join(map(str, result))


def play(cups, times, max_val):
    while times > 0:
        c, p1, p2, p3 = cups[:4]
        pickup = [p1, p2, p3]
        rest = cups[4:]
        dest = find_dest(c-1, pickup, max_val)
        print "dest=", dest
        idx = rest.index(dest) + 1
        cups = rest[:idx] + pickup + rest[idx:] + [c]
        print cups 
        times -= 1
    return cups


def find_dest(c, pickup, max_val):
    if c == 0:
        return find_dest(max_val, pickup, max_val)
    elif c in pickup:
        return find_dest(c - 1, pickup, max_val)
    else:
        return c


assert part1("389125467", 10) == "92658374"
assert part1("389125467", 100) == "67384529"






