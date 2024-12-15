

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
    |> IO.inspect
    |> Enum.map(&String.to_integer/1)
    |> IO.inspect
    |> List.to_tuple()
  end

end



defmodule Tests do
  use ExUnit.Case
  test "example" do
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
  end

  test "part1" do
    assert 1722302 == File.read!("test/input01.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

end
