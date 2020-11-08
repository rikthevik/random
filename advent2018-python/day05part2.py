#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """

inputstr = """
"""

inputstr = """abBAa"""
inputstr = """aAbBaA"""
inputstr = """dabAcCaCBAcCcaDA"""
inputstr = open("day05input.txt", "r").read().strip()

import re, collections, itertools

count_c = []
for c in sorted(set(inputstr.upper())):
    s = list(inputstr.replace(c.upper(), '').replace(c.lower(), ''))
    idx = 0
    while idx < len(s) - 1:
        # print("".join(s))
        if s[idx].upper() == c:
            left = s[:max(0, idx)]
            right = s[idx+1:]
            s = left + right
            idx = max(0, idx - 1)
        elif abs(ord(s[idx]) - ord(s[idx+1])) == 32:
            left = s[:max(0, idx)]
            right = s[idx+2:]
            s = left + right
            idx = max(0, idx - 1)
        else:
            idx += 1
    print(c, len(s))
    count_c.append((len(s), c))
print(min(count_c))

