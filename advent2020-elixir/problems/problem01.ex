
defmodule Util do

end


defmodule Problem01 do
  def part1(ints) do
    for a <- ints, b <- ints, a != b, a+b == 2020 do
      a * b
    end
    |> Enum.at(0)
  end
end

defmodule Tests do 
  use ExUnit.Case

  def prepare(input) do
    input
    |> String.trim
    |> String.split
    |> Enum.map(&String.to_integer/1)
  end

  test "part1 example" do
    result = "1721
979
366
299
675
1456"
    |> prepare
    |> Problem01.part1
    |> IO.inspect
    assert result == 514579
  end

  

end
