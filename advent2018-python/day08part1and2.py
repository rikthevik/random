#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """


inputstr = """
2 3 0 3 10 11 12 1 1 0 1 99 2 1 1 2
"""
inputstr = open("day08input.txt", "r").read()


import re, collections, itertools
Node = collections.namedtuple('Node', 'a children metadata')


def dive(a):
    num_children = next(nextline_gen)
    num_metadata = next(nextline_gen)
    letters = [ next(letter_gen) for i in range(num_children) ]
    children = [ dive(letter) for letter in letters ]
    metadata = [ next(nextline_gen) for i in range(num_metadata) ]
    return Node(a, children, metadata)

def nextline_gen_fn():
    for s in inputstr.strip().split(" "):
        yield(int(s))
nextline_gen = nextline_gen_fn()

def letter_gen_fn():
    i = 0
    while True:
        yield(i)
        i += 1
letter_gen = letter_gen_fn()

def left_metadata(node):
    print("left_metadata", node)
    for i in node.metadata:
        yield i
    for n in node.children:
        yield from left_metadata(n)

def node_value(node):
    if not node.children:
        print(node.metadata, "=>", sum(node.metadata))
        tot = sum(node.metadata)
    else:
        tot = 0
        for m in node.metadata:
            idx = m-1
            if 0 <= idx < len(node.children):
                tot += node_value(node.children[idx]) 
    print("nchildren=", len(node.children), "metadata", node.metadata, "value=", tot)
    return tot

def main():
    root = dive(next(letter_gen))
    # print(root)
    print(node_value(root))

if __name__ == '__main__':
    main()
