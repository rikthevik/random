
defmodule Prob do
  defstruct [:t, :x]
  def new() do
    %Prob{t: 1, x: 1}
  end

  def read(p, ["noop"]) do
    [%{p|t: p.t+1}]
  end
  def read(p, ["addx", x]) do
    [%{p|t: p.t+1}, %{p|t: p.t+2, x: p.x+x}]
  end

  def signal_strength(p) do
    p.t * p.x
  end

  def tuple(p) do
    {p.t, p.x}
  end

end

defmodule Part1 do
  def get_steps(rows) do
    {steps, p} = rows
    |> Enum.map_reduce(Prob.new(), fn row, p ->
      ps = Prob.read(p, row)
      {ps, List.last(ps)}
    end)

    steps = steps
    |> List.flatten()
  end

  def run(rows, cycle_list) do
    steps = get_steps(rows)

    cycle_list
    |> Enum.map(fn cycle ->
      p = steps
      |> Enum.find(fn p -> p.t == cycle end)
      |> IO.inspect

      p.x * cycle
    end)
  end
end

defmodule Part2 do
  def pixel(col, x) do
    ret = pix(col, x)
    # {col, x, ret} |> IO.inspect()
    ret
  end
  def pix(col, x) when col <= x+1 and col >= x-1 do "#" end
  def pix(_, _) do "." end

  def run(rows) do
    w = 40
    h = 6

    step_map = Part1.get_steps(rows)
    |> Enum.map(fn p -> {p.t, p.x} end)
    |> Map.new()

    IO.puts("wat")
    for row <- 0..(h-1) do
      for col <- 0..(w-1) do
        t = row * w + col + 1
        p = pixel(col, Map.get(step_map, t, 1))
        IO.write(p)
      end
      IO.puts("")
    end


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
    addx -5
    noop"
    # assert [20, -7] == input |> prepare |> Part1.run([5, 7])
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
    # assert [420, 1140, 1800, 2940, 2880, 3960] == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220])
    # assert 13140 == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220]) |> Enum.sum()
    input |> prepare |> Part2.run()
  end

  test "go time" do
    input = File.read!("./inputs/p10input.txt")
    assert 15220 == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220]) |> Enum.sum()
    input |> prepare |> Part2.run()
  end
end
