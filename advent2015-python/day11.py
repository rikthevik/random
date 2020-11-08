
ord_a = ord("a")

reject_letters = (ord("i"), ord("o"), ord("l"))
ord_z = ord("z")

def increment(l):
    # The big prune
    for i in range(len(l)):
        if l[i] in reject_letters:
            l[i:] = [l[i]+1] + [ ord_a for a in l[i+1:] ]

    # Increment
    for i in reversed(range(len(l))):
        if l[i]+1 > ord_z:
            l[i] = ord_a
        else:
            l[i] += 1
            if l[i] in reject_letters:
                l[i] += 1
            break

def out(l):
    return "".join(chr(n) for n in l)

def is_valid(l):
    if any( letter in l for letter in reject_letters ):
        assert 0
        return False
    return has_straight(l) and has_doubles(l)

def has_straight(l):
    for triple in zip(l[:-2], l[1:-1], l[2:]):
        if triple[1] - triple[0] == 1 and triple[2] - triple[0] == 2:
            print triple
            return True
    return False

def has_doubles(l):
    f = None
    for i, double in enumerate(zip(l[:-1], l[1:])):
        if double[1] - double[0] == 0:
            f = i+2
            break
    if f is None:
        return False
    for double in zip(l[f:-1], l[f+1:]):
        if double[1] - double[0] == 0:
            return True
    return False

def main(inputstr):
    l = [ ord(c) for c in inputstr.strip() ]
    while 1:
        print out(l)
        increment(l)
        print out(l)
        if is_valid(l):
            break
    print "@@", out(l)
    print

main("hijklmmn")
main("abbceffg")
main("abbcegjk")
main("abcdefgh")
main("ghijklmn")
main("cqjxjnds")
main("cqjxxyzz")