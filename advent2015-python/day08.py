

import re

def main(inputpath):
    total_diff = 0
    second_diff = 0
    for l in ( _l.strip() for _l in open(inputpath, "r") ):
        code_count = len(l)
        content = l[1:-1]
        content, _ = re.subn(r'\\x[a-f0-9][a-f0-9]', '!', content)
        content = content.replace(r'\\', '@')
        content = content.replace(r'\"', '#')
        mem_count = len(content)
        # print l, code_count, mem_count, (code_count - mem_count)
        total_diff += (code_count - mem_count)

        # Turn each character into a number that we'll sum up at the end.
        orig_count = len(l)
        content = "1" + l + "1"
        content, _ = re.subn(r'\\x[a-f0-9][a-f0-9]', '5', content)
        content = content.replace('"', '2')
        content = content.replace('\\', '2')
        content, _ = re.subn(r'[a-z]', '1', content)
        exploded_count = sum( int(c) for c in content )
        second_diff += (exploded_count - orig_count)
        print l, content, exploded_count

    print total_diff, second_diff

main("input08.test.txt")
main("input08.real.txt")