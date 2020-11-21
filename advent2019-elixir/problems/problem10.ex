
defmodule Util do
  def slope({ax, ay}, {bx, by}) do
    # Return the smallest integer slope: {rise, run}
    {rise, run} = {by - ay, bx - ax}
    divisor = Integer.gcd(rise, run)
    {Integer.floor_div(rise, divisor), Integer.floor_div(run, divisor)}
  end

  
end

defmodule Asteroids do
  def new(map, {w, h}) do
    lines = map
    |> String.trim
    |> String.split("\n")  
    
    # I feel like there's another nicer way to write this...
    for y <- 0..(h-1), x <- 0..(w-1) do
      case lines |> Enum.at(y) |> String.at(x) do
        "#" -> {x, y}  # We found an asteroid, return its location.
        _ -> nil
      end
    end
    |> Enum.filter(fn a -> a end)  # Drop non-asteroid positions.
    |> MapSet.new
  end
  
  def visible_from(aset, {x, y}) do
    # Let's go through all of the other asteroids and find the paths they block.
    # If we have a list of asteroids we know are definitely blocked,
    #  hopefully the remaining asteroids should be the ones we can see.
    blocked_paths = MapSet.new(look_at({x, y}, MapSet.to_list(aset)))
    remaining_asteroids = aset 
    |> MapSet.delete({x, y})              # Remove the current asteroid!
    |> MapSet.difference(blocked_paths)   # Remove all of the blocked ones.
  end
  
  
  def look_at({x, y}, []) do [] end
  def look_at({x, y}, [{ax, ay}|remaining]) do
    blocked_after({x, y}, {ax, ay}) ++ look_at({x, y}, remaining)
  end

  def blocked_after({x, y}, {x, y}) do [] end
  def blocked_after({x, y}, {ax, ay}) do
    # What are all of the paths blocked by the second asteroid?
    #  Does not include the second asteroid!
    {rise, run} = Util.slope({x, y}, {ax, ay})
    # "blocked_after rise=#{rise} run=#{run}" |> IO.puts
    for i <- 1..50 do   # keep going for quite awhile, doesn't matter if it's past bounds
      {ax+run*i, ay+rise*i}
    end
  end

  def destroy(aset) do

  end

end

defmodule Problem10 do

  def part1(map, {w, h}) do
    alist = Asteroids.new(map, {w, h})
    for a <- alist do
      {a, Asteroids.visible_from(alist, a) |> Enum.count}
    end
    |> Enum.sort_by(fn {a, detected} -> -detected end)
    |> Enum.at(0)
  end
  
  def part2(s) do

  end
end

defmodule Tests do 
  use ExUnit.Case

  test "slope functions" do
    assert {1, 1} == Util.slope({0, 0}, {1, 1})
    assert {1, -1} == Util.slope({0, 0}, {-2, 2})
  end

  test "blocked functions" do
    assert [{2, 2}, {3, 3}] = Asteroids.blocked_after({0, 0}, {1, 1}) |> Enum.take(2)
  end

  test "loading" do
    map = """
    .#.
    ..#
    """
    # Kinda janky to compare against a MapSet...
    assert [{1, 0}, {2, 1}] == Asteroids.new(map, {3, 2}) |> MapSet.to_list |> Enum.sort
  end

  test "example 1" do
    map = """
    .#..#
    .....
    #####
    ....#
    ...##
    """
    a = Asteroids.new(map, {5, 5})
    assert 7 == a |> Asteroids.visible_from({1, 0}) |> Enum.count
    assert 7 == a |> Asteroids.visible_from({4, 0}) |> Enum.count
    assert 6 == a |> Asteroids.visible_from({0, 2}) |> Enum.count
    assert 7 == a |> Asteroids.visible_from({1, 2}) |> Enum.count
    assert 7 == a |> Asteroids.visible_from({2, 2}) |> Enum.count
    assert 7 == a |> Asteroids.visible_from({3, 2}) |> Enum.count
    assert 5 == a |> Asteroids.visible_from({4, 2}) |> Enum.count
    assert 7 == a |> Asteroids.visible_from({4, 3}) |> Enum.count
    assert 8 == a |> Asteroids.visible_from({3, 4}) |> Enum.count
    assert 7 == a |> Asteroids.visible_from({4, 4}) |> Enum.count
    { best_location, number_detected } = Problem10.part1(map, {5, 5})
    assert best_location == {3, 4}
    assert number_detected == 8
  end
 
  test "example 2" do
    map = """
    ......#.#.
    #..#.#....
    ..#######.
    .#.#.###..
    .#..#.....
    ..#....#.#
    #..#....#.
    .##.#..###
    ##...#..#.
    .#....####
    """
    { best_location, number_detected } = Problem10.part1(map, {10, 10})
    assert best_location == {5, 8}
    assert number_detected == 33
  end

  test "example 3" do
    map = """
    #.#...#.#.
    .###....#.
    .#....#...
    ##.#.#.#.#
    ....#.#.#.
    .##..###.#
    ..#...##..
    ..##....##
    ......#...
    .####.###.
    """
    { best_location, number_detected } = Problem10.part1(map, {10, 10})
    assert best_location == {1, 2}
    assert number_detected == 35
  end
  
  test "example 4" do
    map = """
    .#..#..###
    ####.###.#
    ....###.#.
    ..###.##.#
    ##.##.#.#.
    ....###..#
    ..#.#..#.#
    #..#.#.###
    .##...##.#
    .....#.#..
    """
    { best_location, number_detected } = Problem10.part1(map, {10, 10})
    assert best_location == {6, 3}
    assert number_detected == 41
  end

  test "part1" do
    map = """
    ##.###.#.......#.#....#....#..........#.
    ....#..#..#.....#.##.............#......
    ...#.#..###..#..#.....#........#......#.
    #......#.....#.##.#.##.##...#...#......#
    .............#....#.....#.#......#.#....
    ..##.....#..#..#.#.#....##.......#.....#
    .#........#...#...#.#.....#.....#.#..#.#
    ...#...........#....#..#.#..#...##.#.#..
    #.##.#.#...#..#...........#..........#..
    ........#.#..#..##.#.##......##.........
    ................#.##.#....##.......#....
    #............#.........###...#...#.....#
    #....#..#....##.#....#...#.....#......#.
    .........#...#.#....#.#.....#...#...#...
    .............###.....#.#...##...........
    ...#...#.......#....#.#...#....#...#....
    .....#..#...#.#.........##....#...#.....
    ....##.........#......#...#...#....#..#.
    #...#..#..#.#...##.#..#.............#.##
    .....#...##..#....#.#.##..##.....#....#.
    ..#....#..#........#.#.......#.##..###..
    ...#....#..#.#.#........##..#..#..##....
    .......#.##.....#.#.....#...#...........
    ........#.......#.#...........#..###..##
    ...#.....#..#.#.......##.###.###...#....
    ...............#..#....#.#....#....#.#..
    #......#...#.....#.#........##.##.#.....
    ###.......#............#....#..#.#......
    ..###.#.#....##..#.......#.............#
    ##.#.#...#.#..........##.#..#...##......
    ..#......#..........#.#..#....##........
    ......##.##.#....#....#..........#...#..
    #.#..#..#.#...........#..#.......#..#.#.
    #.....#.#.........#............#.#..##.#
    .....##....#.##....#.....#..##....#..#..
    .#.......#......#.......#....#....#..#..
    ...#........#.#.##..#.#..#..#........#..
    #........#.#......#..###....##..#......#
    ...#....#...#.....#.....#.##.#..#...#...
    #.#.....##....#...........#.....#...#...
    """
    { best_location, number_detected } = Problem10.part1(map, {40, 40})
    assert best_location == {31, 20}
    assert number_detected == 319
  end


  

end