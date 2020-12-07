
defmodule Util do

end


defmodule Problem do

  def parse_contains("no other bags") do [] end
  def parse_contains(s) do
    s
    |> String.split(", ")
    |> Enum.map(fn s -> Regex.named_captures(~r/^(?<amt>\d+) (?<color>[\w ]+) bags?$/, s) end)
    |> Enum.map(fn m -> {m["amt"] |> String.to_integer, m["color"]} end)
  end

  def load_row(s) do
    match = Regex.named_captures(~r/^ *(?<color>[\w ]+) bags contain (?<contains>.*)\.$/, s)
    {match["color"], parse_contains(match["contains"])}
  end

  def load_graph(inputstr) do
    inputstr
    |> String.trim
    |> String.split(~r/\n/)
    |> Enum.map(&load_row/1)
    |> Enum.flat_map(&row_to_edges/1)
  end

  def row_to_edges({orig_color, contains_list}) do
    contains_list 
    |> Enum.map(fn {amt, contains_color} -> {contains_color, orig_color} end)
  end

  def p1_traverse(graph, curr) do
    # "p1_traverse #{curr}" |> IO.puts
    matching_edges = graph
    |> Enum.filter(fn {contains, orig} -> curr == contains end)
    # |> IO.inspect
    [curr] ++ Enum.map(matching_edges, fn {contains, orig} -> p1_traverse(graph, orig) end)
  end

  def part1(graph) do
    # graph |> IO.inspect
    
    paths = graph
    |> p1_traverse("shiny gold")
    |> List.flatten
    |> MapSet.new
    |> MapSet.delete("shiny gold")
    # |> IO.inspect
    |> Enum.count
  end

  def part2(rows) do

  end

end

defmodule Tests do 
  use ExUnit.Case
  
  test "examples" do
    inputstr = "light red bags contain 1 bright white bag, 2 muted yellow bags.
    dark orange bags contain 3 bright white bags, 4 muted yellow bags.
    bright white bags contain 1 shiny gold bag.
    muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
    shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
    dark olive bags contain 3 faded blue bags, 4 dotted black bags.
    vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
    faded blue bags contain no other bags.
    dotted black bags contain no other bags."

    assert {"light red", [{1, "bright white"}, {2, "muted yellow"}]} == "light red bags contain 1 bright white bag, 2 muted yellow bags." |> Problem.load_row

    g = inputstr |> Problem.load_graph
    assert 4 == g |> Problem.part1
    
  end

  test "go time " do

  end
end
