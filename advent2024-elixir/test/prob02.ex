

defmodule Prob do
  def p1_is_safe(row) do
    p1_is_safe_asc(row) or p1_is_safe_asc(Enum.reverse(row))
  end
  def p1_is_safe_asc([_a]) do true end
  def p1_is_safe_asc([a,b|rest]) do
    diff = b - a
    diff >= 1 and diff <= 3 and p1_is_safe_asc([b|rest])
  end

  def run1(rows) do
    rows
    |> Enum.map(&p1_is_safe/1)
    |> Enum.filter(fn a -> a end)
    |> Enum.count()
  end

  def run2(rows) do
    rows
    |> Enum.map(&p2_is_safe/1)
    |> Enum.filter(fn a -> a end)
    |> Enum.count()
  end

  def p2_is_safe(row) do
    p2_is_safe_asc(row)
      or p2_is_safe_asc(Enum.reverse(row))
  end
  def p2_is_safe_asc(row) do
    p1_is_safe_asc(row)
    or sublists(row)
      |> Enum.map(&p1_is_safe_asc/1)
      |> Enum.any?()
  end

  def sublists(row) do
    # returns a list of lists, each one missing one original list element
    sublists([], row)
  end
  def sublists(prefix, [_a]) do
    [prefix]
  end
  def sublists(prefix, [a|rest]) do
    [prefix ++ rest] ++ sublists(prefix ++ [a], rest)
  end

end

defmodule Parse do
  def rows(s) do
    s
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(&make_row/1)
  end

  def make_row(s) do
    s
    |> String.split(~r/ +/)
    |> Enum.map(&String.to_integer/1)
  end

end




defmodule Tests do
  use ExUnit.Case

  test "functions" do
    assert Prob.sublists([1, 2, 3, 4]) == [
      [2, 3, 4],
      [1, 3, 4],
      [1, 2, 4],
      [1, 2, 3],
    ]

  end

  test "example1" do
    input = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""
    assert 2 == input
    |> Parse.rows()
    |> Prob.run1()

    assert 4 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 606 == File.read!("test/input02.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 644 == File.read!("test/input02.txt")
    |> Parse.rows()
    |> Prob.run2()
  end


end
