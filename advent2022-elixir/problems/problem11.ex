
defmodule Monkey do
  defstruct [:idx, :items, :op, :operand, :divby, :iftrue, :iffalse]
  def new(lines) do
    m = %Monkey{}

    lines
    |> Enum.reduce(%Monkey{}, fn l, m -> parse(m, l) end)
    |> IO.inspect(label: "done")
  end

  def parse_operand("old") do "old" end
  def parse_operand(s) do String.to_integer(s) end

  def parse(m, "Monkey " <> s) do
    %{m| idx: s
      |> String.trim(":")
      |> String.to_integer()
    }
  end
  def parse(m, "Starting items: " <> item_str) do
    %{m| items: item_str
      |> String.split(~r/, +/)
      |> Enum.map(&String.to_integer/1)
    }
  end
  def parse(m, "Operation: new = old " <> s) do
    s |> IO.inspect(label: "wat")
    [op, operand] = String.split(s, ~r/ /)
    %{m|
      op: op,
      operand: parse_operand(operand),
    }
  end
  def parse(m, "Test: divisible by " <> divby) do
    %{m| divby: String.to_integer(divby)}
  end
  def parse(m, "If true: throw to monkey " <> iftrue) do
    %{m| iftrue: String.to_integer(iftrue)}
  end
  def parse(m, "If false: throw to monkey " <> iffalse) do
    %{m| iffalse: String.to_integer(iffalse)}
    |> IO.inspect
  end
end

defmodule Part1 do
  def run(line_groups) do
    monkeys = line_groups
    |> Enum.map(&Monkey.new/1)
  end
end

defmodule Part2 do
  def run(rows) do

  end
end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(row) do
    row
    |> IO.inspect
  end

  def prepare(input) do
    input
    |> String.trim()
    |> String.split(~r/ *\n */)
    |> Enum.chunk_by(fn s -> s == "" end)
    |> Enum.filter(fn s -> s != [""] end)
    |> IO.inspect()
    # |> Enum.map(fn s -> String.split(s, ~r/ /) end)
    # |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "Monkey 0:
    Starting items: 79, 98
    Operation: new = old * 19
    Test: divisible by 23
      If true: throw to monkey 2
      If false: throw to monkey 3

  Monkey 1:
    Starting items: 54, 65, 75, 74
    Operation: new = old + 6
    Test: divisible by 19
      If true: throw to monkey 2
      If false: throw to monkey 0

  Monkey 2:
    Starting items: 79, 60, 97
    Operation: new = old * old
    Test: divisible by 13
      If true: throw to monkey 1
      If false: throw to monkey 3

  Monkey 3:
    Starting items: 74
    Operation: new = old + 3
    Test: divisible by 17
      If true: throw to monkey 0
      If false: throw to monkey 1"
    input |> prepare |> Part1.run()
    # assert [420, 1140, 1800, 2940, 2880, 3960] == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220])
    # assert 13140 == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220]) |> Enum.sum()
    # input |> prepare |> Part2.run()
  end

  test "go time" do
    # input = File.read!("./inputs/p10input.txt")
    # assert 15220 == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220]) |> Enum.sum()
    # input |> prepare |> Part2.run()
  end
end
