
import itertools

def main(target, inputstr):
    containers = map(int, inputstr.splitlines())
    satisfied_count = 0
    for i in range(1, len(containers)):
        for combo in itertools.combinations(containers, i):
            if sum(combo) == target:
                satisfied_count += 1
        if satisfied_count > 0:
            break
    print satisfied_count


main(25, """20
15
10
5
5""")
main(150, """11
30
47
31
32
36
3
1
5
3
32
36
15
11
46
26
28
1
19
3""")