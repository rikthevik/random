#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """

inputstr = """
"""

inputstr = """abBAa"""
inputstr = """aAbBaA"""
inputstr = """dabAcCaCBAcCcaDA"""
inputstr = open("day05input.txt", "r").read()

import re, collections, itertools

s = list(inputstr.strip())
idx = 0
while idx < len(s) - 1:
    # print("".join(s))
    if abs(ord(s[idx]) - ord(s[idx+1])) == 32:
        left = s[:max(0, idx)]
        right = s[idx+2:]
        s = left + right
        idx = max(0, idx - 1)
    else:
        idx += 1
print("final %r" % "".join(s))
print(len(s))


