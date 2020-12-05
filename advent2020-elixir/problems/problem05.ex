
defmodule Util do

end


defmodule Problem do

  # Well that sure looks like a binary string encoding.
  # FBFBBFF => 0101100 == 0x2c, 44
  def bsp_to_int(s) do
    s 
    |> String.replace("F", "0") 
    |> String.replace("B", "1")
    |> String.replace("L", "0")
    |> String.replace("R", "1")
    |> String.to_integer(2)
  end

  
  def find_seat(s) do
    row = s |> String.slice(0..6) |> bsp_to_int
    col = s |> String.slice(7..9) |> bsp_to_int
    {row, col}
  end

  def part1(rows) do
    
  end

  def part2(rows) do
    
  end

end

defmodule Tests do 
  use ExUnit.Case
  
  test "examples" do
    assert Problem.find_seat("BFFFBBFRRR") == {70, 7}
    assert Problem.find_seat("FFFBBBFRRR") == {14, 7}
    assert Problem.find_seat("BBFFBBFRLL") == {102, 4}

  end


end
