#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """

inputstr = """
Step C must be finished before step A can begin.
Step C must be finished before step F can begin.
Step A must be finished before step B can begin.
Step A must be finished before step D can begin.
Step B must be finished before step E can begin.
Step D must be finished before step E can begin.
Step F must be finished before step E can begin.
"""


import re, collections, itertools
Point = collections.namedtuple('Point', 'x y')

regex = re.compile(r'Step ([A-Z]) must be finished before step ([A-Z]) can begin.')

def main():
    g = collections.defaultdict(set)
    reverse = collections.defaultdict(set)
    for l in inputstr.strip().splitlines():
        pre, post = regex.match(l).groups()
        g[pre].add(post)
        # print(pre, post)  # ./day07part1.py | tsort
        reverse[post].add(pre)

    all_nodes = set(g.keys()) | set(reverse.keys())
    queue = set()
    visited = set()
    for n in all_nodes:
        if not reverse.get(n):
            queue.add(n)
            break

    print("initial queue", queue)

    while queue:
        curr = sorted(queue)[0]
        print("curr", curr, "queue", queue)
        visited.add(curr)

        queue.remove(curr)
        for n in g.get(curr, []):
            if n not in visited:
                queue.add(n)

        print()

#     print("no_incoming", no_incoming)
#     print("all_nodes", all_nodes)
#     print("g", g)
#     print("reverse", reverse)


if __name__ == '__main__':
    main()
