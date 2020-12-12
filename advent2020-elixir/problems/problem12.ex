
defmodule Util do
  
end

defmodule Problem do

  def load_line(line) do
    line |> String.trim
  end

  def load(inputstr) do
    lines = inputstr
    |> String.split("\n")
    |> Enum.map(&load_line/1)

    m = for {l, y} <- Enum.with_index(lines), {c, x} <- Enum.with_index(String.graphemes(l)), into: %{} do
      {{x, y}, c}
    end

    
  end

  def part1(rows) do
    
  end
  def part2(rows) do
  
  end

  
end

defmodule Tests do 
  use ExUnit.Case
  
  test "examples" do
    inputstr = "F10
    N3
    F7
    R90
    F11"
    assert 25 == inputstr |> Problem.load |> Problem.part1
    # assert 26 == inputstr |> Problem.load |> Problem.part2
  end

  test "go time" do
    # inputstr = ""
    # assert 2303 == inputstr |> Problem.load |> Problem.part1
    # assert 8 == inputstr |> Problem.load |> Problem.part2
  end


end
