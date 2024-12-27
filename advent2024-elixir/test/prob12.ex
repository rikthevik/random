
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

  def set(g, k, v) do
    %Grid{g|
      map: Map.put(k, v),
    }
  end
  def popfirst(g) do
    [first] = g.map
    |> Enum.keys()
    |> Enum.take(1)
    %Grid{g|
      map: Map.delete(g.map)
    }
  end
end


defmodule Prob do
  def points_near({x, y}) do
    [
      {x+1, y},
      {x-1, y},
      {x, y-1},
      {x, y+1},
    ]
  end

  def find_regions(g) do
    [point] = g.map
    |> Map.keys()
    |> Enum.take(1)


  end


  def run1(g) do
    find_regions(g)
  end

  # def run2(rows) do

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

  # setup do
  #   _pid = start_supervised!(State)
  #   :ok
  # end

  test "example1" do
    input = """
OOOOO
OXOXO
OOOOO
OXOXO
OOOOO
"""
    assert 11 == input
    |> Parse.rows()
    |> Prob.run1()

    # assert 31 == input
    # |> Parse.rows()
    # |> Prob.run2()
  end

  # test "part1" do
  #   assert 1722302 == File.read!("test/input00.txt")
  #   |> Parse.rows()
  #   |> Prob.run1()
  # end

  # test "part2" do
  #   assert 20373490 == File.read!("test/input00.txt")
  #   |> Parse.rows()
  #   |> Prob.run2()
  # end


end
