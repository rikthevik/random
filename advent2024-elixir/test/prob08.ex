
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
  def nodes(g) do
    g.map
    |> Map.values()
    |> MapSet.new()
    |> Enum.filter(fn a -> a != "." end)
  end

  def run1(g) do
    g
    |> nodes()
  end

  # def run2(g) do

  # end
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
    assert 11 == input
    |> Parse.rows()
    |> Prob.run1()

    # assert 31 == input
    # |> Parse.rows()
    # |> Prob.run2()
  end

  # test "part1" do
  #   assert 1722302 == File.read!("test/input08.txt")
  #   |> Parse.rows()
  #   |> Prob.run1()
  # end

  # test "part2" do
  #   assert 20373490 == File.read!("test/input08.txt")
  #   |> Parse.rows()
  #   |> Prob.run2()
  # end


end
