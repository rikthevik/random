

defmodule Util do
  
end

defmodule Problem do

  def load(inputstr) do
    inputstr
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&tokens/1)
  end

  # tail recursive
  def tokens(s) do tokens(s, []) end
  def tokens("", acc) do Enum.reverse(acc) end
  def tokens(s, acc) do
    [_, token, rest] = Regex.run(~r/^(e|se|sw|w|nw|ne)(.*$)/, s)
    tokens(rest, [token|acc])
  end

  # There's a bit of subtlety about how you model hexagons.  
  # The se/sw and ne/nw thing didn't seem super obvious and I had to draw it out.
  # Though I guess if you're consistent it doesn't really matter.
  def last_hex([], {x, y}) do {x, y} end
  def last_hex(["e"|rest], {x, y})  do last_hex(rest, {x+1, y+0}) end
  def last_hex(["se"|rest], {x, y}) do last_hex(rest, {x+0, y-1}) end
  def last_hex(["sw"|rest], {x, y}) do last_hex(rest, {x-1, y-1}) end
  def last_hex(["w"|rest], {x, y})  do last_hex(rest, {x-1, y+0}) end
  def last_hex(["nw"|rest], {x, y}) do last_hex(rest, {x+0, y+1}) end
  def last_hex(["ne"|rest], {x, y}) do last_hex(rest, {x+1, y+1}) end

  def flip(:white) do :black end
  def flip(:black) do :white end
  
  def part1(paths) do
    for path <- paths do
      last_hex(path, {0, 0})
    end
    # We have the paths, now fold those into a map for each point
    |> Enum.reduce(Map.new, fn {x, y}, m ->
      Map.put(m, {x, y}, flip(Map.get(m, {x, y}, :white)))
    end)
    |> Enum.count(fn {_k, v} -> v == :black end)
  end

  


end



defmodule Tests do 
  use ExUnit.Case

  @tag :example
  test "example1" do
    inputstr = "sesenwnenenewseeswwswswwnenewsewsw
    neeenesenwnwwswnenewnwwsewnenwseswesw
    seswneswswsenwwnwse
    nwnwneseeswswnenewneswwnewseswneseene
    swweswneswnenwsewnwneneseenw
    eesenwseswswnenwswnwnwsewwnwsene
    sewnenenenesenwsewnenwwwse
    wenwwweseeeweswwwnwwe
    wsweesenenewnwwnwsenewsenwwsesesenwne
    neeswseenwwswnwswswnw
    nenwswwsewswnenenewsenwsenwnesesenew
    enewnwewneswsewnwswenweswnenwsenwsw
    sweneswneswneneenwnewenewwneswswnese
    swwesenesewenwneswnwwneseswwne
    enesenwswwswneneswsenwnewswseenwsese
    wnwnesenesenenwwnenwsewesewsesesew
    nenewswnwewswnenesenwnesewesw
    eneswnwswnwsenenwnwnwwseeswneewsenese
    neswnwewnwnwseenwseesewsenwsweewe
    wseweeenwnesenwwwswnew"
    assert 10 == inputstr |> Problem.load |> Problem.part1
  end

  test "gotime" do
    inputstr = "swswswswneswswwwswnewswswweswnwsww
    nwwewenenwnenwnwnwnwneswnwswnwnwswswnw
    seneswwwswwnenwnenwswswswswsewseeww
    esenesenesesesewseseswnesesweesesesese
    seseseeseenesewseenwsesewswwsesenwse
    eswenewnenenewneneneneenenenenwnene
    nwseeseseeseseseseewseesenwseeesese
    nwnwswswswweneseswwswwneswswswswswsw
    senenenwnenewneneneseswneeeenenenew
    eswnwnesenwnwnenwnwnwnwwnwsenwwswswenw
    wswneswswseesewswseswswswnenesenenwswswne
    seswseswneswswswwnwswwswseneswswswswsee
    neseseswnwesesesesewswsesenesenesesesw
    wwswwwsweswwwww
    seswwnwneenwswneenwewneneneseenee
    eswseenweswewseneeeeseeswnwnwse
    swsweswswswnweswswneswwswnwswwwswswswsw
    nwwnwnwnwnwnwnwnwwswwnweneswwenwnw
    sewswwwwwwwweswwwwneswwnwswnw
    nwneeneeneneseneseneneneneneneswnenwnene
    swnenenweeneeeseswweneenenenenene
    nwnwnwsenwewsesenwenwwwswwnwnesenw
    swnwswswswswswsewseswnewneseswswswneesw
    wwweswwswwsewswswwwwnwwesewwne
    swswsweneswswswenwswnewnwswwneswseswswe
    nwnesewwnwwnwwwsew
    enwwwnenwnewwwwswwseeswewe
    neswseswswsenwseswnwseswse
    senwseneneneneneeseneswnenenenenwnenwnw
    swseneswwseenwsenwneneswnewnenewene
    ewwwwwwwewwwnwswwwwwwwne
    eswswenwsenwnwsenenw
    nwneseewseswwsewswnwnwnwwwwnewww
    nwwwwwwwwewnwwswnew
    neeeseeesewseeeeeeeewe
    wweswnenwwnewnwnwwwewsewnwwsew
    swwswwwswwewwswswnwsweswnwwwww
    eseswneenwneenweseenweeseeeenw
    neneswneneneneneneneneneswnenwnwnw
    nwnwwnwewwswwnwwwnwsewnwwenwnw
    seswswswnwswwwwswwswneswwseswnw
    nwseswenwwneneneseswneenwnenenwnenwnenw
    nwnenenenesewwnenwnwnesenwnwnwnwnenwnwnw
    wseeeneseeeseseesesenwseseswsesese
    sweseswnwseseseswseswseseseswswswse
    ewwwswswsenwewnewwwenwwwnwww
    nwwsewnwnwnwneswwnwesewnwwnwnwnwnwne
    nenwnwnwnenenwnenwnwswswnwneenenwnwnwne
    esenwneswsesesweeeeweseseeseseswnw
    swswswswwsesweseswswswsw
    swsweneswwseswswswwswsenewswwswseswnene
    nenenewnwnenenwenwnesenwneseswnwnwnwne
    nenenenewneeseneneswneneneswsenenenwne
    nenenwnenwswwnweesenwsenwnwnwseswnwnwnw
    seseeenwsenwswsesenwseeseeseeseswese
    swneeseseneswswnwswnwwwwswswnee
    seeseseseneseseswsewseenenwwneseswse
    wswseseenwwswnewenwswswwwnewwsw
    nenewswnwnenwnwneeneswseeneswnenwnenesene
    nwswsenweweseeneseesesesesesesesee
    seneswswwesenenwswseswnwseseseseseswne
    wwnwwweswnwnwwweneseewnwsesenw
    swswneneneneenewnesenewweenweswne
    eseneseneseenenewwswseweenweenenene
    nwwnwwnwsenwnwnwnwwnwwnww
    swweswsewewwwwwwwwwwnewne
    swswnewseseseesenewseesesesesesenwese
    swswnenwnenwnwnwnwnenenenwnwwnenwseene
    wnwwwwnwnwwnwwnwnwwwnwnwsenwe
    nwseswwwnenwwwwesewwwwwwwnenwnw
    nwswswnwswwswwnenenwnwnwnwnewnenw
    seswswswnwswswswswswswswswswswswsw
    neneseeneswnwnenwnwsenwnenenewne
    wwwwwnenwnwnweswwnwsewwwesese
    swwswswwwwseswswenwnewswwswweswnw
    swwswseswswseeswswswewswswnwswswese
    nwnwewsenenwnesewwwwswnwnenwswsee
    seseseenwwswseneneseswswnwnewswnwsenwse
    wwswwnwwwwsewwwenewnwswnwwwe
    swwwwswwswwswneseswswswwnewswwse
    nenenwneeswnenesweneneneeneneswsewesw
    seswswswseswswswswsweenwswswwseswwsw
    swswswsewneseesenwseseswseswswswnwsesw
    nwwnewnwnwswnwnwswnwsenwwnwenwnenww
    wswwnwwwswwwwswe
    eewneeeeneeswsee
    wseneseeseewseseseswsewse
    wwswnwnwwnewnwsewenenwswwewswwne
    seneesesesesewswswwnwseswswseseswseswsw
    ewnweeeseneseeseseeneseswwwee
    wwwwswwsewwwwewwwwwswnwwne
    swsewswswswseswseseeswsenwseswswswsenw
    nenenenenesenenenenenenewenewneswsene
    newnewewwnwnwnwsewwswnwwwwesww
    neseeeneneeewnee
    wsenwwnwenwnwwnwnwnwwnwnwwnw
    nweswenwseseswwseeenwseenwswsesewsw
    wwwswwwwsewwwwwwwwne
    nenwnwnwnenwnwnwnenwwnwnwnwnwnwe
    eeeeeweneeseeeesweeeeew
    seneseeeeewewnweseeseseseeseese
    swenenenenwesweewneeeneneeeeeee
    wnenwseswnwwwsenwnwwnwnwwnwwnwnwnwnw
    sewwwswnwwnwwwswwnewwewwwsw
    swwwwswswwswswwwswnew
    esweeneeswenwnweesweneeeeswee
    eenweeseneeeeeeeeeseeenenwsw
    nwneswweeneseswnwswnweeesesesenwe
    neneneeswnwnwnwnenenwnenene
    wseewseeseseneswsenwsenewsesweseswswse
    eseswneneseneenenewswwnwnenenesenenenw
    seswsesesweseswseswseswwsw
    nwnenenenenwnenenwsenenwwsenewnenenene
    eneneneneswnenenenenenenenwneneneswnwnw
    neneeneneenwnenenesweneneewsweneene
    swnwnwneswnwnwseenwnwnenwenewnwnwnwwnw
    swswwnwwswnwwseswewswneseneswewneswe
    neswswnewwswswwwswwsewww
    nwneeenwswnwsenwnwnwnwnenwswnwnwsenwnw
    neeswnwnwwnwseswesweneswnw
    swnenwenwnwnwnwsesenwswnwnwnwnwnwnwnwnw
    swseswswnenwwwwseswwwwsw
    seswneseswseswswswsewesenwsenesewsesw
    eseeneswseenwewseewneeeene
    swnenenenenenenewwneneswnenenesenesenw
    swnenwnenwnwenenenwnenenwnwnene
    eswneenwwnwwwneewneneneswneseswee
    neseneseneewneeeweewnwneeseee
    nesenenenenwnwnenwswnwnenwnenenwnw
    seswsesesenwseeeeseseeesesewseenw
    eneswsewneeswnenweswneeswnewwswseene
    eeseseseswneswseseeeeeeeeewne
    wwwseswnenwwnwnwenenwnw
    sesenesweeeeeweeeweeenwwe
    wsewnwwsewwewwnew
    esesenwnwwwneswwswsenwnwnwseswneswwew
    nenwwnwnwnwswwenwwwenwwwnwnwwnw
    seeeneeneeseeswnenenwsweweewee
    swswswwswswswswwswswwswneswswsw
    nweseneweseeswwnwwswswnw
    wnwsweswseswswswswseswne
    swnenenwneenenenenenenenenenenenene
    swswswswswseswswwswswswwnwwenwnwseswesw
    wswwswswwswswsweswewswwswnwnesw
    neneeewneneeswnewneneeseseswewnw
    seseswseeesenwsesweseneseeseeesese
    nenenenwnesewneswneneseneenewnene
    neneneneneneswwneneneneneesenenenenene
    swswswnwswnwswsweeswswseswswswswswswnw
    sweeseseneeeseeswnewnwnwwewsee
    neswsenwnewwnwwwwwwswweseenenww
    nwwwwnwwwsewnwwswnewwwnewww
    nwswsweswswneswseswswswswwneseswwnesww
    wsewwnwwwwswnewwwwsewswwwsw
    nwwwwwsenewneewwseenewwsesw
    nwnenwwnwwnwwnenenwnenwenesenwenwne
    nwnenwnwsewnenwsenwnenenwnwnenenenwnene
    wswswwwenwswenesewwnenwe
    wseswneeswneseenwnwsenwswewwweswesw
    swnwseseeeeewseswnwseneseswsenwsesene
    sweneswnwnwswsweneswnwswneswneswsweswsw
    eeeswnwswneeneenewswnewneneeee
    senwwnenwenwnwwsenwnwnwnenw
    esesenweseeeeseseeesesese
    seeeeseneseseeeswseeeeseewsene
    wneswwwwswswwwewwnesesenwwwse
    wnwnwwwsenwnwswnwnwnenewnwnwwnwwnw
    senewsesesesesesesesesesesese
    eenweswneeenee
    nwnenwwnwnwnwnwwwseenwnwnwwnwnwnwswnw
    esweneseeneeneeneneneneneswnenewnee
    nwwwwswwewnwnwww
    neneeneewneeneneneswnwnesenenenenwnesene
    wneswsesenewswwwwwwwnwswwwseww
    wesenesewswsenwswneswswseswneesesese
    sesesenwswsewnwsenwswseswesenenwseeseew
    wwnwswwneswwweswwwwwwwswww
    nenenwnesewwswswewsenwswnewwswew
    wwwnwwwnenwwwwwnwswnwnw
    nenwswneneneenenenenwnenwnwnwnenwnw
    swenwswewswswswewnwwswnewswseswne
    swsenweeseswenwseseswsenwsesewseswswse
    eeeweswnwnenenweeswneeeseneeee
    swwswneseswnwseneswnewswweseswnwww
    swswswswnenwswswseswseswswswneswwseswsw
    enwsewsweeseseseneweeseswesenwese
    nesenweneneneneneswnwnwnenwnenwnenwnene
    seswseeenwsesenweseseseseseneseeseeswse
    senenwsewnwnwnenwewnwswwneswnwnwsweenw
    neeewnenweseseseeswnesweneneewwse
    eeenwswswseneweseneenweneneneew
    swswneneswnenenenwnenwnenenenwnwnwwnwe
    swsweswwswswswwnwwwweswswswwswnw
    wewwewwwwnwswswwwwswwswsww
    swwnwwswnweseswnwswseweenewwww
    neswswswseswswseswswswseswwswswswsesenw
    eneeneneneewneneneeneneenesew
    nwnwnwnwnwnwnwsenwenenenwnwnwnwwnwnwswne
    weneswnwsenewseseswseeseene
    eseseweneenwnweseeseseneneweswswe
    swswswswseswswsenwnwseswseeswswsweswnw
    sweswwsweswswwswswsweswswwnwswnwenw
    eeeseseeenwsewswesesewsenwsenesw
    seneswseseseseneseseseweesesesw
    ewnwnwwnenwwnwwnenwwnwsewwnwswww
    senweeswseswneweesesesesewnwnwsee
    wseseseseseseeneseese
    neswneswewnwswwwwwwwswwwseewnwse
    sewwsesesewnwswswswseeneeesesewse
    sweswwneseneswswswswnwswnesene
    eesweeenenweeneeeswenwneeeene
    eseseeneweeseeeeneenwneeenwne
    neneneneneswneenenwnewneneneneswnenenenee
    nwnesewwswswseswnwwneswswwswwsesesw
    eeneeswesenwewenwneneeeseenwesw
    nenwneneneneswnenenenwnwnenw
    wwseewnewwneenwwnwswsewseenwse
    wsenwwnwwswwwwwswnweewnenwsee
    nweseswseseseeeseeseeseeesenwsese
    neneswseesewesenenenwneswwswnewswswsenw
    wwneseenwwsenwnwnwneswswewnwswwnwne
    eneneeneneeneesw
    nwnenenwenwnwseeenwwswnwnenwnenewnw
    swsweswswsewewswswnwnwwsewwe
    swseneswswswswswswsesewswswseseswswnesw
    eseseesenwsenwseseeeweesesweeene
    neswnwsewsweseswseseswsesesenwnwneseseswse
    eeneeeseeseenwneeneeeeeewne
    nenwswewnwsweneswwenwswneseseneenew
    weeswwwwnenwswnwsenewnwswwnwnwenw
    wwnewswswswwnwseswwwswswwwnwsew
    newsenwwneswwnwwnwswseeswseswsenwww
    swswwsweneswwwnwnee
    nwswswswswswswswswnwnwswenwseswswseeswsw
    nwnwnwnewswwswnwnwnenwsenweenwnwnwnese
    nwenwseseseswswswswswswenwseswnwewswswse
    swneswwewsenwnwnweeenenweeseese
    nwwwwwswnwesenwwnee
    nwnwwwwnwwnwnwsenw
    nwseseseswswneseswswnwseseswsweswsweswsw
    enweswnweswnweneeeneneneeeswee
    sesenwseswnwswswnenesesesesweseseesesw
    swseswsewnwnwwneswswswseswswneseswwsw
    nenwnenwnwnwnwnesenwnwnwnwswnene
    swwenweesenesweesenweseeeeee
    swnewsesenwswesweeneneesewnw
    swneweswsenwnenesese
    nwnweseeseseseswseewseseenenwsee
    neswswneseeeeenenwwneeenenwneseneene
    swswswsesesesenwsesesenwseswsesese
    nwswnwenwnwnwnwnwnwnwnwnwnwsenwnw
    eeneesweeeeeeseswnweeneneewe
    eeenweseseeeswnwwnwnenwswnewsenenw
    neswswswswseseesweswsenwsesenwnwswswsesew
    eseeeseenweseeeeseese
    swwwswwswwswwsewwswswnwsww
    swswwsenwswwswswswswwwswew
    eeeseeeseswewneeswneee
    sweseswswenwnwwswswnwnenwwseewwwsee
    wwnwwwwnwnwwwwewwenewnwswww
    sewneswnwseeneswwwnewnwenewseswwnw
    seswswswswwswswswnwsweswswswswseswswe
    seswswswswswnwneswnwswswsesesenese
    eenweseeeseeeeneneeeweseesw
    swnwseswswnweneswenwnewenenwnwswnenese
    wweenewnwsewnwwnwnenwswseweesw
    wwseneeneneneneseenwwswsewwesee
    wwsenewwswswwwswwwwswsw
    nwwswwwnwwwnenwnwwnwnenwwswwnesw
    eneseeweseesesesweewnwenwwswe
    eneneeeweneeseeeenesenenenwne
    neeneeeeesweseweeeeeewee
    swsewnesenweenwenwnwneseseswnwnenene
    sewseswseseswseseseswswesenwneswsesese
    nwwwnewsewswswwnwseewwwsenewne
    enwneseeeeswswneeenwnweeewwsw
    wnwswswswswswsweswsw
    nenenenwnesenwnenwnwswwswnene
    swseseseseenwesenwsesewseesewnwseenw
    eswenwsweeeenwneswseeeenwwnee
    sweeswswwswswnwwnwswseseeswsesw
    nweenwswsesenwneswnweeeeseseswswsenw
    wnewseenwnwswneseeeeswnenwneene
    nwsewnwnwnenwnwnwswenwnwnwnwwnwnwnwse
    swswswswswswswnwswswswswseeswnwseswswsw
    senwseswseeseneseewnwnweeseesesesesese
    eeseeeenweeeneeeeneeeew
    seswsenwswseesesenwswsesweswneseswsesese
    nwwnenwnwwwnwwwsenwwnwnwsewnwnewsew
    swneswswswswnwwswswswseswswsweswseenw
    swwnenwnwneneenenenwnenwnenenenwnwne
    ewneswsenwnwenenenwswseeesewnwsww
    wswswenwwnenwnwseeswwnweswswnweeswse
    nwnwnwsewnwnwnwenwswwsewnwenwnwwnw
    neneswneneneneneneeneenenwnenewnwneenesw
    eeeseseeweeeeenee
    nwnwnwswsenenwenwnwnwnwswnwnwsenwnwsweene
    wwsewwwwswwnewwnewwswwswwsw
    nesesewwneseneseweeenwsweenwswwse
    eeenweesweeewweeeeneeeee
    eseswnwwsenwswneswsesweseneeneneswwwsw
    wnwnwnwnwewnwnwseenwwnww
    enwsenwseseeneseeseseseeswnwseesesee
    neneseseseeswswwseswnesesewswnwnwwee
    neenwnwnwnenwsenwnwnwsenwnenenwnwneneswnwnw
    senewnwnenweeewnenwnenenwswnwnenwswnwne
    seseswseswsesesesesenesewseesesesesew
    nenenenwwnwneeneenwswnwnenwnwnenewnee
    wwwwwseswneewnewneswnwewswsenw
    nwnenwnwnwnwenwnwnenenwnwsenwnwwwnwne
    wswwsenewnenenesewneneseseseewnewsw
    nwnwsenwnwnwnenwnwnwnwnwnwnwnw
    nwswswnwnenenwenenewneeeneswswnenwwnene
    sesenwnwenwnwwnwnwnwnwnwnwnwsenwneswsenw
    nwneneneswnenwnwnwnenenwnenwsenwnene
    seneswneewswnenwwneeeeneeneneewe
    seswswswswswneswswswswwweswwswnwswwne
    swnenwnwwnenwnwnwsenenwweesenenenew
    swsewwnenwnwwwwsenwwwewnwwsenew
    eeeeeneeneeweneeeneenwnewswene
    nwnwnwnwwnwwwwnwwwwnewnwwswneswe
    swwnwsweneseswwswnewswswnwswseswnwseswe
    swswswswswswswswswswseswswswswneewnwww
    senwnenwsenenewnwnwwsenenwnwnwnwenenw
    wswnwenwenewnwwwwwnwnwwswwwsw
    swseseswswseswseneswwseneseswwseswsesese
    eeeswsenewenweseeeeseeeenesw
    enwnenwneswwewnwsewnwnenenwnwse
    nwnenwnenwenwnwnenwnwnwswnwnwnwneneswnw
    sweswseswswnwswswswswswswseenwswsewsw
    wnwnwewnweenwnwewnwwsenwweswnw
    senenwnwwnwnwnwwnwwwnwnwnwnwnwnwnwsesw
    nwnwnwneswnwnwenwnwnewnwneenwnwnwswne
    seesenewnwneswnenenenenenenenesewnene
    seswwswnenwnwseseswseswswswseseweneesw
    swwswenwwnwnwwewwwnwwnwnwwe
    nwnwnenenwnwsenenwnwsenwnwswnwnwnwnwnw
    wewsesenwswnewnwnwwnw
    nesenenewneesenenweneweneeneeneeswne
    senwwsenwswswnwneesewwnwneenwwnwswe
    nwnwenwnwnwswnwnwnwnwnwswnwnwwenwnwnwnw
    nwnwnwswnwnwneewnesenwnwnwnewnenwnenwnwe
    wseseenwswseneseseneeeseeeeesenw
    nenewwsewwenenwwsewswwnwwswww
    nwwwnwwnesewewwwwswwewwseww
    eeswseneswwsenwesesweswwsenwnwnwnese
    wnwwswwewwwwwwwsenwnwwnwwsenw
    nwnwnwnwnwneseneenwnenwwneenenwnwwnw
    nwnwsewswnesenenwenweneseeneswwnenwwne
    nwseeneneneneeneneneneneswwwwewswse
    nwnenwnenenenwwswneneswnwneneneeenenwne
    swswswsweswnwwswswswsweswneswswswswsw
    seswseseswseswseswswnwseswswswseneswew
    senwwwweswnwneswenwwswnwnwnenwwse
    swswswswsewseswsewsesesesweneswsesesw
    enenewneneneeeewneneseeneeneseene
    nwnwnwnwnwwsenwnwsenwnwsenwnwwnwnenwnwnesw
    nenenenwswnwneneneneneneneenwsenenenenw
    nwnenwnwnwnwnwenwnwnwswneswnwnwnwnwnwsenw
    neenenwseswnwseswswnwwnenwnwnenenenwswsew
    sewnenwnenwenesenwwnwsenenwwne
    wswnwwswwnwnwnwnenewnwnw
    senwswneeswswswswwwswswswwsweswwsw
    esewswneeeeneeewneneneneseenenwnene
    nenwnwwneswnwswnwnenwswnwnwsenenwnenwnwnw
    wswswnwswswwswnwswwsweweswswswsw
    swswenewweswwwsweewwseswwnwnw
    swwwseswswwsenesweesweenwnewsese
    eseeseneseewsweneeeeseeeeee
    wwnwwnwnwnwwswsewnwnwnwnwewwwnw
    nwneswnwswnenwenwnwnenwnwwsenwnwnwnwne
    eeeeeeneneneeweeeese
    seseswseswneneseseswsenwseseseswseswsesee
    wswwseswswswswswewwswnwnewsww
    esenwwwseswwwnewwewnewwwww
    seeeeeneeseeesenweseesewnwesese
    eswwewwwwnwwwwwsewwwewnwsw
    seeseeseesenwnwseeswsweswseseseesesenw
    eeseeweeeseeeeeeeee
    seeeseewswsenwseenwseeseneneswese
    nwnwnwwneneneneewnwenenenenwsenwswnw
    wsesweswnewswneswsenesewswnwseswnesene
    seswseseseswseseseseswnwswswseswsesenwe
    newnenesewneneneeneneseneeneneneesw
    swswswswwsweswswwwwswsenweswnwwne
    enwwwnwswswswwsew
    nwnwnwneswnenwnwnwnenenwe
    nenwneneseswnenwnenwneswneswwswneseee
    eneneneeneswswneneenwswenwwneseenenw
    seseswnwsenwsewswnewnwwneewneswswnew
    eneneenenenenenenenenewnenenenesw
    neswneswwneneewseneneeewnwnenenwne
    swnwnewneeseswnweneswnwsenwnwwsewe
    swwenenwswwnwsweseswswsw
    senenwnenenenewnwnewnwenwnwneeneswnee
    wnewneswswswwneseswww
    sewwweswsewseswswswswnewseeneesw
    wnwnwwsewwnwneseewwwnwsenwwww
    swswswwswwswewwswswswseeswswnwswsw
    seswneswsewswswswseseeswsw
    nwwwnwsenwwseseneewwnwnwwwwnw
    swswswswnwswwswsewne
    sewneswswwweseneneeswnwnwswewswswe
    nenwenwenwnwwnwnenwnenenenwnwneswnenw
    eeneseseseseenwseswnewsesenwwew
    nenwnesenenwwnenenenwnenenwneene
    swseeseseseswsenewseseeswswnwswwswnwnwne
    nwnenwnenwwnewswswseenwnwnwnw
    seseswseswwsweswswswsenwswsenenwswswseswsw
    nwwwsewwwwwnenwnwwwwwnwsenwsew
    nenwnenwnenenenwnenwnenenesewneswnenenw
    neenwnenesenwnenwnwneenwseswnwwwnwne
    nenwnwnesenwnwenwnwsenwnwnwnwnwnwnwnww
    swwwwwswwneswwwwsewwswwswenw
    nwswswwswnwseseenww
    nenwsesewneeswnwnenesenesenenewnwneee
    swnewweneswseswswswswswswswswneswswswnwsw
    eneseneeswwnwwnwnwsesewswenwnwsewnw
    nweswnenenesenwneneneneswenenenenenenwnw
    swnwnweneseenwewnweeswsenwswswnwese
    esenwsweenwseeseeeeeesesweeese
    wwwwwwwwwwwnesewww
    swseswsesesenwseswswse
    seseseswseesewseswseseseswswsese
    wseeswswneseseswnwnwswswswnewwwwsw
    wnwenwnwswnwnwswnwewewwnwnewnwnwse
    enenwnwwwnwwwsenenwswnwseneseswnenw
    eeeeswseseeeeseeeenwswnweeese
    nwneswswswseswswwswswseeswswswwseswswsw
    swseswnwswseswneswswswswswswsweswswsww
    swswswswnwswswswsenweseseswseneseswswne
    eswwnweseesesewnwsesesenwseseneesesese
    enwseewnesweeenenwneseeswneeswenwe
    wswwswswwseewswwnwwwseswnwswenw
    nwnwnwwnwnwnwswnwnwnwe
    swsenwnenwnwnwnwwe
    nwseeseneeeeseeeeeeeswneseswe
    neeeeewnenewnesesw
    nwsewesenwnwnenenwnwsewwseneenwswnwnw
    nwsewwnenenenesenwnwsenwsewnesenenwse
    swsenenenwseseseswswsenwweeswsenwwsesw
    wewswswwswwwwnenweswwsw
    sewwwwneswnewwswwwwwwwnewwww
    nenwnesenwenenwnenesenenwswswenewwnenene
    eneeneeseeewneeneee
    seswnwwwnenwewewnwenwwnwnwsesew
    swseenewnesenwwsenwwseswnese
    senwwwwewsenwwnwnwnwnwswnwnenwwswnwne
    nwseseseneswsenenesesenewnesesenwswwseswe
    sesewnwnwnweeswnwnwwnwnwwnwnenwnwnese
    nwneneneenenwneswnwnwneneneneswnenenene
    wweseseswswneswsesweseswseseswsewswe
    esweseeeseswnwsenwseenwsenweesew
    neswseeweeesweseeseesesenwseee
    nwwnwnwswesewneenwsesewwwnwnwnww
    nesewneseneeneneeeeenenewnenenenenenw
    eswswswwswswwwwswnwswswwwswswsene
    eeneneeneenenenwnenenewneeeeewsw
    swseswneswswseseswswneseneswsesesese
    weweseneneesweswswnenwenwnwwseswse
    nenewnweesenenwneneneneeseneeneenenese
    enenwwnwnwnwnwnewnwnwwswwwnwnwwnwse
    seeseswseseeenwsesenesenwseseeeese
    neenwwnesenwneneneswsenenenwnwsenwnwwne
    swwwswswswnwwewswnewwnewwwswswsw
    seswsesesesesewsesesenewneneseesesese
    neswswnwswswswseswwnesewswnwse
    wseseswnwsenwswswswseseeeswnewseeswsw
    seseewenwseseseesesew
    seneswseswnweneseswnwwnwsenenwsenwsesww
    wwseneswswwswwneseswswswswwseswswwne"
    assert 12345 == inputstr |> Problem.load |> Problem.part1
  end
 end
