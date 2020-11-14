

defmodule Tree do
  defstruct [:g, :nodes]


  def new(trunk_to_branch_edges) do
    # Each branch can only point to one trunk.  
    # But each trunk can point to multiple branches.
    # So if we want to store the edges in a Map rather than a 
    # list of edges, we need to key using the branch.
    g = Map.new(for [trunk, branch] <- trunk_to_branch_edges do
      {branch, trunk}
      |> IO.inspect
    end)
    nodes = MapSet.new(Map.keys(g) ++ Map.values(g))
    %Tree{
      g: g,
      nodes: nodes,
    }
    |> IO.inspect
  end

  def steps_to_root(t, node) do
    if Map.has_key?(t.g, node) do
      1 + steps_to_root(t, t.g[node])
    else
      0
    end
  end

  def everyones_steps_to_root(t) do
    t.nodes
    |> Enum.map(&(t |> Tree.steps_to_root(&1)))
    |> Enum.sum()
  end

end



defmodule Problem do

  def parse(line) do
    String.split(line, ")")
  end

  def part1(input_lines) do
    "PART 1" |> IO.puts
    tree = input_lines
    |> String.trim
    |> String.split
    |> Enum.map(fn l -> String.split(l, ")") end)
    |> Tree.new
    |> IO.inspect
    |> Tree.everyones_steps_to_root
    |> IO.inspect
  end
end

defmodule Tests do 
  use ExUnit.Case

  def prepare_prog_string(prog_string) do
    prog_string
    |> String.trim 
    |> String.split 
    |> Enum.map(fn i -> i |> String.trim |> Problem.parse end)
    |> Enum.at(0)
  end

  test "graph functions" do
    t = [ ["ROOT", "a"], ["a", "a1"], ["a", "b"], ["b", "b1"] ]
    |> IO.inspect
    |> Tree.new
    |> IO.inspect

    assert 0 == t |> Tree.steps_to_root("ROOT")
    assert 1 == t |> Tree.steps_to_root("a")
    assert 2 == t |> Tree.steps_to_root("a1")
    assert 2 == t |> Tree.steps_to_root("b")
    assert 3 == t |> Tree.steps_to_root("b1")
    assert 8 == t |> Tree.everyones_steps_to_root()
  end

  test "part 1 example" do
    output = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """
    |> Problem.part1
    assert output == 42
  end

  test "part 1 for real" do
    output = """
    COM)B
    B)C
    C)D
    D)E
    E)F
    B)G
    G)H
    D)I
    E)J
    J)K
    K)L
    """
    |> Problem.part1
    assert output == 42
  end

end

