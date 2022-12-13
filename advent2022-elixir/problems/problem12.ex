
defmodule Util do
  def transpose(rows) do
    rows
    # |> Enum.map(&String.graphemes/1)
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end
end

defmodule Prob do
  defstruct [:start, :goal, :graph]

  def height_for_char("S") do height_for_char("a") end
  def height_for_char("E") do height_for_char("z") end
  def height_for_char(c) do
    c
    |> String.to_charlist()
    |> List.first()
  end

  def new(lines) do
    grid_rows = for {line, row} <- Enum.with_index(lines) do
      for {c, col} <- Enum.with_index(String.graphemes(line)) do
        {{row, col}, c}
      end
    end
    |> IO.inspect(label: "grid_rows")

    w = lines |> List.first() |> String.graphemes() |> length()
    h = lines |> length()

    {start, "S"} = grid_rows |> List.flatten() |> Enum.find(fn {_, c} -> c == "S" end)
    {goal, "E"} = grid_rows |> List.flatten() |> Enum.find(fn {_, c} -> c == "E" end)

    %Prob{
      start: start,
      goal: goal,
      graph: make_graph(grid_rows, w-1, h-1),
    }
  end

  def valid_edge?(fromh, toh) when toh - fromh <= 1 do true end
  def valid_edge?(_, _) do false end

  def make_graph(grid_rows, w_idx, h_idx) do
    # Take the rows and turn it into one-directional edges.
    height_map = grid_rows
    |> List.flatten()
    |> Enum.map(fn {p, char} -> {p, height_for_char(char)} end)
    |> Enum.sort()
    |> IO.inspect()
    |> Map.new()
    |> IO.inspect(label: "height_map")

    right_pairs = for row <- 0..h_idx, col <- 0..(w_idx-1) do {{row, col}, {row, col+1}} end
    left_pairs = for {from, to} <- right_pairs do {to, from} end
    down_pairs = for row <- 0..(h_idx-1), col <- 0..w_idx do {{row, col}, {row+1, col}} end
    up_pairs = for {from, to} <- down_pairs do {to, from} end

    g = Enum.concat([right_pairs, down_pairs, left_pairs, up_pairs])
    |> List.flatten()
    |> IO.inspect(label: "pairs")
    |> Enum.filter(fn {from, to} ->
      fromh = Map.get(height_map, from)
      toh = Map.get(height_map, to)
      val = valid_edge?(fromh, toh)
      {from, fromh, to, toh, "diff=", toh - fromh, ":", val} |> IO.inspect()
      val
    end)
    |> Enum.sort()
    |> Enum.group_by(fn {from, _} -> from end, fn {_, to} -> to end)

    g |> Enum.sort()
    |> IO.inspect(label: "foo")

    g
  end

  def begin(prob) do
    min_path_length = find_paths(prob, prob.start, [])
    |> Enum.filter(fn a -> a != nil end)
    |> Enum.map(fn path -> path |> Tuple.to_list() |> length() end)
    |> Enum.min()

    min_path_length - 1  # path length to steps
  end

  def find_paths(prob, point, path) do
    # [point, "path=", path, "next=", Map.get(prob.graph, point, [])] |> IO.inspect(label: "find_paths")
    cond do
      point == prob.goal ->
        List.to_tuple([point|path])
        # |> IO.inspect(label: "WIN")
      Enum.member?(path, point) ->
        # {point, path} |> IO.inspect(label: "revisit")
        nil
      true ->
        for next_point <- Map.get(prob.graph, point, []) do
          find_paths(prob, next_point, [point|path])
        end
        |> List.flatten()
    end
  end
end

defmodule Part1 do
  def run(rows) do
    rows
    |> Prob.new()
    |> IO.inspect()
    |> Prob.begin()
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

  def prepare_row(s) do
    s
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "Sabqponm
    abcryxxl
    accszExk
    acctuvwj
    abdefghi"
    assert 31 == input |> prepare |> Part1.run
    # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p12input.txt")
    assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end
end
