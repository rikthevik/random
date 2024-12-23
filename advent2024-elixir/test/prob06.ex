
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

defmodule Dude do
  defstruct [:x, :y, :dx, :dy, :path, :g]
  def new(g, {x, y}, {dx, dy}) do
    %Dude{
      x: x,
      y: y,
      dx: dx,
      dy: dy,
      path: [],
      g: g,
    }
  end

  def path_key(dude) do
    {{dude.x, dude.y}, {dude.dx, dude.dy}}
  end

  def p1_move(dude) do
    if path_key(dude) in dude.path do
      :loop
    else
      next_pos = {dude.x + dude.dx, dude.y + dude.dy}
      next_tile = Grid.get(dude.g, next_pos)
      p1_try_move(dude, next_pos, next_tile)
    end
  end

  def p1_try_move(dude, _, "#") do
    {dx, dy} = turn_right({dude.dx, dude.dy})
    %Dude{dude|
      dx: dx,
      dy: dy,
      path: [path_key(dude)|dude.path],
    }
    |> p1_move()
  end
  def p1_try_move(dude, {x, y}, tile) when tile in ["^", "."] do
    %Dude{dude|
      x: x,
      y: y,
      path: [path_key(dude)|dude.path],
    }
    |> p1_move()
  end
  def p1_try_move(dude, _, "") do
    %Dude{dude|
      path: [path_key(dude)|dude.path],
    }
  end

  def turn_right({+1, +0}) do {+0, +1} end
  def turn_right({+0, +1}) do {-1, +0} end
  def turn_right({-1, +0}) do {+0, -1} end
  def turn_right({+0, -1}) do {+1, +0} end

end


defmodule Prob do


  def run1(g) do
    start_pos = g.map
    |> Enum.filter(fn {_, v} -> v == "^" end)
    |> Enum.at(0)
    |> elem(0)

    d = Dude.new(g, start_pos, {0, -1})
    |> Dude.p1_move()

    d.path
    |> Enum.map(fn {p, _dir} -> p end)
    |> MapSet.new()
    |> Enum.count()

  end

  def run2(g) do
    start_pos = g.map
    |> Enum.filter(fn {_, v} -> v == "^" end)
    |> Enum.at(0)
    |> elem(0)

    # trim the first and last points?
    d = Dude.new(g, start_pos, {0, -1})
    |> Dude.p1_move()

    path_points = d.path
    |> Enum.drop(1)

    # Try putting a wall at each point in the path
    # and see if it turns into a :loop
    for {p, _} <- path_points do
      {p, g
      |> Grid.set(p, "#")
      |> Dude.new(start_pos, {0, -1})
      |> Dude.p1_move()}
    end
    |> Enum.filter(fn {_, v} -> v == :loop end)
    |> Enum.map(fn {p, _v} -> p end)
    |> MapSet.new()
    |> IO.inspect(label: "wat")
    |> Enum.count()

  end
end

defmodule Parse do
  def load(s) do
    s
    |> Grid.load()
  end


end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#...
"""
    assert 41 == input
    |> Parse.load()
    |> Prob.run1()

    assert 6 == input
    |> Parse.load()
    |> Prob.run2()
  end

  # test "part1" do
  #   assert 4890 == File.read!("test/input06.txt")
  #   |> Parse.load()
  #   |> Prob.run1()
  # end

  # test "part2" do
  #   assert 20373490 == File.read!("test/input00.txt")
  #   |> Parse.load()
  #   |> Prob.run2()
  # end

end
