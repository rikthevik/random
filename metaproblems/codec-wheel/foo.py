#!/usr/bin/env python3

top =    "{}ABCDEFGHIJKLMNOPQRSTUVWXYZ"
bottom = "ZYXPTKMR}ABJICOSDHG{QNFUVWLE"

ciphertext = "RKPUYPFCIAKKJMYZZJT"

def get_map(offset):
    return dict(zip(top, bottom[i:] + bottom[:i]))

for i in range(len(top)):
    m = get_map(i)
    print( "".join(m[c] for c in ciphertext) )


