

defmodule Prob do
  def run1({rulemap, rows}) do
    # this tells us that k must be before v
    rulemap
    |> IO.inspect

    # so let's reverse all of the rows
    # and find rules that we'r in violation of
    rows
    |> Enum.map(&Enum.reverse/1)
    |> Enum.filter(fn row -> p1_row_is_valid(rulemap, row) end)
    |> Enum.map(&middle_member/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def p1_row_is_valid(rulemap, []) do
    true
  end
  def p1_row_is_valid(rulemap, [a|rest]) do
    must_be_before = Map.get(rulemap, a)
    if must_be_before do
      (not Enum.member?(rest, must_be_before)) and p1_row_is_valid(rulemap, rest)
    else
      p1_row_is_valid(rulemap, rest)
    end
  end

  def middle_member(l) do
    Enum.at(l, middle_index(Enum.count(l)))
  end
  def middle_index(c) when rem(c, 2) == 1 do
    Kernel.floor(c / 2)
  end

  # def run2(rows) do

  # end
end

defmodule Parse do
  def parse(s) do
    [l, r] = s
    |> String.trim()
    |> String.split("\n\n")
    rulemap = l
    |> String.split("\n")
    |> Enum.map(&make_rule/1)
    |> Map.new()
    rows = r
    |> String.split("\n")
    |> Enum.map(&make_row/1)
    # |> Enum.take(1)
    {rulemap, rows}
  end

  def make_row(s) do
    s
    |> String.split(",")
    # |> Enum.map(&String.to_integer/1)
  end

  def make_rule(s) do
    s
    |> String.split("|")
    # |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""
    assert 143 == input
    |> Parse.parse()
    |> Prob.run1()

    # assert 31 == input
    # |> Parse.rows()
    # |> Prob.run2()
  end

  test "part1" do
    assert 1722302 == File.read!("test/input05.txt")
    |> Parse.parse()
    |> Prob.run1()
  end

  # test "part2" do
  #   assert 20373490 == File.read!("test/input05.txt")
  #   |> Parse.parse()
  #   |> Prob.run2()
  # end


end
