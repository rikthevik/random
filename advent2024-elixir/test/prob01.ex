

defmodule Prob do
  def to_parallel_lists(rows) do
    # A little lame, but works just fine
    first = rows
    |> Enum.map(fn {a, _} -> a end)
    second = rows
    |> Enum.map(fn {_, b} -> b end)
    [first, second]
  end

  def distance({a, b}) do
    Kernel.abs(a - b)
  end

  def run1(rows) do
    [left, right] = rows
    |> to_parallel_lists()

    List.zip([Enum.sort(left), Enum.sort(right)])
    |> Enum.map(&distance/1)
    |> Enum.sum()
  end

  def run2(rows) do
    [left, right] = rows
    |> to_parallel_lists()

    occurrances = right
    |> Enum.frequencies()

    left
    |> Enum.map(fn a -> a * Map.get(occurrances, a, 0) end)
    |> Enum.sum()
  end
end

defmodule Parse do
  def rows(s) do
    s
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&Parse.make_row/1)
  end

  def make_row(s) do
    s
    |> String.split(~r/ +/)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
3   4
4   3
2   5
1   3
3   9
3   3
"""
    assert 11 == input
    |> Parse.rows()
    |> Prob.run1()

    assert 31 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 1722302 == File.read!("test/input01.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 20373490 == File.read!("test/input01.txt")
    |> Parse.rows()
    |> Prob.run2()
  end


end
