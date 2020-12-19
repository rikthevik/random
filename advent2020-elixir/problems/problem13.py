



def go((himod, hirem), (lomod, lorem)):
    print (himod, hirem), (lomod, lorem)
    newmod = himod * lomod
    val = hirem
    iterations = 0
    while True:
        #        print val
        if val % lomod == lorem:
            # print "%d * %d iterations + %d == %d" % (himod, iterations, hirem, val)
            return (newmod, val)
        if val > newmod:
            raise Exception("wtf")
        val = val + himod
        # iterations += 1


rows = [
    (67, 0),
    (7, 2),
    (59, 3),
    (61, 4),
]
rows = [
    (1789, 0),
    (37, 1),
    (47, 2),
    (1889, 3),
]
rows = [
    (17, 0),
    (13, 2),
    (19, 3),
]
s = "13,x,x,41,x,x,x,x,x,x,x,x,x,569,x,29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19,x,x,x,23,x,x,x,x,x,x,x,937,x,x,x,x,x,37,x,x,x,x,x,x,x,x,x,x,17"
rows = [ (int(v), i) for i, v in enumerate(s.split(",")) if v != "x" ]

# AHA! In the test data they is 17 with a remainder of 61 which screws everything up.
# Gotta get that remainder back into the 17's mod space!  Fuckers!
rows = [ (mod, rem % mod) for (mod, rem) in rows ]
print rows
# raise Exception("wat")
rows = list(sorted(rows, reverse=False))
curr = rows[0]
rest = rows[1:]
for row in rest:
    curr = go(curr, row)

mod, rem = curr
print "ANSWER", mod - rem

