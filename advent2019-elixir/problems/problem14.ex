

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

  def part1(rows) do
    # yikes, this might be a tough one    
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
