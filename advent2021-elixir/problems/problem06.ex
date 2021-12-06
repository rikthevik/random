
defmodule Util do

end

defmodule Part1 do
  def run(rows, steps) do

    d = rows
    |> Enum.frequencies

    defaults = for i <- 0..8, into: %{} do {i, 0} end

    defaults
    |> Map.merge(d)
    |> IO.inspect
    |> step(steps)
    |> calc
  end

  def step(d, 0) do d end
  def step(d, steps_remaining) do
    %{
      0 => d[1],
      1 => d[2],
      2 => d[3],
      3 => d[4],
      4 => d[5],
      5 => d[6],
      6 => d[0] + d[7],
      7 => d[8],
      8 => d[0],
    }
    |> step(steps_remaining-1)
  end

  def calc(d) do
    for {_, count} <- d do count end
    |> Enum.sum
  end
end

defmodule Part2 do
  def run(rows) do
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
    |> String.split(~r/,/)
    |> Enum.map(&String.to_integer/1)
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split
    |> Enum.map(&Tests.prepare_row/1)
    |> Enum.at(0)
  end

  test "example" do
      input = "3,4,3,1,2"
      assert 5934 == input |> prepare |> Part1.run(80)
      assert 26984457539 == input |> prepare |> Part1.run(256)
      # assert 5 == input |> prepare |> Part2.run(80)
  end

  test "go time" do
    input = "5,1,2,1,5,3,1,1,1,1,1,2,5,4,1,1,1,1,2,1,2,1,1,1,1,1,2,1,5,1,1,1,3,1,1,1,3,1,1,3,1,1,4,3,1,1,4,1,1,1,1,2,1,1,1,5,1,1,5,1,1,1,4,4,2,5,1,1,5,1,1,2,2,1,2,1,1,5,3,1,2,1,1,3,1,4,3,3,1,1,3,1,5,1,1,3,1,1,4,4,1,1,1,5,1,1,1,4,4,1,3,1,4,1,1,4,5,1,1,1,4,3,1,4,1,1,4,4,3,5,1,2,2,1,2,2,1,1,1,2,1,1,1,4,1,1,3,1,1,2,1,4,1,1,1,1,1,1,1,1,2,2,1,1,5,5,1,1,1,5,1,1,1,1,5,1,3,2,1,1,5,2,3,1,2,2,2,5,1,1,3,1,1,1,5,1,4,1,1,1,3,2,1,3,3,1,3,1,1,1,1,1,1,1,2,3,1,5,1,4,1,3,5,1,1,1,2,2,1,1,1,1,5,4,1,1,3,1,2,4,2,1,1,3,5,1,1,1,3,1,1,1,5,1,1,1,1,1,3,1,1,1,4,1,1,1,1,2,2,1,1,1,1,5,3,1,2,3,4,1,1,5,1,2,4,2,1,1,1,2,1,1,1,1,1,1,1,4,1,5"
    assert 383160 == input |> prepare |> Part1.run(80)
    assert 1721148811504 == input |> prepare |> Part1.run(256)
  end
end
