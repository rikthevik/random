

defmodule Util do
  
end

defmodule Problem do

  def load(inputstr) do
    inputstr 
    |> String.trim
    |> String.split(~r/ *\n *\n */)
    |> Enum.map(&load_row/1)
    |> IO.inspect
  end

  def load_row(rowstr) do
    [idline|rows] = rowstr |> String.split(~r/\n/)
    [_, idstr] = Regex.run(~r/Tile (\d+):/, idline)
    id = idstr |> String.to_integer

    # Make sure our tiles are okay.
    10 = rows |> Enum.count
    10 = rows |> Enum.at(0) |> String.length
    
    # clockwise around so we maintain our orientation
    top = rows |> Enum.at(0)
    right = rows |> Enum.map(fn s -> String.at(s, 9) end) |> Enum.join("")
    bottom = rows |> Enum.at(9) |> String.reverse
    left = rows |> Enum.reverse |> Enum.map(fn s -> String.at(s, 0) end) |> Enum.join("")

    {id, [top, right, bottom, left]}
  end
    
  

  def part1(rows) do
    rows |> IO.inspect
  end



end



defmodule Tests do 
  use ExUnit.Case

  test "example1" do
    inputstr = """
    Tile 2311:
    ..##.#..#.
    ##..#.....
    #...##..#.
    ####.#...#
    ##.##.###.
    ##...#.###
    .#.#.#..##
    ..#....#..
    ###...#.#.
    ..###..###

    Tile 1951:
    #.##...##.
    #.####...#
    .....#..##
    #...######
    .##.#....#
    .###.#####
    ###.##.##.
    .###....#.
    ..#.#..#.#
    #...##.#..

    Tile 1171:
    ####...##.
    #..##.#..#
    ##.#..#.#.
    .###.####.
    ..###.####
    .##....##.
    .#...####.
    #.##.####.
    ####..#...
    .....##...

    Tile 1427:
    ###.##.#..
    .#..#.##..
    .#.##.#..#
    #.#.#.##.#
    ....#...##
    ...##..##.
    ...#.#####
    .#.####.#.
    ..#..###.#
    ..##.#..#.

    Tile 1489:
    ##.#.#....
    ..##...#..
    .##..##...
    ..#...#...
    #####...#.
    #..#.#.#.#
    ...#.#.#..
    ##.#...##.
    ..##.##.##
    ###.##.#..

    Tile 2473:
    #....####.
    #..#.##...
    #.##..#...
    ######.#.#
    .#...#.#.#
    .#########
    .###.#..#.
    ########.#
    ##...##.#.
    ..###.#.#.

    Tile 2971:
    ..#.#....#
    #...###...
    #.#.###...
    ##.##..#..
    .#####..##
    .#..####.#
    #..#.#..#.
    ..####.###
    ..#.#.###.
    ...#.#.#.#

    Tile 2729:
    ...#.#.#.#
    ####.#....
    ..#.#.....
    ....#..#.#
    .##..##.#.
    .#.####...
    ####.#.#..
    ##.####...
    ##..#.##..
    #.##...##.

    Tile 3079:
    #.#.#####.
    .#..######
    ..#.......
    ######....
    ####.#..#.
    .#...#.##.
    #.#####.##
    ..#.###...
    ..#.......
    ..#.###...
    """
    assert 20899048083289 == inputstr |> Problem.load |> Problem.part1

  end

  
end
