
defmodule Util do

end

defmodule Part1 do
  def run(rows) do
    values = rows
    |> Enum.map(&to_value/1)

    horiz = values
    |> Enum.map(fn [horiz, _] -> horiz end)
    |> Enum.sum

    depth = values
    |> Enum.map(fn [_, depth] -> depth end)
    |> Enum.sum

    horiz * depth
  end

  def to_value(["forward", val]) do [+val, 0] end
  def to_value(["down", val]) do [0, +val] end
  def to_value(["up", val]) do [0, -val] end

end

defmodule Part2 do
  def run(rows) do
  end


end

defmodule Tests do
  use ExUnit.Case

  def parse_row(s) do
    [instruction, val] = s
    |> String.trim
    |> String.split(~r/ /)
    [instruction, String.to_integer(val)]
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&parse_row/1)
  end

  test "example" do
      input = "
forward 5
down 5
forward 8
up 3
down 8
forward 2
      "
      assert 150 == input |> prepare |> Part1.run
      # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = "122"
  end
end
