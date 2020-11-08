
import hashlib

def main(inputstr):
    i = 1
    while True:
        s = "%s%d" % (inputstr, i)
        checksum = hashlib.md5(s).hexdigest()
        if checksum.startswith("000000"):
            print inputstr, i
            break
        i += 1

# main("abcdef")
# main("pqrstuv")
main("ckczppom")
