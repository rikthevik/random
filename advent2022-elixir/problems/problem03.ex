
defmodule Work do
  def priority(s) do
    s
    |> String.to_charlist()
    |> List.first()
    |> priority_for_char()
  end

  def priority_for_char(c) when c >= 97 and c <= 122 do c - 96 end
  def priority_for_char(c) when c >= 65 and c <= 90 do c - 64 + 26 end
end

defmodule Part1 do
  def run(rows) do
    rows
    |> Enum.map(fn s -> String.split_at(s, div(String.length(s), 2)) end)
    |> Enum.map(fn {l, r} ->
      MapSet.new(String.graphemes(l))
      |> MapSet.intersection(MapSet.new(String.graphemes(r)))
      |> MapSet.to_list()
    end)
    |> List.flatten()
    |> Enum.map(&Work.priority/1)
    |> Enum.sum()
  end
end

defmodule Part2 do
  def common_item(rows) do
    rows
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&MapSet.new/1)
    |> Enum.reduce(&MapSet.intersection/2)
    |> MapSet.to_list()
    |> List.first()
  end

  def run(rows) do
    rows
    |> Enum.chunk_every(3)
    |> Enum.map(&common_item/1)
    |> Enum.map(&Work.priority/1)
    |> Enum.sum()
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

  test "lib" do
    assert 1 == Work.priority("a")
    assert 27 == Work.priority("A")
  end

  test "example" do
    input = "vJrwpWtwJgWrhcsFMMfFFhFp
    jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL
    PmmdzqPrVvPwwTWBwg
    wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn
    ttgJtRGJQctTZtZT
    CrZsJsPPZsGzwwsLwLmpwMDw"
    assert 157 == input |> prepare |> Part1.run
    assert 70 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = ProblemInputs.problem03()
    assert 8298 == input |> prepare |> Part1.run
    assert 2708 == input |> prepare |> Part2.run
  end
end
