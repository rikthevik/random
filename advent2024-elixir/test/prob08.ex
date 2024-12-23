
defmodule Grid do
  # A grid is a {x, y} -> char mapping
  # Conventions: {x, y} = p
  # References to a grid are called g

  defstruct [:map, :w, :h]

  def load(s) do
    s
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> new()
  end

  def new(rows) do
    h = rows
    |> Enum.count()
    w = rows
    |> Enum.at(0)
    |> Enum.count()
    map = for {row, y} <- Enum.with_index(rows), {char, x} <- Enum.with_index(row), into: %{} do
      {{x, y}, char}
    end

    %Grid{
      map: map,
      w: w,
      h: h,
    }
  end
  def points(g) do
    g.map
    |> Map.keys()
    |> Enum.sort()
  end

  def get(g, p) do
    Map.get(g.map, p, "")
  end
  def set(g, p, val) do
    %Grid{g|
      map: Map.put(g.map, p, val)
    }
  end
end


defmodule Prob do
  def grid_nodes(g) do
    g.map
    |> Map.values()
    |> MapSet.new()
    |> Enum.filter(fn a -> a != "." end)
  end
  def grid_points(g, node) do
    g.map
    |> Enum.filter(fn {_, v} -> v == node end)
    |> Enum.map(fn {p, _} -> p end)
  end

  def pairs(l) do
    for x <- l, y <- l, x != y, do: {x, y}
  end

  def p1_antinodes({{ax, ay}, {bx, by}}) do
    dx = bx - ax
    dy = by - ay
    [{ax - dx, ay - dy}, {bx + dx, by + dy}]
  end
  def run1(g) do
    nodes = g
    |> grid_nodes()

    for node <- nodes do
      g
      |> grid_points(node)
      |> pairs()
      |> Enum.map(&p1_antinodes/1)
    end
    |> List.flatten()
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 and x < g.w and y < g.h end)
    |> MapSet.new()
    |> Enum.count()
  end



  def p2_antinodes({{ax, ay}, {bx, by}}) do
    dx = bx - ax
    dy = by - ay
    # kinda gross. we don't have the bounds of the grid here, so let's just go
    # 32 iterations and filter the out of bounds points later
    l = for i <- 0..32 do
      {ax - i * dx, ay - i * dy}
    end
    r = for i <- 0..32 do
      {bx + i * dx, by + i * dy}
    end
    Enum.concat(l, r)
  end

  def run2(g) do
    nodes = g
    |> grid_nodes()

    for node <- nodes do
      g
      |> grid_points(node)
      |> pairs()
      |> Enum.map(&p2_antinodes/1)
    end
    |> List.flatten()
    |> Enum.filter(fn {x, y} -> x >= 0 and y >= 0 and x < g.w and y < g.h end)
    |> MapSet.new()
    |> Enum.count()
  end
end

defmodule Parse do
  def rows(s) do
    s
    |> Grid.load()
  end


end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
............
........0...
.....0......
.......0....
....0.......
......A.....
............
............
........A...
.........A..
............
............
"""
    # assert 14 == input
    # |> Parse.rows()
    # |> Prob.run1()

    assert 34 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  # test "part1" do
  #   assert 323 == File.read!("test/input08.txt")
  #   |> Parse.rows()
  #   |> Prob.run1()
  # end

  test "part2" do
    assert 20373490 == File.read!("test/input08.txt")
    |> Parse.rows()
    |> Prob.run2()
  end


end
