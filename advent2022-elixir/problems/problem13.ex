
defmodule Util do

end

defmodule Part1 do
  def start_lr({l, r}) do
    {l, r} |> IO.inspect(label: "start")
    go(l, r)
  end

  def go(l, r) do
    {l, r} |> IO.inspect(label: "go")
    go_inner(l, r)
  end

  def go_inner(l, r) when is_integer(l) and is_integer(r) do
    cond do
      l == r ->
        :continue
      l < r ->
        :correct
      l > r ->
        :incorrect
    end
  end
  def go_inner([], []) do :continue end
  def go_inner([], [_|_]) do :correct end
  def go_inner([_|_], []) do :incorrect end
  def go_inner(l, r) when is_list(l) and is_integer(r) do go(l, [r]) end
  def go_inner(l, r) when is_integer(l) and is_list(r) do go([l], r) end
  def go_inner([l|lrest], [r|rrest]) do
    case go(l, r) do
      :continue ->
        go(lrest, rrest)
      result ->
        result
    end
  end




  def run(rows) do
    rows
    |> IO.inspect()
    |> Enum.map(&start_lr/1)
    |> Enum.with_index()
    |> Enum.filter(fn {result, idx} -> result == :correct end)
    |> Enum.map(fn {_, idx} -> idx + 1 end)
    |> Enum.sum()
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

  def prepare_row(pair) do
    pair
    |> Enum.map(fn lr ->
      {ret, _binding} = Code.eval_string(lr)
      ret
    end)
    |> List.to_tuple()
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.chunk_by(fn r -> r == "" end)
    |> Enum.filter(fn r -> r != [""] end)
    |> Enum.map(&Tests.prepare_row/1)
    # |> Enum.drop(1)
    # |> Enum.take(5)
  end

  test "example" do
    input = "[1,1,3,1,1]
    [1,1,5,1,1]

    [[1],[2,3,4]]
    [[1],4]

    [9]
    [[8,7,6]]

    [[4,4],4,4]
    [[4,4],4,4,4]

    [7,7,7,7]
    [7,7,7]

    []
    [3]

    [[[]]]
    [[]]

    [1,[2,[3,[4,[5,6,7]]]],8,9]
    [1,[2,[3,[4,[5,6,0]]]],8,9]"
    assert 13 == input |> prepare |> Part1.run
    # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = "122"
    # assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end
end
