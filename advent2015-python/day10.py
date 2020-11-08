
import re, itertools

def main(s, numtimes):
    for i in range(numtimes):
        new = ""
        for char, founditer in itertools.groupby(s):
            # print char, list(foundlist)
            foundlist = list(founditer)
            new += "%d%s" % (len(foundlist), char)
        s = new
        # print s
        # break
    print "@@", len(s)




main("211", 1)
main("1", 6)
main("1113222113", 50)
