#!/usr/bin/env python3

import itertools, collections

FREE = "."

class Segment:
    def __init__(self, *args):
        self.idx, self.len, self.file_id = args
    def __str__(self):
        return str(self.file_id) * self.len
    def __repr__(self):
        return "{idx=%d len=%d file_id=%s}" % (self.idx, self.len, self.file_id)

def prob2(s):
    segments = []
    file_ids = itertools.count(0)
    idx = 0
    for i, length in enumerate(map(int, s)):
        if length == 0:
            pass
        elif i % 2 == 0:
            segments.append(Segment(idx, length, next(file_ids)))
        else:
            segments.append(Segment(idx, length, FREE))
        idx += length
    print(segments)

    iteration = itertools.count(0)

    fulls = [s for s in segments if s.file_id != FREE]
    try_fulls = fulls.copy()
    frees = [s for s in segments if s.file_id == FREE]

    result_fulls = []
    while try_fulls:
        full = try_fulls.pop()

        result2 = list(sorted(fulls + frees, key=lambda seg: seg.idx))
        # print("full=", full, "result2=", display(result2))
        for free in sorted(frees, key=lambda seg: seg.idx):
            if free.idx > full.idx:
                pass
            elif full.len == free.len:
                # print("exact", full)
                # need to replace the free space if we move
                frees.remove(free)
                frees.append(Segment(full.idx, full.len, FREE))
                full.idx = free.idx
                break
            elif full.len < free.len:
                # print("lt", full)
                frees.append(Segment(full.idx, full.len, FREE))
                full.idx = free.idx
                free.idx += full.len
                free.len -= full.len
                # print("@@", frees)
                break
            else:
                pass
                
    result = list(sorted(fulls + frees, key=lambda seg: seg.idx))
    print("!!", result)
    print("@@", display(result))
    print("##", checksum(result))
    return checksum(result)

def display(segments):
    return "".join(str(s) for s in segments)

def checksum(segments):
    tot = 0
    for i, file_id in enumerate(yield_file_ids(segments)):
        if file_id != FREE:
            tot += i * file_id
    return tot

def yield_file_ids(segments):
    for s in segments:
        for i in range(s.len):
            yield s.file_id

assert 2858 == prob2("""2333133121414131402""")
assert 1928 == prob2(open("input09.txt", "r").read().strip())


