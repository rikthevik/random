
defmodule Util do

end


defmodule Problem do

  def load_row(s) do
    s
    |> String.strip
    |> String.replace("\n", "")
  end

  def load(rows) do
    rows
    |> String.strip
    |> String.split("\n\n")
    |> Enum.map(&load_row/1)
  end

  def part1(rows) do
    
  end

  def part2(rows) do
   
  end

end

defmodule Tests do 
  use ExUnit.Case
  
  test "examples" do
    inputstr = "abc

    a
    b
    c
    
    ab
    ac
    
    a
    a
    a
    a
    
    b"
    assert ["abc", "abc", "abac", "aaaa", "b"] == inputstr |> Problem.load
  end

end
