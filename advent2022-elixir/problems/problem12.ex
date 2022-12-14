
defmodule Global do
  def start_link() do
    {:ok, pid} = Task.start_link(fn -> loop(%{}) end)
    Process.register(pid, :global)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        retval = Map.get(map, key)
        # "GET F(#{inspect key}) => #{inspect retval}" |> IO.puts
        send caller, retval
        loop(map)
      {:all, caller} ->
        send caller, map
        loop(map)
      {:put, key, value} ->
        # "SET F(#{inspect key}) := #{inspect value}" |> IO.puts
        loop(Map.put(map, key, value))
      {:reset} ->
        loop(Map.new())
    end
  end

  def put(k, v) do send :global, {:put, k, v} end
  def get(k) do
    send :global, {:get, k, self()}
    receive do v -> v end
  end
  def all() do
    send :global, {:all, self()}
    receive do v -> v end
  end
  def reset() do
    send :global, {:reset}
  end
end

defmodule Util do
  def transpose(rows) do
    rows
    # |> Enum.map(&String.graphemes/1)
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end
end

defmodule Prob do
  defstruct [:start, :goal, :graph, :height_map]

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
    # |> IO.inspect(label: "grid_rows")

    w = lines |> List.first() |> String.graphemes() |> length()
    h = lines |> length()

    {start, "S"} = grid_rows |> List.flatten() |> Enum.find(fn {_, c} -> c == "S" end)
    {goal, "E"} = grid_rows |> List.flatten() |> Enum.find(fn {_, c} -> c == "E" end)

    height_map = grid_rows
    |> List.flatten()
    |> Enum.map(fn {p, char} -> {p, height_for_char(char)} end)
    |> Enum.sort()
    |> IO.inspect()
    |> Map.new()
    |> IO.inspect(label: "height_map")

    %Prob{
      start: start,
      goal: goal,
      graph: make_graph(height_map, w-1, h-1),
      height_map: height_map,
    }
  end

  def valid_edge?(fromh, toh) when toh - fromh <= 1 do true end
  def valid_edge?(_, _) do false end

  def make_graph(height_map, w_idx, h_idx) do
    # Take the rows and turn it into one-directional edges.

    right_pairs = for row <- 0..h_idx, col <- 0..(w_idx-1) do {{row, col}, {row, col+1}} end
    left_pairs = for {from, to} <- right_pairs do {to, from} end
    down_pairs = for row <- 0..(h_idx-1), col <- 0..w_idx do {{row, col}, {row+1, col}} end
    up_pairs = for {from, to} <- down_pairs do {to, from} end

    Enum.concat([right_pairs, down_pairs, left_pairs, up_pairs])
    |> List.flatten()
    |> Enum.filter(fn {from, to} ->
      fromh = Map.get(height_map, from)
      toh = Map.get(height_map, to)
      val = valid_edge?(fromh, toh)
      # {from, fromh, to, toh, "diff=", toh - fromh, ":", val} |> IO.inspect()
      val
    end)

  end


  def dijkstras(prob) do
    remaining = prob.graph
    |> Enum.map(fn {k, _} -> k end)
    |> MapSet.new()

    for from <- remaining do
      Global.put({:dist, from}, 100000000)
      Global.put({:prev, from}, nil)
    end
    Global.put({:dist, prob.start}, 0)

    d_iter(prob, remaining)
  end

  def calc_path(prob) do
    calc_path(prob, prob.goal, [])
  end
  def calc_path(%{start: start}, start, path) do [start|path] end
  def calc_path(prob, curr, path) do
    calc_path(prob, Global.get({:prev, curr}), [curr|path])
  end

  def get_dist(point) do Global.get({:dist, point}) end

  def d_iter(prob, remaining) do
    if MapSet.size(remaining) == 0 do
      calc_path(prob)
      |> IO.inspect()
    else
      curr = Enum.min_by(remaining, &get_dist/1)
      # |> IO.inspect(label: "curr")

      neighbours = prob.graph
      |> Enum.filter(fn {k, _} -> k == curr end)
      |> Enum.map(fn {_, v} -> v end)

      for next <- neighbours do
        alt = get_dist(curr) + 1  # constant cost
        if alt < get_dist(next) do
          Global.put({:dist, next}, alt)
          Global.put({:prev, next}, curr)
        end
      end
      # |> IO.inspect
      d_iter(prob, MapSet.delete(remaining, curr))
    end
  end
end

defmodule Part1 do
  def run(rows) do
    Global.start_link()
    path = rows
    |> Prob.new()
    # |> IO.inspect()
    |> Prob.dijkstras()

    length(path) - 1  # steps
  end
end

defmodule Part2 do
  def run(rows) do
    Global.start_link()
    prob = rows
    |> Prob.new()
    # |> IO.inspect()
    |> dijkstras()

    low_points = prob.height_map
    |> Enum.filter(fn {p, h} -> h == 97 end)
    |> Enum.map(fn {p, _} -> p end)

    paths = low_points
    |> Enum.map(fn p -> calc_path(p, prob.goal, []) end)
    |> Enum.filter(fn a -> a != nil end)
    |> Enum.map(fn path -> {length(path), path} end)
    |> IO.inspect()

    low_points
    |> Enum.map(fn p -> Global.get({:dist, p}) end)
    |> IO.inspect()
    |> Enum.min()

  end

  def dijkstras(prob) do
    remaining = prob.graph
    |> Enum.map(fn {k, _} -> k end)
    |> MapSet.new()

    Global.put({:dist, prob.goal}, 0)

    d_iter(prob, remaining)
  end

  def calc_path(target, target, path) do [target|path] end
  def calc_path(target, nil, path) do nil end
  def calc_path(target, curr, path) do
    calc_path(target, Global.get({:prev, curr}), [curr|path])
  end


  def get_dist(point) do
    v = Global.get({:dist, point})
    if v == nil do 1000000 else v end
  end
  def get_prev(point) do Global.get({:prev, point}) end

  def d_iter(prob, remaining) do
    if MapSet.size(remaining) == 0 do
      prob
    else
      curr = Enum.min_by(remaining, &get_dist/1)
      # |> IO.inspect(label: "curr")

      # Go backwards
      neighbours = prob.graph
      |> Enum.filter(fn {_, v} -> v == curr end)
      |> Enum.map(fn {k, _} -> k end)

      for next <- neighbours do
        alt = get_dist(curr) + 1 # constant cost
        if alt < get_dist(next) do
          Global.put({:dist, next}, alt)
          Global.put({:prev, curr}, next)
        end
      end
      # |> IO.inspect
      d_iter(prob, MapSet.delete(remaining, curr))
    end
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
    # assert 31 == input |> prepare |> Part1.run
    assert 29 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p12input.txt")
    # assert 437 == input |> prepare |> Part1.run
    assert 430 == input |> prepare |> Part2.run
  end
end
