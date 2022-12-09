
defmodule Util do
  def transpose(rows) do
    rows
    # |> Enum.map(&String.graphemes/1)
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end
end

defmodule Part1 do
  def zip_row(row) do
    row
    |> Enum.zip(0..Kernel.length(row))
  end
  def build_tree_rows(rows) do
    for {row, row_idx} <- Enum.with_index(rows) do
      for {r, col_idx} <- Enum.with_index(row) do
        {r, {row_idx, col_idx}}
      end
    end
  end
  def run(rows) do
    trees = build_tree_rows(rows)

    transposed_trees = trees |> Util.transpose()

    left_trees = trees
    |> Enum.map(&find_visible/1)
    # |> IO.inspect(label: "left:")

    right_trees = trees
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&find_visible/1)
    # |> IO.inspect(label: "right:")

    top_trees = trees
    |> Util.transpose()
    |> Enum.map(&find_visible/1)
    # |> IO.inspect(label: "top:")

    bottom_trees = trees
    |> Util.transpose()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(&find_visible/1)
    # |> IO.inspect(label: "bottom:")

    all_trees = Enum.concat([
      left_trees,
      right_trees,
      top_trees,
      bottom_trees])

    visible_trees = all_trees
    |> List.flatten()
    |> MapSet.new()
    |> Enum.sort()
    # |> IO.inspect(label: "final:")
    |> length()
  end

  def find_visible([{h, coord}|rest]) do
    [coord|find_visible_inner(h, rest)]
  end
  def find_visible_inner(_, []) do [] end
  def find_visible_inner(h1, [{h2, coord}|rest]) when h2 > h1 do
    [coord|find_visible_inner(h2, rest)]
  end
  def find_visible_inner(h1, [{h2, coord}|rest]) when h2 <= h1 do
    find_visible_inner(h1, rest)
  end
  def find_visible_inner(_, _) do [] end
end

defmodule Part2 do
  def run(rows) do
    db = Part1.build_tree_rows(rows)
    # |> IO.inspect()
    |> List.flatten()
    |> Enum.map(fn {t, coord} -> {coord, t} end)
    |> Map.new()

    h = rows |> length()
    w = rows |> List.first() |> length()
    # {w, h} |> IO.inspect(label: "w-h:")

    # look_trees = tree_map
    # |> IO.inspect()
    # |> Enum.filter(fn {{row, col}, _} -> row > 0 and col > 0 and row < h-1 and col < w-1 end)


    search = db
    # search = [
    #   {{1, 2}, 5},
    #   {{3, 2}, 5},
    # ]

    for {{row, col}, t} <- search do
      score = [
        for r <- row..0 do Map.get(db, {r, col}) end,
        for c <- col..(w-1) do Map.get(db, {row, c}) end,
        for c <- col..0 do Map.get(db, {row, c}) end,
        for r <- row..(h-1) do Map.get(db, {r, col}) end,
      ]
      |> Enum.map(&scenic_enter/1)
      # |> IO.inspect(label: "scores")
      |> Enum.reduce(fn a, b -> a * b end)
      {{row, col}, score}
    end
    # |> IO.inspect()
    |> Enum.map(fn {_, score} -> score end)
    |> Enum.max()

  end

  def scenic_enter(trees) do
    # trees |> IO.inspect()
    ret = scenic(trees)
    # {trees, ret} |> IO.inspect(label: "=>")
    ret
  end

  def scenic([h]) do 0 end
  def scenic([h,t|trees]) when t < h do 1 + scenic([h|trees]) end
  def scenic([h,t|trees]) when t == h do 1 end
  def scenic([h,t|trees]) when t > h do 0 end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "30373
    25512
    65332
    33549
    35390"
    assert 21 == input |> prepare |> Part1.run
    assert 8 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p8input.txt")
    # assert 1805 == input |> prepare |> Part1.run
    assert 1805 == input |> prepare |> Part2.run
  end
end
