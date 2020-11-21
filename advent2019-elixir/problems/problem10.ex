
defmodule Util do
  def slope({ax, ay}, {bx, by}) do
    {by - ay, bx - ax}
  end

  def slope_reduced({rise, run}) do
    divisor = 1 # gcd(rise, run)
    {Integer.floor_div(rise, divisor), Integer.floor_div(run, divisor)}
  end
end

defmodule Problem09 do
  def part1(s) do
  
  end

  def part2(s) do

  end
end

defmodule Tests do 
  use ExUnit.Case

  test "slope functions" do
    assert {1, 1} == Util.slope({0, 0}, {1, 1})
    assert {2, -2} == Util.slope({0, 0}, {-2, 2})
    assert {1, -1} == Util.slope({0, 0}, {-2, 2}) |> Util.slope_reduced
  end

end