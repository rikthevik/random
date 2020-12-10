

defmodule Util do

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

  def p1_traverse(recipes, {req_amt, "ORE"}) do
    "ORE => #{req_amt}" |> IO.puts
    req_amt
  end
  def p1_traverse(recipes, {req_amt, req_chem}) do
    "p1_traverse #{req_amt} #{req_chem}" |> IO.puts
    matching_recipes = recipes
    |> Enum.filter(fn {ingreds, {a, c}} -> c == req_chem end)
    |> IO.inspect
    "" |> IO.puts

    # # let's start with 1 match for now, maybe we have to pick the minimum recipe
    [{produced, {prod_amt, req_chem}}] = matching_recipes
    for {prod_amt, prod_chem} <- produced do
      # gotta incorporate the required amount here...
      recipe_iterations = Kernel.ceil(req_amt / prod_amt)
      p1_traverse(recipes, {prod_amt * recipe_iterations, prod_chem})
    end
    |> Enum.sum

  end

  def part1(rows) do
    rows 
    |> IO.inspect
    |> p1_traverse({1, "FUEL"})
  end

  def part2(rows) do
    
  end

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
    |> IO.inspect
    assert 31 == rows |> Problem.part1
  end

  test "example 2" do
  
  end

  test "go time" do
  
  end

end
