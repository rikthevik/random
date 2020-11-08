
import re, collections, itertools

class Runner(object):
    def __init__(self, name, speed_str, fly_str, rest_str):
        self.name = name
        self.speed = int(speed_str)
        self.fly = int(fly_str)
        self.rest = int(rest_str)
        self.period = self.fly + self.rest
        self.points = 0
    def travelled(self, numsecs):
        return self.speed * (int(numsecs / self.period)*self.fly + min(numsecs % self.period, self.fly))

def main(numsecs, inputstr):
    l_regex = re.compile('(\w+) can fly (\d+) km/s for (\d+) seconds, but then must rest for (\d+) seconds.')
    runners = []
    for l in inputstr.splitlines():
        runners.append(Runner(*re.match(l_regex, l).groups()))

    for currsec in range(1, numsecs+1):
        dists = list(sorted(( (r.travelled(currsec), r) for r in runners ), reverse=1))
        for max_dist, dist_runners in itertools.groupby(dists, key=lambda t: t[0]):
            for d, r in dist_runners:
                r.points += 1
            break

    for r in runners:
        print r.name, r.points

    print "-"*80


main(1000, """Comet can fly 14 km/s for 10 seconds, but then must rest for 127 seconds.
Dancer can fly 16 km/s for 11 seconds, but then must rest for 162 seconds.""")
main(2503, """Dancer can fly 27 km/s for 5 seconds, but then must rest for 132 seconds.
Cupid can fly 22 km/s for 2 seconds, but then must rest for 41 seconds.
Rudolph can fly 11 km/s for 5 seconds, but then must rest for 48 seconds.
Donner can fly 28 km/s for 5 seconds, but then must rest for 134 seconds.
Dasher can fly 4 km/s for 16 seconds, but then must rest for 55 seconds.
Blitzen can fly 14 km/s for 3 seconds, but then must rest for 38 seconds.
Prancer can fly 3 km/s for 21 seconds, but then must rest for 40 seconds.
Comet can fly 18 km/s for 6 seconds, but then must rest for 103 seconds.
Vixen can fly 18 km/s for 5 seconds, but then must rest for 84 seconds.""")