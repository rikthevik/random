

defmodule Prob do
  def run1({rules, rows}) do
    # this tells us that k must be before v

    # so let's reverse all of the rows
    # and find rules that we'r in violation of
    rows
    |> Enum.map(&Enum.reverse/1)
    |> Enum.filter(fn row -> p1_row_is_valid(rules, row) end)
    |> Enum.map(&middle_member/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def p1_row_is_valid(_rules, []) do
    true
  end
  def p1_row_is_valid(rules, [c|rest]) do
    active_rules = rules
    |> Enum.filter(fn {a, _b} -> c == a end)

    (not Enum.any?(active_rules, fn {_a, b} -> Enum.member?(rest, b) end)) and p1_row_is_valid(rules, rest)

  end

  def middle_member(l) do
    Enum.at(l, middle_index(Enum.count(l)))
  end
  def middle_index(c) when rem(c, 2) == 1 do
    Kernel.floor(c / 2)
  end

  def run2({rules, rows}) do
    rows
    |> Enum.map(&Enum.reverse/1)
    |> Enum.filter(fn row -> not p1_row_is_valid(rules, row) end)
    # |> Enum.take(1)  # temp
    |> Enum.map(fn row -> p2_sort_row(rules, row) end)
    |> Enum.map(&middle_member/1)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  def p2_sort_row(rules, row) do
    # row |> IO.inspect(label: "row")
    relevant_rules = for c <- row do
      rules
      |> Enum.filter(fn {a, _b} -> a == c end)
    end
    |> List.flatten()
    |> Enum.filter(fn {_a, b} -> Enum.member?(row, b) end)
    # |> IO.inspect(label: "relevant rules")

    p2_next_item(relevant_rules, row)
    # |> IO.inspect(label: "sorted")
  end

  # Basically a topological sort. Look for the item with the least number
  # of incoming rules, and then remove that item and the corresponding rules
  def p2_next_item([], []) do
    []
  end
  def p2_next_item(rules, items) do

    freq = rules
    |> Enum.map(fn {_a, b} -> b end)
    |> Enum.frequencies()

    least_incoming = items
    |> Enum.map(fn item -> {item, Map.get(freq, item, 0)} end)
    |> Enum.min_by(fn {_a, b} -> b end)
    |> elem(0)
    # |> IO.inspect(label: "least_incoming")

    remaining_rules = rules
    |> Enum.filter(fn {_a, b} -> b != least_incoming end)
    # |> IO.inspect(label: "remaining_rules")

    remaining_items = items
    |> Enum.filter(fn a -> a != least_incoming end)

    [least_incoming|p2_next_item(remaining_rules, remaining_items)]

  end
end

defmodule Parse do
  def parse(s) do
    [l, r] = s
    |> String.trim()
    |> String.split("\n\n")
    rules = l
    |> String.split("\n")
    |> Enum.map(&make_rule/1)
    rows = r
    |> String.split("\n")
    |> Enum.map(&make_row/1)
    # |> Enum.take(1)
    {rules, rows}
  end

  def make_row(s) do
    # I was going to convert these to integers, but Elixir(Erlang) charlists
    # like to display lists of ascii-valid ints in a goofy way, so let's stick
    # with strings until we need the ints for something.
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

    assert 123 == input
    |> Parse.parse()
    |> Prob.run2()
  end

  test "part1" do
    assert 5948 == File.read!("test/input05.txt")
    |> Parse.parse()
    |> Prob.run1()
  end

  test "part2" do
    assert 3062 == File.read!("test/input05.txt")
    |> Parse.parse()
    |> Prob.run2()
  end


end
