

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
      val = case Integer.parse(char) do
        {v, _} -> v
        :error -> nil
      end
      {{x, y}, val}
    end

    %Grid{
      map: map,
      w: w,
      h: h,
    }
  end

  def get(g, p) do
    Map.get(g.map, p, nil)
  end
  def set(g, p, val) do
    %Grid{g|
      map: Map.put(g.map, p, val)
    }
  end
end

defmodule Prob do
  def fetch_start_points(g) do
    g.map
    |> Enum.filter(fn {_, v} -> v == 0 end)
    |> Enum.map(fn {p, _} -> p end)
    |> Enum.sort()
  end
  def points_near({x, y}) do
    [
      {x+1, y},
      {x-1, y},
      {x, y-1},
      {x, y+1},
    ]
  end

  def run1(g) do
    g
    |> fetch_start_points()
    |> Enum.map(fn p -> p1_start_walk(g, p, :p1) end)
    |> IO.inspect
    |> Enum.sum()
  end

  def run2(g) do
    g
    |> fetch_start_points()
    |> Enum.map(fn p -> p1_start_walk(g, p, :p2) end)
    |> IO.inspect
    |> Enum.sum()
  end

  def p1_should_walk?(g, here, next) do
    # Grid.get(g, next) |> IO.inspect(label: "next")
    # Grid.get(g, here) |> IO.inspect(label: "here")
    Grid.get(g, next) != nil and Grid.get(g, here) + 1 == Grid.get(g, next)
  end

  def p1_start_walk(g, p, mode) do
    p1_walk(g, p, 0, [], mode)
    |> List.flatten()
    |> MapSet.new()
    |> Enum.count()
  end

  def p1_walk(_, here, 9, _path, :p1) do
    # Just return the 9 point
    here
  end
  def p1_walk(_, here, 9, path, :p2) do
    [here|path]
    |> Enum.reverse()
    |> List.to_tuple()
  end
  def p1_walk(g, here, height, path, mode) do
    # {here, height, path} |> IO.inspect()
    for p <- points_near(here), p1_should_walk?(g, here, p) do
      p1_walk(g, p, height+1, [here|path], mode)
    end
  end

  # def run2(g) do

  # end
end

defmodule Parse do
  def rows(s) do
    s |> Grid.load()
  end

end



defmodule Tests do
  use ExUnit.Case

  test "example00" do
    input = """
..90..9
...1.98
...2..7
6543456
765.987
876....
987....
"""
    assert 4 == input
    |> Parse.rows()
    |> Prob.run1()
  end

  test "example0" do
    input = """
10..9..
2...8..
3...7..
4567654
...8..3
...9..2
.....01
"""
    assert 3 == input
    |> Parse.rows()
    |> Prob.run1()
  end

  test "example1" do
    input = """
89010123
78121874
87430965
96549874
45678903
32019012
01329801
10456732
"""
    assert 36 == input
    |> Parse.rows()
    |> Prob.run1()

    assert 81 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 688 == File.read!("test/input10.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 1459 == File.read!("test/input10.txt")
    |> Parse.rows()
    |> Prob.run2()
  end

end
