
import re
l_regex = re.compile(r'([A-Za-z]+): capacity (-?\d+), durability (-?\d+), flavor (-?\d+), texture (-?\d+), calories (-?\d+)')


def combos2(upto):
    for i in range(upto+1):
        for j in range(upto+1):
            if i+j == upto:
                yield (i, j)

def combos4(upto):
    for i in range(upto+1):
        for j in range(upto+1):
            for k in range(upto+1):
                for l in range(upto+1):
                    if i+j+k+l == upto:
                        yield (i, j, k, l)

def main(combo_fn, inputstr):

    allprops = []
    for l in inputstr.splitlines():
        groups = l_regex.match(l).groups()
        name = groups[0]
        allprops.append(map(int, groups[1:6]))
    print allprops

    max_score, max_combo = 0, None
    for combo in combo_fn(100):
    # for combo in [ (40, 60) ]:
        scores = []
        for amount, cookie in zip(combo, allprops):
            scores.append([ amount*prop for prop in cookie ])
        # print "!!", combo, scores
        added_props = [ max(0, sum(col)) for col in zip(*scores) ]
        # print "##", added_props
        total_score = reduce(lambda a,b: a*b, added_props[:-1])  # Remove calories.
        total_cals = added_props[-1]

        # print total_cals

        # print total_score
        if total_cals == 500 and total_score > max_score:
            max_score = total_score
            max_combo = combo
        # break
    print max_score, max_combo

# main(combos2, """Butterscotch: capacity -1, durability -2, flavor 6, texture 3, calories 8
# Cinnamon: capacity 2, durability 3, flavor -2, texture -1, calories 3""")
main(combos4, """Sugar: capacity 3, durability 0, flavor 0, texture -3, calories 2
Sprinkles: capacity -3, durability 3, flavor 0, texture 0, calories 9
Candy: capacity -1, durability 0, flavor 4, texture 0, calories 1
Chocolate: capacity 0, durability 0, flavor -2, texture 2, calories 8""")