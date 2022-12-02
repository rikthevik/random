
defmodule Util do

end

defmodule Part1 do
  def run(rows) do
    rows
    |> IO.inspect()
  end
end

defmodule Part2 do
  def run(rows) do
    rows
    |> IO.inspect()
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "199"
    assert 7 == input |> prepare |> Part1.run
    assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = "122"
    assert 7 == input |> prepare |> Part1.run
    assert 7 == input |> prepare |> Part2.run
  end
end
