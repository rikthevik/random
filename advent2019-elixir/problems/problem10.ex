
defmodule Util do
  def slope_vec({ax, ay}, {bx, by}) do
    # Return the smallest integer slope_vec: {rise, run}
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
    {rise, run} = Util.slope_vec({x, y}, {ax, ay})
    # "blocked_after rise=#{rise} run=#{run}" |> IO.puts
    for i <- 1..50 do   # keep going for quite awhile, doesn't matter if it's past bounds
      {ax+run*i, ay+rise*i}
    end
  end

  def destroy(aset, {x, y}, {ax, ay}) do
    # Nice property: The angle from the centre is the same.
    # So we don't need to try to recalculate the visible asteroids, we can just
    # return the next asteroid that was previously blocked.  This is important.
    aset_remaining = aset |> MapSet.delete({ax, ay})
    newly_visible = blocked_after({x, y}, {ax, ay})
    |> Enum.filter(&(MapSet.member?(aset, &1)))
    |> Enum.at(0)
    { aset_remaining, newly_visible }
  end 

  def by_laser_sort({x, y}) do
    # Remember that the coordinate system grows down, so invert the y value.
    angle = -:math.atan2(-y, x) + :math.pi/2
    if angle < 0, do: angle + :math.pi*2, else: angle
  end


end

defmodule Problem10 do

  def part1(map, {w, h}) do
    aset = Asteroids.new(map, {w, h})
    for a <- aset do
      {a, Asteroids.visible_from(aset, a) |> Enum.count}
    end
    |> Enum.sort_by(fn {a, detected} -> -detected end)
    |> Enum.at(0)
  end
  
  def part2(map, {w, h}) do
    { {lx, ly}, _num_detected } = part1(map, {w, h})
    
    # Let's subtract the laser_location to make the math easier.
    aset = Asteroids.new(map, {w, h})
    |> Enum.map(fn {x, y} -> {x - lx, y - ly} end)
    |> MapSet.new
    
    visible = aset 
    |> IO.inspect
    |> Asteroids.visible_from({0, 0})
    |> Enum.map(fn {x,y} -> { Asteroids.by_laser_sort({x, y}), {x, y} } end)
    |> Enum.sort  # could use sort_by but i wanted to see this
    |> Enum.map(fn {order, asteroid} -> asteroid end)
    |> IO.inspect
    
  end

  
end

defmodule Tests do 
  use ExUnit.Case

  test "slope_vec functions" do
    assert {1, 1} == Util.slope_vec({0, 0}, {1, 1})
    assert {1, -1} == Util.slope_vec({0, 0}, {-2, 2})
  end

  test "blocked functions" do
    assert [{2, 2}, {3, 3}] = Asteroids.blocked_after({0, 0}, {1, 1}) |> Enum.take(2)
  end

  @tag :fast
  test "loading" do
    map = """
    #..
    .#.
    #.#
    """
    # Kinda janky to compare against a MapSet...
    aset = Asteroids.new(map, {3, 3})
    assert [{0, 0}, {0, 2}, {1, 1}, {2, 2}] == aset |> MapSet.to_list |> Enum.sort

    # Let's try the destroy functions
    assert [{0, 2}, {1, 1}] == aset |> Asteroids.visible_from({0, 0}) |> MapSet.to_list |> Enum.sort
    { aset, newly_visible } = aset |> Asteroids.destroy({0, 0}, {1, 1})
    assert newly_visible == {2, 2}
    assert [{0, 2}, {2, 2}] == aset |> Asteroids.visible_from({0, 0}) |> MapSet.to_list |> Enum.sort
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

  @tag :part2
  test "part 2 example" do
    map = """
    .#....#####...#..
    ##...##.#####..##
    ##...#...#.#####.
    ..#.....#...###..
    ..#.#.....#....##
    """
    { {lx, ly}, number_detected } = Problem10.part1(map, {17, 5})
    assert {lx, ly} == {8, 3}
    assert number_detected == 30

    aset = Asteroids.new(map, {17, 5})
    |> Enum.map(fn {x, y} -> {x - lx, y - ly} end)
    |> Enum.sort
    |> IO.inspect
    |> MapSet.new
    
    # assert aset |> Asteroids.visible_from({0, 0}) |> Enum.member?({1, 2})

    destroyed = Problem10.part2(map, {17, 5})
    assert [{0, -2}, {1, -3}, {1, -2}, {2, -3}, {1, -1}, {3, -2}, {4, -2}, {3, -1}, {7, -2}] == destroyed |> Enum.take(9)
  end
  

end