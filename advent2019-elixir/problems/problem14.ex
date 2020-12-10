

defmodule Util do
  
  def topological_sort(edges) do
    topological_sort(edges, [])
  end
  def topological_sort([], acc) do acc end
  def topological_sort(edges, acc) do 
    # Find all the nodes with no incoming edges.
    all_dsts = edges |> Enum.map(fn {_src, dst} -> dst end) |> MapSet.new
    nodes_no_incoming = edges
    |> Enum.filter(fn {src, _dst} -> not MapSet.member?(all_dsts, src) end)
    |> Enum.map(fn {src, _dst} -> src end)
    |> MapSet.new
    # These are part of our topological sort
    new_acc = acc ++ Enum.sort(nodes_no_incoming)

    # Remove all the nodes with no incoming edges.
    new_edges = edges
    |> Enum.filter(fn {src, _dst} -> not MapSet.member?(nodes_no_incoming, src) end)

    # Keep going
    topological_sort(new_edges, new_acc)
  end
end

defmodule Problem do

  def load_chunk(s) do
    [amt, chem] = s |> String.split(" ")
    {String.to_integer(amt), chem}
  end
  def load_recipe(l) do
    [ingreds, product] = l |> String.split(" => ")
    {ingreds |> String.split(", ") |> Enum.map(&load_chunk/1), load_chunk(product)}
  end
  def load(inputstr) do
    inputstr
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&load_recipe/1)
  end
  def recipe_to_edges({ingreds, {_req_amt, req_chem}}) do
    ingreds |>
    Enum.map(fn {_prod_amt, prod_chem} -> {req_chem, prod_chem} end)
  end
  def recipes_to_edges(recipes) do
    recipes 
    |> Enum.flat_map(&recipe_to_edges/1)
  end

  def get_requirements(recipes, {req_amt, req_chem}) do
    # "get_requirements {#{req_amt}, #{req_chem}}" |> IO.puts
    matching_recipes = recipes
    |> Enum.filter(fn {_ingreds, {_a, c}} -> c == req_chem end)
    # |> IO.inspect

    # # let's start with 1 match for now, maybe we have to pick the minimum recipe
    [{produced, {recipe_amt, _req_chem}}] = matching_recipes

    recipe_iterations = Kernel.ceil(req_amt / recipe_amt)

    for {prod_amt, prod_chem} <- produced, into: %{} do
      {prod_chem, prod_amt * recipe_iterations}
    end
  end

  def p1_traverse(_recipes, [], reqs) do reqs end
  def p1_traverse(recipes, [node|nodes], reqs) do
    # "NODE #{node} REQS #{inspect reqs}" |> IO.puts
    new_reqs = get_requirements(recipes, {Map.get(reqs, node), node})
    all_reqs = reqs |> Map.merge(new_reqs, fn _key, a, b -> a + b end)  # sum up any that exist in both!
    # |> IO.inspect
    p1_traverse(recipes, nodes, all_reqs)
  end

  def part1(recipes) do
    
    nodes = recipes
    |> recipes_to_edges
    |> Util.topological_sort
  
    p1_traverse(recipes, nodes, %{"FUEL" => 1})
    |> Map.get("ORE")
  
  end

  # def part2(rows) do
    
  # end

end

defmodule Tests do 
  use ExUnit.Case

  test "example 1" do
    rows = "10 ORE => 10 A
    1 ORE => 1 B
    7 A, 1 B => 1 C
    7 A, 1 C => 1 D
    7 A, 1 D => 1 E
    7 A, 1 E => 1 FUEL"
    |> Problem.load
    assert 31 == rows |> Problem.part1
  end

  test "example 2" do
  
  end

  test "go time" do
  
  end

end
