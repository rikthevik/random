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

def prob1(s):
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
    d = collections.deque(segments)
    result = []
    try:
        while True:
            # print("iteration=%s" % next(iteration), display(d), ":::", display(result))
            free = d.popleft()
            if free.file_id != FREE:
                result.append(free)
            else:
                last = d.pop()
                while last.file_id == FREE:
                    last = d.pop()
                # print("!!! free=", free, "last=", last)
                if last.len == free.len:
                    # same length, swap it out
                    # print("!!! freeeq")
                    result.append(Segment(free.idx, free.len, last.file_id))
                elif last.len < free.len:
                    # print("!!! freelt")
                    # remove the space from the current free chunk and put it back
                    result.append(Segment(free.idx, last.len, last.file_id))
                    d.appendleft(Segment(free.idx + last.len, free.len - last.len, FREE))
                elif last.len > free.len:
                    # print("!!! freegt")
                    result.append(Segment(free.idx, free.len, last.file_id))
                    d.append(Segment(last.idx, last.len - free.len, last.file_id))

    except IndexError:
        pass


    print("!!", result)
    print("@@", display(result))
    print("##", checksum(result))
    return checksum(result)

def display(segments):
    return "".join(str(s) for s in segments)

def checksum(segments):
    tot = 0
    for i, file_id in enumerate(yield_file_ids(segments)):
        tot += i * file_id
    return tot

def yield_file_ids(segments):
    for s in segments:
        for i in range(s.len):
            yield s.file_id

# assert 1928 == prob1("""12345""")
# assert 1928 == prob1("""2333133121414131402""")
assert 1928 == prob1(open("input09.txt", "r").read().strip())


