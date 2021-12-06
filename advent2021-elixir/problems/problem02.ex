
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
  defstruct [:aim, :depth, :horiz]

  def new() do
    %Part2{
      aim: 0,
      depth: 0,
      horiz: 0,
    }
  end

  def run(rows) do
    prob = Part2.new
    |> process_instruction(rows)
    |> IO.inspect
    prob.depth * prob.horiz
  end

  def doit(prob, ["forward", val]) do
    %Part2{prob|
      horiz: prob.horiz + val,
      depth: prob.depth + (prob.aim * val),
    }
  end
  def doit(prob, ["up", val]) do
    %Part2{prob|
      aim: prob.aim - val,
    }
  end
  def doit(prob, ["down", val]) do
    %Part2{prob|
      aim: prob.aim + val,
    }
  end

  def process_instruction(prob, []) do prob end
  def process_instruction(prob, [inst|rest]) do
    process_instruction(doit(prob, inst) |> IO.inspect, rest)
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
      assert 900 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = "forward 2
    down 4
    down 1
    down 4
    forward 3
    down 6
    down 5
    forward 3
    forward 8
    down 2
    down 3
    up 8
    down 5
    up 7
    down 7
    forward 5
    up 2
    down 6
    forward 7
    forward 1
    forward 2
    forward 7
    up 7
    forward 6
    down 3
    down 1
    up 9
    down 2
    up 1
    down 1
    up 6
    forward 6
    down 7
    forward 6
    up 1
    down 6
    forward 2
    up 7
    forward 4
    forward 8
    forward 7
    down 7
    forward 8
    down 1
    down 6
    down 7
    forward 4
    down 3
    up 7
    down 5
    down 9
    up 8
    up 4
    down 2
    down 3
    up 7
    forward 6
    forward 6
    forward 8
    forward 2
    up 5
    down 8
    down 3
    down 3
    down 4
    down 9
    down 6
    up 6
    forward 4
    down 6
    forward 3
    forward 3
    down 4
    down 8
    down 2
    up 5
    up 5
    forward 3
    forward 5
    down 7
    forward 6
    forward 9
    forward 8
    forward 2
    down 3
    down 3
    down 7
    down 1
    down 1
    down 1
    down 2
    down 8
    down 6
    forward 6
    up 1
    up 6
    down 7
    down 1
    forward 1
    up 2
    up 8
    up 8
    forward 2
    down 1
    down 8
    down 7
    down 1
    forward 1
    down 9
    up 3
    down 3
    forward 2
    down 3
    up 6
    down 2
    forward 7
    down 9
    down 6
    down 1
    forward 6
    down 4
    down 1
    down 3
    forward 3
    down 5
    forward 9
    down 5
    down 7
    up 8
    forward 8
    forward 8
    down 6
    down 1
    forward 8
    down 4
    up 4
    up 4
    up 2
    forward 2
    forward 2
    down 1
    up 8
    down 1
    down 7
    forward 5
    down 9
    down 2
    up 3
    down 1
    down 5
    forward 6
    down 7
    up 3
    forward 7
    down 4
    down 3
    forward 4
    up 8
    down 4
    forward 4
    forward 2
    forward 5
    down 5
    up 2
    forward 4
    down 4
    forward 6
    down 4
    forward 1
    down 5
    forward 2
    forward 2
    down 8
    forward 4
    forward 7
    down 3
    up 3
    forward 2
    forward 6
    forward 8
    down 2
    forward 4
    down 2
    up 9
    down 9
    down 2
    forward 5
    up 4
    forward 2
    down 2
    down 3
    forward 1
    down 2
    forward 8
    forward 8
    down 4
    forward 6
    down 3
    down 3
    down 5
    forward 8
    forward 4
    forward 1
    up 4
    up 2
    forward 8
    down 8
    forward 2
    forward 6
    up 1
    up 5
    forward 2
    forward 4
    forward 7
    forward 8
    forward 2
    down 3
    down 1
    down 9
    down 6
    up 5
    up 6
    forward 6
    down 3
    down 2
    down 1
    forward 5
    forward 2
    forward 7
    down 8
    down 7
    forward 7
    up 8
    forward 7
    down 1
    up 4
    forward 9
    forward 4
    forward 1
    down 3
    down 9
    down 7
    forward 1
    down 3
    forward 3
    down 4
    down 7
    forward 4
    up 6
    down 8
    up 1
    forward 6
    forward 1
    down 7
    down 8
    up 9
    up 4
    down 3
    down 7
    forward 8
    up 2
    up 6
    forward 8
    down 1
    up 4
    up 4
    forward 8
    down 2
    down 4
    down 3
    forward 5
    down 8
    forward 1
    down 2
    forward 9
    forward 3
    up 6
    down 6
    forward 6
    forward 4
    down 6
    down 3
    down 3
    forward 6
    down 5
    up 4
    down 9
    down 3
    down 6
    up 9
    forward 6
    down 2
    forward 7
    up 8
    down 3
    down 7
    down 9
    forward 6
    down 1
    forward 2
    down 1
    down 3
    down 3
    forward 5
    forward 2
    up 5
    forward 4
    up 7
    down 9
    forward 7
    forward 3
    down 6
    forward 1
    down 1
    up 8
    down 9
    up 3
    down 7
    up 9
    forward 7
    down 7
    down 9
    forward 9
    forward 7
    up 9
    down 7
    down 2
    down 7
    up 2
    down 3
    down 9
    down 6
    forward 7
    forward 8
    forward 8
    forward 6
    forward 9
    forward 4
    down 4
    down 5
    down 7
    forward 6
    forward 2
    forward 4
    forward 9
    down 4
    forward 6
    down 7
    up 1
    down 7
    forward 9
    forward 7
    down 4
    down 3
    up 6
    forward 8
    forward 7
    down 8
    forward 4
    up 6
    up 4
    forward 9
    forward 4
    forward 4
    forward 7
    down 1
    up 6
    forward 8
    forward 3
    up 6
    forward 4
    down 1
    up 2
    forward 1
    down 5
    forward 5
    up 4
    down 6
    down 3
    up 8
    forward 9
    down 2
    forward 4
    forward 8
    down 9
    forward 5
    forward 2
    down 9
    down 8
    forward 8
    down 7
    up 6
    forward 1
    up 9
    up 3
    forward 9
    down 6
    forward 9
    down 3
    down 3
    forward 7
    forward 5
    down 8
    down 9
    down 3
    down 6
    up 8
    down 9
    forward 8
    down 7
    down 5
    down 1
    up 4
    down 9
    forward 6
    forward 9
    up 6
    up 4
    forward 3
    forward 2
    forward 1
    down 1
    down 2
    forward 8
    up 6
    forward 5
    up 4
    down 1
    forward 5
    down 3
    down 6
    up 7
    forward 2
    forward 6
    forward 7
    forward 4
    down 5
    down 4
    forward 4
    down 6
    up 2
    up 2
    forward 7
    forward 3
    down 8
    down 1
    down 8
    forward 7
    forward 7
    up 5
    forward 4
    up 8
    down 9
    down 4
    down 4
    forward 5
    down 1
    forward 2
    down 6
    up 4
    down 8
    down 1
    down 9
    down 5
    up 5
    forward 4
    down 2
    down 8
    down 4
    forward 4
    forward 5
    down 8
    up 9
    forward 7
    forward 6
    down 8
    down 3
    up 7
    down 7
    forward 2
    forward 5
    forward 7
    down 9
    up 1
    down 6
    down 2
    forward 6
    forward 3
    forward 3
    up 9
    forward 4
    down 5
    down 7
    forward 8
    forward 6
    forward 5
    down 9
    down 5
    down 1
    down 7
    forward 9
    forward 8
    down 2
    down 4
    down 1
    up 5
    up 5
    forward 5
    down 3
    down 1
    forward 8
    up 9
    up 3
    down 3
    up 3
    up 5
    forward 8
    down 3
    up 3
    down 9
    up 6
    up 8
    forward 5
    up 2
    down 6
    forward 3
    down 2
    down 4
    forward 9
    forward 6
    forward 3
    up 5
    down 9
    down 7
    forward 9
    forward 7
    forward 5
    up 5
    up 1
    down 6
    forward 4
    forward 4
    down 7
    down 1
    up 3
    forward 6
    forward 4
    down 1
    forward 5
    forward 3
    forward 1
    forward 3
    up 3
    up 9
    down 7
    down 4
    forward 8
    down 8
    down 3
    up 2
    down 8
    forward 5
    down 7
    forward 6
    down 9
    up 5
    forward 4
    down 2
    forward 6
    down 8
    down 7
    forward 8
    forward 5
    down 2
    forward 7
    forward 5
    forward 7
    down 8
    forward 5
    down 8
    down 6
    down 7
    down 9
    forward 9
    down 6
    forward 8
    up 6
    up 1
    down 5
    forward 1
    forward 7
    up 2
    up 5
    up 6
    down 5
    down 5
    forward 7
    down 9
    down 2
    forward 9
    forward 3
    down 5
    up 2
    up 8
    forward 5
    forward 8
    up 1
    forward 3
    forward 1
    up 4
    forward 1
    down 9
    down 6
    forward 1
    down 4
    down 4
    forward 9
    down 3
    up 6
    down 3
    forward 6
    forward 6
    down 3
    forward 6
    down 3
    down 1
    forward 3
    down 7
    up 9
    forward 1
    down 7
    down 2
    up 8
    down 1
    down 9
    down 1
    down 4
    down 6
    down 3
    down 7
    down 2
    down 9
    down 2
    forward 4
    up 3
    down 4
    up 4
    down 1
    forward 5
    forward 7
    down 7
    forward 9
    forward 6
    down 8
    forward 6
    forward 7
    up 3
    down 3
    up 6
    forward 7
    up 4
    forward 4
    down 1
    up 8
    forward 7
    down 2
    up 6
    forward 1
    forward 3
    up 9
    up 8
    up 5
    forward 7
    up 5
    down 6
    forward 7
    forward 7
    down 4
    down 3
    forward 2
    down 8
    up 9
    up 6
    forward 7
    forward 5
    down 9
    down 2
    up 5
    down 3
    down 3
    up 5
    down 8
    forward 7
    down 4
    down 2
    up 9
    down 5
    down 8
    down 5
    down 6
    forward 9
    down 3
    down 8
    forward 3
    down 1
    down 9
    forward 1
    down 3
    up 9
    up 3
    forward 8
    up 2
    down 4
    up 5
    up 4
    down 9
    down 5
    up 3
    forward 2
    down 8
    forward 8
    forward 7
    up 4
    down 9
    down 6
    up 1
    forward 9
    up 8
    forward 4
    up 3
    down 4
    up 2
    up 7
    down 2
    forward 3
    down 8
    down 9
    up 7
    up 8
    forward 3
    forward 1
    forward 7
    forward 5
    forward 9
    forward 2
    up 1
    down 1
    up 4
    forward 1
    up 9
    forward 7
    forward 2
    down 6
    down 5
    forward 9
    forward 4
    down 6
    down 6
    up 8
    down 3
    up 8
    down 3
    forward 2
    down 1
    down 1
    forward 5
    down 1
    forward 9
    up 8
    forward 2
    down 5
    up 8
    up 8
    forward 8
    forward 8
    forward 3
    forward 2
    forward 8
    forward 9
    forward 8
    forward 6
    forward 4
    up 7
    forward 9
    forward 8
    up 7
    forward 6
    forward 9
    forward 8
    down 7
    forward 9
    down 4
    down 1
    up 1
    up 9
    forward 2
    down 6
    down 2
    down 8
    down 6
    up 8
    forward 7
    up 9
    forward 5
    forward 4
    forward 8
    up 4
    forward 4
    up 6
    forward 7
    forward 1
    up 8
    down 6
    forward 7
    forward 3
    forward 2
    down 4
    forward 4
    down 7
    down 6
    down 2
    up 3
    up 5
    down 7
    down 9
    up 8
    down 1
    up 1
    down 8
    up 8
    forward 8
    down 6
    down 1
    down 6
    forward 3
    down 9
    down 5
    up 3
    down 1
    down 1
    forward 4
    down 4
    up 3
    forward 8
    up 4
    down 3
    down 5
    down 3
    forward 6
    forward 3
    down 2
    forward 9
    forward 3
    forward 2
    down 2
    forward 6
    down 1
    down 1
    forward 5
    forward 4
    forward 6
    down 7
    forward 7
    forward 3
    forward 1
    up 3
    down 6
    forward 1
    up 9
    forward 9
    forward 5
    forward 3
    forward 3
    down 3
    up 8
    forward 5
    up 6
    forward 2
    down 7
    forward 2
    forward 8
    forward 8
    forward 3
    up 9
    down 5
    down 3
    forward 7
    up 9
    forward 4
    down 1
    down 3
    down 5
    down 2
    forward 9
    up 6
    down 3
    down 7
    down 3
    up 6
    forward 3
    down 4
    forward 2
    down 8
    down 2
    forward 7
    down 2
    down 9
    forward 1
    down 1
    down 9
    down 6
    forward 5
    down 1
    up 1
    forward 5
    forward 4
    forward 9
    down 3
    forward 3
    forward 5
    down 9
    forward 9
    down 8
    down 2
    forward 1
    up 1
    down 5
    forward 2
    up 9
    forward 9
    forward 7
    forward 9
    forward 3
    down 7
    forward 2
    down 4
    up 3
    down 7
    down 6
    forward 2
    down 2
    forward 8
    up 9
    down 1
    forward 7
    down 8
    forward 3
    down 2
    down 5
    down 5
    down 3
    forward 1
    up 9
    up 9
    down 8
    down 6
    up 7
    forward 7
    down 4
    forward 6
    down 9
    up 5
    up 6
    forward 4
    forward 1
    forward 1
    down 7
    down 8
    down 2
    down 4
    down 3
    up 8
    down 3
    forward 3
    forward 8
    up 3
    down 2
    forward 4
    down 3
    forward 5
    up 1
    down 9
    down 1
    down 4
    forward 3
    forward 6
    forward 7
    forward 2
    forward 9
    forward 1
    forward 6
    forward 7
    forward 2
    up 1
    down 6
    down 1
    forward 6
    down 6
    down 5
    forward 1"
    assert 1804520 == input |> prepare |> Part1.run
    assert 1971095320 == input |> prepare |> Part2.run
  end
end