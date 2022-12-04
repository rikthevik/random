
defmodule Util do

end

defmodule Part1 do
  def for_row([{l1, r1}, {l2, r2}]) when l1 >= l2 and r1 <= r2 do true end
  def for_row([{l1, r1}, {l2, r2}]) when l1 <= l2 and r1 >= r2 do true end
  def for_row(_) do false end

  def run(rows) do
    rows
    |> Enum.map(&for_row/1)
    |> Enum.filter(fn a -> a end)
    |> Enum.count()
  end
end

defmodule Part2 do
  def for_row([{l1, r1}, {l2, _}]) when l2 >= l1 and l2 <= r1 do true end
  def for_row([{l1, r1}, {_, r2}]) when r2 >= l1 and r2 <= r1 do true end
  def for_row(_) do false end

  def run(rows) do
    rows
    |> Enum.map(&Enum.sort/1)
    |> IO.inspect
    |> Enum.map(&for_row/1)
    |> Enum.filter(fn a -> a end)
    |> Enum.count()
  end
end

defmodule Tests do
  use ExUnit.Case

  def prepare_chunk(s) do
    s
    |> String.split(~r/-/)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def prepare_row(s) do
    s
    |> String.split(~r/,/)
    |> Enum.map(&prepare_chunk/1)
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "2-4,6-8
    2-3,4-5
    5-7,7-9
    2-8,3-7
    6-6,4-6
    2-6,4-8
    "
    assert 2 == input |> prepare |> Part1.run
    assert 4 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = ProblemInputs.problem04()
    assert 644 == input |> prepare |> Part1.run
    assert 7 == input |> prepare |> Part2.run
  end
end
