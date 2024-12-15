

defmodule Grid do
  # A grid is a {x, y} -> char mapping
  # Conventions: {x, y} = p
  # References to a grid are called g

  defstruct [:map, :w, :h]
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
end

defmodule Prob do
  def found_mas?(g, {x, y}, {dx, dy}) do
    Grid.get(g, {x + dx * 1, y + dy * 1}) == "M"
    and Grid.get(g, {x + dx * 2, y + dy * 2}) == "A"
    and Grid.get(g, {x + dx * 3, y + dy * 3}) == "S"
  end

  def found_xmas_count(g, p) do
    directions = [
      {+1, +0}, # right
      {-1, +0}, # left
      {+0, -1}, # up
      {+0, +1}, # down
      {+1, -1}, # upright
      {-1, -1}, # upleft
      {+1, +1}, # downright
      {-1, +1}, # downleft
    ]
    directions
    |> Enum.filter(fn d -> found_mas?(g, p, d) end)
    |> Enum.count()
  end

  def run1(rows) do
    g = rows
    |> Grid.new()

    points = g
    |> Grid.points()
    |> Enum.filter(fn p -> Grid.get(g, p) == "X" end)  # gotta start with X
    |> Enum.map(fn p -> found_xmas_count(g, p) end)
    |> Enum.sum()

  end

  def run2(rows) do
    g = rows
    |> Grid.new()

    points = g
    |> Grid.points()
    |> Enum.filter(fn p -> Grid.get(g, p) == "A" end)  # gotta start with A
    |> Enum.filter(fn p -> found_p2(g, p) end)
    |> Enum.count()
  end

  def found_p2(g, {x, y}) do
    a = Grid.get(g, {x-1, y-1}) <> Grid.get(g, {x+1, y+1})
    b = Grid.get(g, {x-1, y+1}) <> Grid.get(g, {x+1, y-1})
    (a == "MS" or a == "SM") and (b == "MS" or b == "SM")
  end
end

defmodule Parse do
  def rows(s) do
    s
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    # |> Enum.take(1)
  end
end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""
    assert 18 == input
    |> Parse.rows()
    |> Prob.run1()

    assert 9 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 2401 == File.read!("test/input04.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 1822 == File.read!("test/input04.txt")
    |> Parse.rows()
    |> Prob.run2()
  end

end
