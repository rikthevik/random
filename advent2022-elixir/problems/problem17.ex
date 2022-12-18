
defmodule Util do
  def list_to_map_array(l) do
    l
    |> Enum.with_index()
    |> Enum.map(fn {v, idx} -> {idx, v} end)
    |> Map.new()
  end
end

defmodule Prob do
  defstruct [:highest, :grid, :rockidx, :rockarray, :jetidx, :jetarray]
  def new(jets) do
    rockshapes = [
      [{2, 0}, {3, 0}, {4, 0}, {5, 0}],          # minus
      [{3, 0}, {2, 1}, {3, 1}, {4, 1}, {3, 2}],  # plus
      [{2, 0}, {3, 0}, {4, 0}, {4, 1}, {4, 2}],  # backwards-L
      [{2, 0}, {2, 1}, {2, 2}, {2, 3}],          # pipe
      [{2, 0}, {3, 0}, {2, 1}, {3, 1}],          # box
    ]

    %Prob{
      highest: -1,
      grid: MapSet.new(),
      rockidx: 0,
      rockarray: Util.list_to_map_array(rockshapes),
      jetidx: 0,
      jetarray: Util.list_to_map_array(jets),
    }
  end

  def draw(p, rock \\ []) do
    g = p.grid
    |> Enum.map(fn p -> {p, "#"} end)
    |> Enum.concat(Enum.map(rock, fn p -> {p, "@"} end))
    |> Map.new()

    for y <- (6+p.highest)..0 do
      IO.write("|")
      for x <- 0..6 do
        IO.write(Map.get(g, {x, y}, "."))
      end
      IO.puts("|")
    end
    IO.puts("+-------+")
    p
  end

  def set_rock(p, rock) do
    rock_highest = rock
    |> Enum.map(fn {_, y} -> y end)
    |> Enum.max()

    %{p|
      grid: MapSet.union(p.grid, MapSet.new(rock)),
      highest: max(p.highest, rock_highest),
      rockidx: p.rockidx + 1,
    }
  end

  def point_overlaps?(_p, {x, _y}) when x < 0 or x > 6 do true end
  def point_overlaps?(_p, {_x, y}) when y < 0 do true end
  def point_overlaps?(p, {x, y}) do MapSet.member?(p.grid, {x, y}) end

  def rock_overlaps?(p, rock) do
    rock
    |> Stream.map(fn {x, y} -> point_overlaps?(p, {x, y}) end)
    |> Enum.any?()
  end

  def next_rock(p) do
    rock = p.rockarray
    |> Map.get(rem(p.rockidx, Enum.count(p.rockarray)))
    |> Enum.map(fn {x, y} -> {x, y + 4 + p.highest} end)

    move_rock(p, rock)
  end

  def next_jet(p) do
    jet_dir = Map.get(p.jetarray, rem(p.jetidx, Enum.count(p.jetarray)))
    p2 = %{p| jetidx: p.jetidx + 1}
    {jet_dir, p2}
  end

  def add_vec(rock, {dx, dy}) do
    rock
    |> Enum.map(fn {x, y} -> {x+dx, y+dy} end)
  end
  def vec_for_dir(">") do {+1, 0} end
  def vec_for_dir("<") do {-1, 0} end
  def vec_for_dir("v") do {0, -1} end

  def try_move(p, dir, rock) do
    # {dir, rock} |> IO.inspect(label: "try_move")
    new_rock = add_vec(rock, vec_for_dir(dir))
    if rock_overlaps?(p, new_rock) do
      {:stopped, rock}
    else
      {:moved, new_rock}
    end
  end

  def move_rock(p, rock) do
    # p |> draw(rock)
    {jet_dir, p2} = next_jet(p)
    {_, rock_jetted} = try_move(p2, jet_dir, rock)
    case try_move(p2, "v", rock_jetted) do
      {:stopped, rock_jetted} ->
        # add this rock to the grid and stop
        Prob.set_rock(p2, rock_jetted)
      {:moved, rock_dropped} ->
        move_rock(p2, rock_dropped)
    end
  end

end

defmodule Part1 do
  def run(rows) do
    rows
    |> Prob.new()
    |> work(2022)

  end

  def work(p, 0) do p.highest + 1 end
  def work(p, rocks_remaining) do
    work(Prob.next_rock(p), rocks_remaining-1)
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
    |> String.graphemes()
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
    |> List.first()
  end

  test "example" do
    input = ">>><<><>><<<>><>>><<<>>><<<><<<>><>><<>>"
    assert 3068 == input |> prepare |> Part1.run
    # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p17input.txt")
    assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end
end
