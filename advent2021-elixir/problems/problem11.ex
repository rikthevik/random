
defmodule Grid do
  defstruct [:h, :w, :pointmap]
  def new(rows) do
    pointmap = for {y, cols} <- Enum.zip(0..10000, rows) do
      for {x, val} <- Enum.zip(0..10000, cols) do
        {{x, y}, val}
      end
    end
    |> List.flatten
    |> Map.new

    %Grid{
      h: rows |> Enum.count,
      w: rows |> Enum.at(0) |> Enum.count,
      pointmap: pointmap,
    }
  end
  def set(g, k, v) do
    %Grid{g|
      pointmap: g.pointmap |> Map.put(k, v)
    }
  end
  def adjacent_diag(g, {x, y}) do
    [
      {x-1, y+1}, {x, y+1}, {x+1, y+1},
      {x-1, y},             {x+1, y},
      {x-1, y-1}, {x, y-1}, {x+1, y-1},
    ]
    |> Enum.filter(fn p -> Map.has_key?(g.pointmap, p) end)
  end
  def draw(g) do
    IO.puts ""
    for y <- g.h..-1 do
      for x <- -1..g.w do
        IO.write Map.get(g.pointmap, {x, y}, ".")
      end
      IO.puts ""
    end
    g
  end
end

defmodule Util do

end

defmodule Part1 do
  def run(rows, steps_remaining) do
    try do
      rows
      |> Grid.new
      |> Grid.draw
      |> step(steps_remaining)
    catch
      {:synchronized, step_count} ->
        steps_remaining - step_count + 1
    end
  end

  def step(g, steps_remaining) do
    step(g, Map.keys(g.pointmap), steps_remaining, 0)
  end
  def step(g, [p|rest], steps_remaining, flash_count) do
    # IO.inspect(rest, label: "#{inspect p}")
    case Map.get(g.pointmap, p) do
      "!" ->
        step(g, rest, steps_remaining, flash_count)
      currval ->
        case increase_val(currval) do
          "!" ->
            g2 = Grid.set(g, p, "!")
            step(g2, rest ++ Grid.adjacent_diag(g2, p), steps_remaining, flash_count)
          newval ->
            g2 = Grid.set(g, p, newval)
            step(g2, rest, steps_remaining, flash_count)
        end
    end
  end
  def step(g, [], 0, flash_count) do flash_count end
  def step(g, [], steps_remaining, flash_count) do
    flash_locations = g.pointmap
    |> Enum.filter(fn {p, v} -> v == "!" end)
    |> Enum.map(fn {p, v} -> p end)

    if Enum.count(flash_locations) == Enum.count(g.pointmap) do
      throw {:synchronized, steps_remaining}
    end

    g2 = %Grid{g|
      pointmap: g.pointmap
        |> Map.merge(flash_locations
          |> Enum.map(fn p -> {p, 0} end)
          |> Map.new)
    }

    # g2 |> Grid.draw
    step(g2, g2.pointmap |> Map.keys, steps_remaining-1, flash_count + Enum.count(flash_locations))
  end

  def increase_val(9) do "!" end
  def increase_val("!") do "!" end
  def increase_val(val) when val >= 0 and val <= 9 do val+1 end

end

defmodule Part2 do
  def run(rows) do
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "pre-example" do
    input = "11111
    19991
    19191
    19991
    11111"
    assert 9 == input |> prepare |> Part1.run(2)
end

  test "example" do
      input = "5483143223
      2745854711
      5264556173
      6141336146
      6357385478
      4167524645
      2176841721
      6882881134
      4846848554
      5283751526"
      assert 204 == input |> prepare |> Part1.run(10)
      assert 1656 == input |> prepare |> Part1.run(100)
      assert 195 == input |> prepare |> Part1.run(1000)
  end

  test "go time" do
    input = "8271653836
    7567626775
    2315713316
    6542655315
    2453637333
    1247264328
    2325146614
    2115843171
    6182376282
    2384738675"
    assert 1562 == input |> prepare |> Part1.run(100)
    assert 268 == input |> prepare |> Part1.run(1000000)
  end
end
