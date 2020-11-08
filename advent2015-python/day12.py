
import json

def leaves(d):
    if isinstance(d, dict):
        if "red" not in d.values():
            for k, v in d.iteritems():
                for a in leaves(v):
                    yield a
    elif isinstance(d, list):
        for item in d:
            for a in leaves(item):
                yield a
    else:
        yield d

def main(d):
    print sum( item for item in leaves(d) if isinstance(item, (int, float)))

main(json.loads(open("input12.real.txt").read()))