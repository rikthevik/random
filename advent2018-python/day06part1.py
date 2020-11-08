#!/usr/bin/env python3

""" https://adventofcode.com/2018/day/2 """

inputstr = """
3, 3
7, 3
3, 10
6, 10
"""

inputstr = """
1, 1
1, 6
8, 3
3, 4
5, 5
8, 9
"""

inputstr = """
350, 353
238, 298
248, 152
168, 189
127, 155
339, 202
304, 104
317, 144
83, 106
78, 106
170, 230
115, 194
350, 272
159, 69
197, 197
190, 288
227, 215
228, 124
131, 238
154, 323
54, 185
133, 75
242, 184
113, 273
65, 245
221, 66
148, 82
131, 351
97, 272
72, 93
203, 116
209, 295
133, 115
355, 304
298, 312
251, 58
81, 244
138, 115
302, 341
286, 103
111, 95
148, 194
235, 262
41, 129
270, 275
234, 117
273, 257
98, 196
176, 122
121, 258
"""

import re, collections, itertools
Point = collections.namedtuple('Point', 'x y')

regex = re.compile(r'(\d+), (\d+)')

def main():
    orig_points = { Point(*map(int, regex.match(l).groups())):100+i for i, l in enumerate(inputstr.strip().splitlines()) }
    orig_c = orig_points.values()
    active_points = orig_points.copy() 
    all_points = orig_points.copy() 
    for i in range(256):
#         print("active_points", active_points)
#         print("removed c", set(orig_c) - set(active_points.values()))
        new_active_points = {}
        for p, c in active_points.items(): 
            try_points = [ Point(p.x-1, p.y), Point(p.x+1, p.y), Point(p.x, p.y-1), Point(p.x, p.y+1) ]
            for t in try_points:
                if new_active_points.get(t, c) != c:
                    new_active_points[t] = '.'
                elif all_points.get(t):
                    pass
                else:
                    new_active_points[t] = c
        
        all_points.update(new_active_points)
        active_points = { p:c for p,c in new_active_points.items() if c != '.' }

#     for y in range(512):
#         for x in range(512):
#             if Point(x, y) in orig_points:
#                 print(orig_points[Point(x, y)].upper(), end='')
#             else:
#                 print(all_points.get(Point(x, y), '_'), end='')
#         print()

    deactivated = sorted(set(orig_c) - set(active_points.values()))
    for d in deactivated:
        print(list(all_points.values()).count(d), d)
    

if __name__ == '__main__':
    main()
