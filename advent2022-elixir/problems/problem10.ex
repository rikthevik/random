
defmodule Prob do
  defstruct [:t, :x]
  def new() do
    %Prob{t: 1, x: 1}
  end

  def read(p, ["noop"]) do
    %{p|t: p.t+1}
  end
  def read(p, ["addx", x]) do
    %{p|t: p.t+2, x: p.x+x}
  end

  def signal_strength(p) do
    p.t * p.x
  end

  def tuple(p) do
    {p.t, p.x}
  end

end

defmodule Part1 do

  def run(rows, cycle_list) do
    {steps, p} = rows
    |> IO.inspect()
    |> Enum.map_reduce(Prob.new(), fn row, p ->
      p2 = Prob.read(p, row)
      {p2, p2}
    end)

    cycle_list
    |> Enum.map(fn cycle ->
      p = steps
      |> Enum.take_while(fn p -> p.t <= cycle end)
      |> Enum.reverse()
      |> List.first()
      |> IO.inspect

      p.x * cycle
    end)
  end
end

defmodule Part2 do
  def run(rows) do
    rows
  end
end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(i=["noop"]) do i end
  def prepare_row(["addx", s]) do ["addx", String.to_integer(s)] end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(fn s -> String.split(s, ~r/ /) end)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "noop
    addx 3
    addx -5"
    assert [20, -7] == input |> prepare |> Part1.run([5, 7])
    # assert 8 == input |> prepare |> Part2.run
  end

  test "example2" do
    input = "addx 15
    addx -11
    addx 6
    addx -3
    addx 5
    addx -1
    addx -8
    addx 13
    addx 4
    noop
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx 5
    addx -1
    addx -35
    addx 1
    addx 24
    addx -19
    addx 1
    addx 16
    addx -11
    noop
    noop
    addx 21
    addx -15
    noop
    noop
    addx -3
    addx 9
    addx 1
    addx -3
    addx 8
    addx 1
    addx 5
    noop
    noop
    noop
    noop
    noop
    addx -36
    noop
    addx 1
    addx 7
    noop
    noop
    noop
    addx 2
    addx 6
    noop
    noop
    noop
    noop
    noop
    addx 1
    noop
    noop
    addx 7
    addx 1
    noop
    addx -13
    addx 13
    addx 7
    noop
    addx 1
    addx -33
    noop
    noop
    noop
    addx 2
    noop
    noop
    noop
    addx 8
    noop
    addx -1
    addx 2
    addx 1
    noop
    addx 17
    addx -9
    addx 1
    addx 1
    addx -3
    addx 11
    noop
    noop
    addx 1
    noop
    addx 1
    noop
    noop
    addx -13
    addx -19
    addx 1
    addx 3
    addx 26
    addx -30
    addx 12
    addx -1
    addx 3
    addx 1
    noop
    noop
    noop
    addx -9
    addx 18
    addx 1
    addx 2
    noop
    noop
    addx 9
    noop
    noop
    noop
    addx -1
    addx 2
    addx -37
    addx 1
    addx 3
    noop
    addx 15
    addx -21
    addx 22
    addx -6
    addx 1
    noop
    addx 2
    addx 1
    noop
    addx -10
    noop
    noop
    addx 20
    addx 1
    addx 2
    addx 2
    addx -6
    addx -11
    noop
    noop
    noop"
    assert [420, 1140, 1800, 2940, 2880, 3960] == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220])
    assert 13140 == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220]) |> Enum.sum()
  end

  test "go time" do
    input = File.read!("./inputs/p10input.txt")
    assert 13140 == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220]) |> Enum.sum()
    # assert 1805 == input |> prepare |> Part2.run
  end
end
