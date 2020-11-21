
defmodule Util do
  def slope({ax, ay}, {bx, by}) do
    # Return the smallest integer slope: {rise, run}
    {rise, run} = {by - ay, bx - ax}
    divisor = Integer.gcd(rise, run)
    {Integer.floor_div(rise, divisor), Integer.floor_div(run, divisor)}
  end

  
end

defmodule Asteroids do
  def new(s, {w, h}) do
    lines = s
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
    
  end
  def look_at({x, y}, [a|remaining]) do

  end
  def blocked_after({x, y}, {ax, ay}, iterations) do
    {rise, run} = Util.slope({x, y}, {ax, ay})
    "blocked_after rise=#{rise} run=#{run}" |> IO.puts
    for i <- 1..iterations do
      {ax+run*i, ay+rise*i}
    end
  end
end

defmodule Problem09 do
  def part1(s) do
  
  end
  def num_visible(start, asteroids) do
    # Assume that you can see the set of all asteroids.
    # Look at one asteroid, find the slope you're looking at it at.
    # Then remove all of the asteroids behind it from the set.
    # Do that for each asteroid - the remaining should be the count.
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
    assert [{2, 2}, {3, 3}] = Asteroids.blocked_after({0, 0}, {1, 1}, 2)
  end

  test "loading" do
    map = """
    .#.
    ..#
    """
    # Kinda janky to compare against a MapSet...
    assert [{1, 0}, {2, 1}] == Asteroids.new(map, {3, 2}) |> MapSet.to_list |> Enum.sort
  end

  test "loading2" do
    map = """
    .#..#
    .....
    #####
    ....#
    ...##
    """
    a = Asteroids.new(map, {5, 5})
    assert 6 == a |> Asteroids.visible_from({0, 2})
  end
 

end