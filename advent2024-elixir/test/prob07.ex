

defmodule Prob do
  def p1_is_valid({result, [acc|rest]}) do

    p1(result, acc, rest)
  end
  # kind of a neat algorithm. keep doing trying each operation
  # and if you're out of items, see if it matches the result
  # super straightforward
  def p1(result, val, []) do
    result == val
  end
  def p1(result, acc, [val|rest]) do

    p1(result, acc * val, rest) or p1(result, acc + val, rest)
  end

  def run1(rows) do
    rows
    |> Enum.filter(&p1_is_valid/1)
    |> Enum.map(fn {result, _vals} -> result end)
    |> IO.inspect()
    |> Enum.sum()
  end

  def concat(a, b) do
    # ugly but it works int("%d%d" % (a,b))
    String.to_integer(Integer.to_string(a) <> Integer.to_string(b))
  end
  def p2_is_valid({result, [acc|rest]}) do
    p2(result, acc, rest)
  end
  def p2(result, val, []) do
    result == val
  end
  def p2(result, acc, [val|rest]) do
    p2(result, acc * val, rest)
    or p2(result, acc + val, rest)
    or p2(result, concat(acc, val), rest)
  end

  def run2(rows) do
    rows
    |> Enum.filter(&p2_is_valid/1)
    |> Enum.map(fn {result, _vals} -> result end)
    |> IO.inspect()
    |> Enum.sum()
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
    [result|vals] = s
    |> String.split(~r/:? /)
    |> Enum.map(&String.to_integer/1)
    {result, vals}
  end

end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
190: 10 19
3267: 81 40 27
83: 17 5
156: 15 6
7290: 6 8 6 15
161011: 16 10 13
192: 17 8 14
21037: 9 7 18 13
292: 11 6 16 20
"""
    # assert 3749 == input
    # |> Parse.rows()
    # |> Prob.run1()

    assert 11387 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 2941973819040 == File.read!("test/input07.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 249943041417600 == File.read!("test/input07.txt")
    |> Parse.rows()
    |> Prob.run2()
  end


end
