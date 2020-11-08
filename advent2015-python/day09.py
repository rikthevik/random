
import re, collections, itertools

def main(inputstr):
    all_cities = set()
    distances = collections.defaultdict(dict)
    for l in (l.strip() for l in inputstr.splitlines()):
        lcity, rcity, dist = re.match(r'(\w+) to (\w+) = (\d+)', l).groups()
        distances[frozenset({lcity, rcity})] = int(dist)
        all_cities.add(lcity)
        all_cities.add(rcity)

    dist_and_ordering = []
    for city_order in itertools.permutations(all_cities):
        city_order = list(city_order)
        total_dist = 0
        for city, next_city in zip(city_order[:-1], city_order[1:]):
            total_dist += distances[frozenset({city, next_city})]
        dist_and_ordering.append((total_dist, " -> ".join(city_order)))

    # print dist_and_ordering
    print min(dist_and_ordering)
    print max(dist_and_ordering)


main("""London to Dublin = 464
London to Belfast = 518
Dublin to Belfast = 141""")
main("""Faerun to Norrath = 129
Faerun to Tristram = 58
Faerun to AlphaCentauri = 13
Faerun to Arbre = 24
Faerun to Snowdin = 60
Faerun to Tambi = 71
Faerun to Straylight = 67
Norrath to Tristram = 142
Norrath to AlphaCentauri = 15
Norrath to Arbre = 135
Norrath to Snowdin = 75
Norrath to Tambi = 82
Norrath to Straylight = 54
Tristram to AlphaCentauri = 118
Tristram to Arbre = 122
Tristram to Snowdin = 103
Tristram to Tambi = 49
Tristram to Straylight = 97
AlphaCentauri to Arbre = 116
AlphaCentauri to Snowdin = 12
AlphaCentauri to Tambi = 18
AlphaCentauri to Straylight = 91
Arbre to Snowdin = 129
Arbre to Tambi = 53
Arbre to Straylight = 40
Snowdin to Tambi = 15
Snowdin to Straylight = 99
Tambi to Straylight = 70""")