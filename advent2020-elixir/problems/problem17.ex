
use Bitwise

defmodule Util do
  
end

defmodule Problem do
  
  def load(inputstr) do
    rows = inputstr
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
  
    for {l, y} <- Enum.with_index(rows), {c, x} <- Enum.with_index(String.graphemes(l)) do
      {{x, y, 0}, c}
    end
    |> Map.new
  end

  def neighbours(space, {px, py, pz}) do
    for z <- -1..1, y <- -1..1, x <- -1..1, {x, y, z} != {0, 0, 0} do
      {px+x, py+y, pz+z}
    end
  end
  def next(space, {x, y, z}) do
    val = Map.get(space, {x, y, z}, ".")
    active_count = space
    |> neighbours({x, y, z})
    |> Enum.count(fn v -> Map.get(space, v, ".") == "#" end)
    nextval(val, active_count)
  end

  defp nextval("#", 2) do "#" end
  defp nextval("#", 3) do "#" end
  defp nextval("#", _) do "." end
  defp nextval(".", 3) do "#" end
  defp nextval(".", _) do "." end

  def getx(space) do space |> Enum.map(fn {{x, _, _}, _} -> x end) end
  def gety(space) do space |> Enum.map(fn {{_, y, _}, _} -> y end) end
  def getz(space) do space |> Enum.map(fn {{_, _, z}, _} -> z end) end

  def part1(space, iters) do
    space 
    |> step(iters)
    |> Map.values
    |> Enum.count(&(&1 == "#"))
  end

  def step(space, 0) do space end
  def step(space, iters) do
    actives = space |> Enum.filter(fn {v, c} -> c == "#" end)

    {minx, maxx} = actives |> getx |> Enum.min_max
    {miny, maxy} = actives |> gety |> Enum.min_max
    {minz, maxz} = actives |> getz |> Enum.min_max

    for z <- (-1+minz)..(maxz+1), y <- (-1+miny)..(maxy+1), x <- (-1+minx)..(maxx+1) do
      {{x, y, z}, next(space, {x, y, z})}
    end
    |> Map.new
    |> step(iters-1)
  end

#### copy paste exercise?

  def load2(inputstr) do
    rows = inputstr
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.trim/1)

    for {l, y} <- Enum.with_index(rows), {c, x} <- Enum.with_index(String.graphemes(l)) do
      {{x, y, 0, 0}, c}
    end
    |> Map.new
  end


  def neighbours2(space, {px, py, pz, pw}) do
    for w <- -1..1, z <- -1..1, y <- -1..1, x <- -1..1, {x, y, z, w} != {0, 0, 0, 0} do
      {px+x, py+y, pz+z, pw+w}
    end
  end
  def next2(space, {x, y, z, w}) do
    val = Map.get(space, {x, y, z, w}, ".")
    active_count = space
    |> neighbours2({x, y, z, w})
    |> Enum.count(fn v -> Map.get(space, v, ".") == "#" end)
    nextval(val, active_count)
  end

  def getx2(space) do space |> Enum.map(fn {{x, _, _, _}, _} -> x end) end
  def gety2(space) do space |> Enum.map(fn {{_, y, _, _}, _} -> y end) end
  def getz2(space) do space |> Enum.map(fn {{_, _, z, _}, _} -> z end) end
  def getw2(space) do space |> Enum.map(fn {{_, _, _, w}, _} -> w end) end

  def part2(space, iters) do
    space 
    |> step2(iters)
    |> Map.values
    |> Enum.count(&(&1 == "#"))
  end

  def step2(space, 0) do space end
  def step2(space, iters) do
    actives = space |> Enum.filter(fn {v, c} -> c == "#" end)

    {minx, maxx} = actives |> getx2 |> Enum.min_max
    {miny, maxy} = actives |> gety2 |> Enum.min_max
    {minz, maxz} = actives |> getz2 |> Enum.min_max
    {minw, maxw} = actives |> getw2 |> Enum.min_max

    for w <- (-1+minw)..(maxw+1), z <- (-1+minz)..(maxz+1), y <- (-1+miny)..(maxy+1), x <- (-1+minx)..(maxx+1) do
      {{x, y, z, w}, next2(space, {x, y, z, w})}
    end
    |> Map.new
    |> step2(iters-1)
  end
end

defmodule Tests do 
  use ExUnit.Case

  test "example1" do
    inputstr = ".#.
    ..#
    ###"
    assert 5 == inputstr |> Problem.load |> Problem.part1(0)
    assert 11 == inputstr |> Problem.load |> Problem.part1(1)
    assert 21 == inputstr |> Problem.load |> Problem.part1(2)
    assert 38 == inputstr |> Problem.load |> Problem.part1(3)
    assert 112 == inputstr |> Problem.load |> Problem.part1(6)
    assert 848 == inputstr |> Problem.load2 |> Problem.part2(6)
  end

  test "go time" do
    inputstr = "......##
    ####.#..
    .##....#
    .##.#..#
    ........
    .#.#.###
    #.##....
    ####.#.."
    assert 426 == inputstr |> Problem.load |> Problem.part1(6)
    assert 1892 == inputstr |> Problem.load2 |> Problem.part2(6)
  end
end
