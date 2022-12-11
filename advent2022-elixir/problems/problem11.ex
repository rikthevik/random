
defmodule Global do
  def start_link() do
    {:ok, pid} = Task.start_link(fn -> loop(%{}) end)
    Process.register(pid, :global)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        retval = Map.get(map, key)
        # "GET F(#{inspect key}) => #{inspect retval}" |> IO.puts
        send caller, retval
        loop(map)
      {:all, caller} ->
        send caller, map
        loop(map)
      {:put, key, value} ->
        # "SET F(#{inspect key}) := #{inspect value}" |> IO.puts
        loop(Map.put(map, key, value))
      {:reset} ->
        loop(Map.new())
    end
  end

  def put(k, v) do send :global, {:put, k, v} end
  def get(k) do
    send :global, {:get, k, self()}
    receive do v -> v end
  end
  def all() do
    send :global, {:all, self()}
    receive do v -> v end
  end
  def reset() do
    send :global, {:reset}
  end
end

defmodule Prob do
  defstruct [:monkeys]
  def new(line_groups) do
    monkey_map = line_groups
    |> Enum.map(&Monkey.new/1)
    |> Enum.map(fn m -> {m.idx, m} end)
    |> Map.new()

    %Prob{
      monkeys: monkey_map,
    }
  end

  def set_worry({div, mod}) do
    Global.put({:worry, 1}, {div, mod})
  end
  def get_worry() do
    Global.get({:worry, 1})
  end

  def add_monkey(m) do
    Global.put({:monkey, m.idx}, m.items)
    Global.put({:count, m.idx}, 0)
  end
  def inc_count(idx) do
    key = {:count, idx}
    Global.put(key, Global.get(key)+1)
  end
  def clear_items(idx) do
    key = {:monkey, idx}
    items = Global.get(key)
    Global.put(key, [])
    items
  end

  def append_item(idx, item) do
    key = {:monkey, idx}
    Global.put(key, Global.get(key) ++ [item])
  end
  def start_round(p) do
    for {idx, m} <- p.monkeys do
      Monkey.take_turn(m)
    end
  end

  def monkey_business() do
    Global.all()
    |> IO.inspect
    |> Enum.filter(fn {{type, _}, _} -> type == :count end)
    |> Enum.map(fn {{:count, _idx}, count} -> count end)
    |> Enum.sort(:desc)
    |> Enum.take(2)
    |> Enum.reduce(fn a, b -> a * b end)
  end
end

defmodule Monkey do
  defstruct [:idx, :items, :op, :operand, :divby, :iftrue, :iffalse, :count]
  def new(lines) do
    m = lines
    |> Enum.reduce(%Monkey{count: 0}, fn l, m -> parse(m, l) end)

    Prob.add_monkey(m)
    m
  end

  def take_turn(m) do
    items = Prob.clear_items(m.idx)
    for i <- items do
      monkey_inspect(m, i)
    end
  end

  def monkey_inspect(m, old) do
    new = compute(old, m.op, m.operand)
    # |> IO.inspect(label: "new")

    {worry_div, worry_mod} = Prob.get_worry()

    bored = cond do
      worry_div ->
        div(new, worry_div)
      worry_mod ->
        rem(new, worry_mod)
    end

    # |> IO.inspect(label: "divby")

    target = if rem(bored, m.divby) == 0 do m.iftrue else m.iffalse end
    Prob.inc_count(m.idx)
    Prob.append_item(target, bored)
  end
  def compute(old, op, "old") do compute_val(old, op, old) end
  def compute(old, op, operand) do compute_val(old, op, operand) end
  def compute_val(old, "*", val) do old * val end
  def compute_val(old, "+", val) do old + val end

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
  def run(line_groups, num_rounds) do
    Prob.set_worry({3, nil})
    p = Prob.new(line_groups)
    inner_run(p, num_rounds)
  end

  def inner_run(p, num_rounds) do
    for i <- 1..num_rounds do
      p |> Prob.start_round()

      # Global.all()
      # |> Enum.map(fn {i, items} -> {i, items} end)
      # |> IO.inspect(label: "post-round-" <> Integer.to_string(i))
    end

    Prob.monkey_business()
  end
end

defmodule Part2 do
  def run(line_groups, num_rounds) do
    p = Prob.new(line_groups)

    # Instead of letting the numbers grow infinitely, look at the numbers
    # each monkey divides by.  The product of all of those is a mod space
    # that we can use.
    mod_space = p.monkeys
    |> Enum.map(fn {_, m} -> m.divby end)
    |> IO.inspect
    |> Enum.reduce(fn a, b -> a * b end)
    |> IO.inspect

    Prob.set_worry({nil, mod_space})
    Part1.inner_run(p, num_rounds)
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
    Global.start_link()
    assert 10605 = input |> prepare |> Part1.run(20)
    Global.reset()
    assert 2713310158 = input |> prepare |> Part2.run(10000)
    # assert [420, 1140, 1800, 2940, 2880, 3960] == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220])
    # assert 13140 == input |> prepare |> Part1.run([20, 60, 100, 140, 180, 220]) |> Enum.sum()
    # input |> prepare |> Part2.run()
  end

  test "go time" do
    input = "Monkey 0:
    Starting items: 73, 77
    Operation: new = old * 5
    Test: divisible by 11
      If true: throw to monkey 6
      If false: throw to monkey 5

  Monkey 1:
    Starting items: 57, 88, 80
    Operation: new = old + 5
    Test: divisible by 19
      If true: throw to monkey 6
      If false: throw to monkey 0

  Monkey 2:
    Starting items: 61, 81, 84, 69, 77, 88
    Operation: new = old * 19
    Test: divisible by 5
      If true: throw to monkey 3
      If false: throw to monkey 1

  Monkey 3:
    Starting items: 78, 89, 71, 60, 81, 84, 87, 75
    Operation: new = old + 7
    Test: divisible by 3
      If true: throw to monkey 1
      If false: throw to monkey 0

  Monkey 4:
    Starting items: 60, 76, 90, 63, 86, 87, 89
    Operation: new = old + 2
    Test: divisible by 13
      If true: throw to monkey 2
      If false: throw to monkey 7

  Monkey 5:
    Starting items: 88
    Operation: new = old + 1
    Test: divisible by 17
      If true: throw to monkey 4
      If false: throw to monkey 7

  Monkey 6:
    Starting items: 84, 98, 78, 85
    Operation: new = old * old
    Test: divisible by 7
      If true: throw to monkey 5
      If false: throw to monkey 4

  Monkey 7:
    Starting items: 98, 89, 78, 73, 71
    Operation: new = old + 4
    Test: divisible by 2
      If true: throw to monkey 3
      If false: throw to monkey 2"
    Global.start_link()
    assert 56120 == input |> prepare |> Part1.run(20)
    assert 24389045529 == input |> prepare |> Part2.run(10000)
  end
end
