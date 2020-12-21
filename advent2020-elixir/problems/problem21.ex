

defmodule Util do
  
end

defmodule Problem do

  def load(inputstr) do
    inputstr 
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&load_recipe/1)
    |> IO.inspect
  end

  def load_recipe(rowstr) do
    [ingreds, rest] = rowstr |> String.split(~r/ .contains /)
    ingreds = ingreds
    |> String.trim
    |> String.split(" ")

    allergens = rest
    |> String.trim
    |> String.slice(0..-2)
    |> String.split(", ")
    |> IO.inspect

    {ingreds, allergens}
  end
    


  def part1(recipes) do
    result = go(recipes)
    |> Enum.map(fn {ingreds, []} -> Enum.count(ingreds) end)
    |> Enum.sum
    "RESULT #{inspect result}" |> IO.puts
    result
  end

  def go(recipes) do
    
    "go(#{inspect recipes})" |> IO.puts

    least_recipe = recipes
    |> Enum.min_by(fn {_, allergens} -> 
      count = Enum.count(allergens) 
      if count == 0, do: 9999, else: count
    end)

    case least_recipe do
      {_, []} -> 
        "we are done" |> IO.puts
        recipes
      {_, [least_allergen|_]} ->
        "least_allergen is #{least_allergen}" |> IO.puts
        remove_allergen(recipes, least_allergen)
        |> go
    end
    


  end

  def remove_allergen(recipes, least_allergen) do
    [culprit] = recipes
    |> Enum.filter(fn {_, allergens} -> Enum.member?(allergens, least_allergen) end)
    |> Enum.map(fn {ingreds, _} -> MapSet.new(ingreds) end) 
    |> Enum.reduce(fn (s1, s2) -> MapSet.intersection(s1, s2) end)
    |> MapSet.to_list

    "ALLERGEN #{least_allergen} => #{culprit}" |> IO.puts

    recipes
    |> Enum.map(fn {ingreds, reqs} -> {
      ingreds |> Enum.filter(fn i -> i != culprit end),
      reqs |> Enum.filter(fn r -> r != least_allergen end)
    }end)

  end

end



defmodule Tests do 
  use ExUnit.Case

  test "example1" do
    inputstr = "mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
    trh fvjkl sbzzf mxmxvkd (contains dairy)
    sqjhc fvjkl (contains soy)
    sqjhc mxmxvkd sbzzf (contains fish)"
    assert 5 == inputstr |> Problem.load |> Problem.part1
  end

  
end
