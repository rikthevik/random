

defmodule Util do
  
end




defmodule Problem do

  defstruct [:bound, :border_to_id, :id_to_variations]

  def new(tiles) do
    id_to_variations = tiles
    |> Enum.map(fn {id, sides} -> {id, variations(sides)} end)
    |> Map.new

    border_to_id = for {id, sides_list} <- id_to_variations do
      for sides <- sides_list do
        for border <- sides do
          {border, id}
        end
      end
    end
    |> List.flatten
    |> Enum.group_by(fn {b, id} -> b end, fn {b, id} -> id end)
    |> Enum.map(fn {b, ids} -> {b, MapSet.new(ids)} end)
    |> Map.new
    |> IO.inspect

    %Problem{
      bound: Kernel.floor(:math.sqrt(Enum.count(tiles))) - 1,
      id_to_variations: id_to_variations,
      border_to_id: border_to_id,
    }
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

    # no alarms and no surprises
    10 = rows |> Enum.count
    10 = rows |> Enum.at(0) |> String.length
    
    # clockwise around so we maintain our orientation
    top = rows |> Enum.at(0)
    right = rows |> Enum.map(fn s -> String.at(s, 9) end) |> Enum.join("")
    bottom = rows |> Enum.at(9) |> String.reverse
    left = rows |> Enum.reverse |> Enum.map(fn s -> String.at(s, 0) end) |> Enum.join("")

    {id, [left, top, right, bottom]}
  end
    

  def orient(sides, :normal) do sides end
  def orient(sides, :vflip) do vflip(sides) end
  def orient(sides, :hflip) do hflip(sides) end
  def vflip([left, top, right, bottom]) do
    [bottom, String.reverse(right), top, String.reverse(left)]
  end
  def hflip([left, top, right, bottom]) do
    [String.reverse(top), left, String.reverse(bottom), right]
  end
  def rotate_cw(sides, 0) do sides end
  def rotate_cw([left, top, right, bottom], times) do
    rotate_cw([left, top, right, bottom], times-1)
  end
  
  def variations(sides) do
    for orientation <- [:normal, :vflip, :hflip], oriented_sides = orient(sides, orientation), i <- 0..3 do
      oriented_sides |> rotate_cw(i)
    end
  end

  def part1(tiles) do
    prob = Problem.new(tiles)
    |> IO.inspect

    ids = Map.keys(prob.id_to_variations)

    id = 1951
    remaining = Enum.filter(ids, fn i -> i != id end)
    attempt(prob, {0, 0}, id, remaining)
  end

  def attempt(prob, {0, 0}, id, remaining) do
    "PUTS #{id} #{inspect remaining}" |> IO.puts
    for sides <- prob.id_to_variations[id] do 
      "SIDES #{id} => #{inspect sides}" |> IO.puts
      goforit(prob, {0, 0}, id, sides)
    end
  end

  def goforit(prob, {0, 0}, id, sides) do
    
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
