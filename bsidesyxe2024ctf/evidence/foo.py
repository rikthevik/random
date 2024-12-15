#!/usr/bin/env python3

total = "A28CACC8A34AE41B512F54B16A34EA55F5BA45A1E22CCBCE7ED283D24CEFD67ED283CA77CC08102F82544B522C58A1020409152E4081027C6E"
# import base64
# print(base64.b64decode(s, validate=False))  # nope

n = ""
while total:
    s = total[:2]
    a = int(total[0] + total[1], base=16)
    total = total[2:]

print(n)

