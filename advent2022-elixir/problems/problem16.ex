
defmodule Util do

end

defmodule Prob do
  defstruct [:graph, :flows]
  def new(rows) do
    graph = rows
    |> Enum.map(fn {curr, _, nexts} ->
      for next <- nexts do {curr, next} end
    end)
    |> Enum.concat()

    flows = rows
    |> Enum.map(fn {curr, flow, _} -> {curr, flow} end)
    |> Map.new()

    %Prob{
      graph: graph,
      flows: flows,
    }
  end

  def nexts(p, curr) do
    p.graph
    |> Enum.filter(fn {k, _} -> k == curr end)
    |> Enum.map(fn {_, v} -> v end)
  end
end

defmodule Part1 do
  def run(rows) do
    rows
    |> Prob.new()
    |> IO.inspect()
    |> traverse()
  end

  def traverse(p) do
    traverse(p, 30, "AA", Map.new(), [])
  end

  def traverse(p, 0, curr, opened, path) do
    path
    |> IO.inspect(label: "done")
  end
  def traverse(p, remaining, curr, opened, path) do
    # {remaining, curr, opened} |> IO.inspect(label: "traverse")

    if Map.get(p.flows, curr) > 0 and Map.get(opened, curr) == nil do
      traverse(p, remaining - 1, curr, Map.put(opened, curr, remaining), [{:open, curr}|path])
    else
      for next <- Prob.nexts(p, curr) do
        traverse(p, remaining - 1, next, opened, [{:walk, next}|path])
      end
    end
  end
end

defmodule Part2 do
  def run(rows) do
    rows
    |> IO.inspect()
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s |> IO.inspect()

    [_match, curr, flowstr, nextstr] = ~r/Valve ([A-Z]+) has flow rate=(\d+); tunnels? leads? to valves? (.+)$/
    |> Regex.run(s)

    {curr, String.to_integer(flowstr), String.split(nextstr, ~r/, /)}
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "Valve AA has flow rate=0; tunnels lead to valves DD, II, BB
    Valve BB has flow rate=13; tunnels lead to valves CC, AA
    Valve CC has flow rate=2; tunnels lead to valves DD, BB
    Valve DD has flow rate=20; tunnels lead to valves CC, AA, EE
    Valve EE has flow rate=3; tunnels lead to valves FF, DD
    Valve FF has flow rate=0; tunnels lead to valves EE, GG
    Valve GG has flow rate=0; tunnels lead to valves FF, HH
    Valve HH has flow rate=22; tunnel leads to valve GG
    Valve II has flow rate=0; tunnels lead to valves AA, JJ
    Valve JJ has flow rate=21; tunnel leads to valve II"
    assert 1651 == input |> prepare |> Part1.run
    # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    # input = "122"
    # assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end
end
