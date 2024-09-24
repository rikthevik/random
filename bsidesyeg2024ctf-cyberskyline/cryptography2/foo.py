
tot = "guvf cebonoyl vfag frpher"
tot = "bpqa qavb uckp jmbbmz"

def slide(c, o):
    if c == ' ': return c
    n = ord(c) + o
    if n > ord('z'):
        n -= 26
    return chr(n)

def go(l, offset):
    print("".join(slide(c, offset) for c in l))

for i in range(32):
    go(tot, i)


