

defmodule Util do
  
end




defmodule Problem do

  defstruct [:w, :tiles, :sol]
  def new(tiles) do
    %Problem{
      w: Integer.floor(:math.sqrt(Enum.count(tiles)))
    }
  end

  def try(p, {0, 0}, tileid) do 
    # top left corner piece
    # needs to have 0 match left and 0 match top
  def try(p, {x, 0}, tileid) do 
    # top row
    # needs to have 1 match left and 0 match top
  end
  def try(p, {0, y}, tileid) do 
    # left side
    # needs to have 0 match left and 1 match top
  end
  def try(p, {0, y}, tileid) do 
    # middle somewhere
  end

  def load(inputstr) do
    inputstr 
    |> String.trim
    |> String.split(~r/ *\n *\n */)
    |> Enum.map(&load_tile/1)
    |> IO.inspect
  end



  def load_tile(rowstr) do
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
    

  def orient(sides, :normal) do sides end
  def orient(sides, :vflip) do vflip(sides) end
  def orient(sides, :hflip) do hflip(sides) end
  def vflip([top, right, bottom, left]) do
    [bottom, String.reverse(right), top, String.reverse(left)]
  end
  def hflip([top, right, bottom, left]) do
    [String.reverse(top), left, String.reverse(bottom), right]
  end
  def rotate_cw(sides, 0) do sides end
  def rotate_cw([top, right, bottom, left], times) do
    rotate_cw([left, top, right, bottom], times-1)
  end

  def part1(tiles) do
    tiles |> IO.inspect

    # tilemap = for {id, sides} <- tiles, orientation <- [:normal, :vflip, :hflip] do
    #   {{id, orientation}, orient(orientation, sides)}
    # end
    # |> Map.new
    # |> IO.inspect
    
    # edges = for {id, sides} <- tiles do
    #   for orientation <- [:normal, :vflip, :hflip] do
    #     for side <- orient(sides, orientation) do
    #       {side, {id, orientation}}
    #     end
    #   end
    # end
    # |> List.flatten
    # |> IO.inspect

    for {id, sides} <- tiles |> Enum.slice(0, 1) do
      for orientation <- [:normal, :vflip, :hflip] do
        oriented_sides = orient(sides, orientation)
        for i <- 0..3 do
          [top, _right, _bottom, left] = oriented_sides |> rotate_cw(i)
          # looking for a left and a top that has no other matches
          
        end
      end
      
    end


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
