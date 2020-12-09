
defmodule Util do

end

defmodule Problem do

  def load_line(line) do
    line |> String.trim |> String.to_integer
  end

  def load(inputstr) do
    inputstr
    |> String.split("\n")
    |> Enum.map(&load_line/1)
  end

  def part1(ints, preamble_len) do
  end 

  def part2() do

  end

end

defmodule Tests do 
  use ExUnit.Case
  
  test "examples" do
    inputstr = "35
    20
    15
    25
    47
    40
    62
    55
    65
    95
    102
    117
    150
    182
    127
    219
    299
    277
    309
    576"
    assert 127 == inputstr |> Problem.load |> Problem.part1(5)
  end

  test "go time" do
    inputstr = ""

    # assert 127 == lines |> Problem.load |> Problem.part1(25)
  end

end
