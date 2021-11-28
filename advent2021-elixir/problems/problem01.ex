
defmodule Util do

end


defmodule Problem do
  def part1(rows) do

  end

  def part2(rows) do

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

  test "example" do
      assert 1 == 1

  end

  test "go time" do
  end

end
