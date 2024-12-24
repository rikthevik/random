
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
end


defmodule Prob do
  def run1(rows) do

  end

  def run2(rows) do

  end
end

defmodule Parse do
  def rows(s) do

  end

  def make_row(s) do

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
