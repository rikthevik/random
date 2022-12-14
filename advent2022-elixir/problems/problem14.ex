
defmodule Util do
  def draw(grid) do
    # grid |> Enum.sort() |> IO.inspect()

    IO.puts("--")
    {wmin, wmax} = grid |> Enum.map(fn {{x, _}, _} -> x end) |> Enum.min_max()
    {hmin, hmax} = grid |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min_max()
    for y <- hmin..hmax do
      for x <- wmin..wmax do
        IO.write(Map.get(grid, {x, y}, "."))
      end
      IO.puts("")
    end
  end
end

defmodule Prob do
  defstruct [:grid, :abyss_height, :done]
  def new(rows) do
    grid = rows
    |> Enum.map(&point_lines/1)
    |> Enum.concat()
    |> Enum.map(&({&1, "#"}))
    |> Map.new()

    {hmin, hmax} = grid |> Enum.map(fn {{_, y}, _} -> y end) |> Enum.min_max()
    abyss_height = hmax + 1

    %Prob{
      grid: grid,
      abyss_height: abyss_height,
      done: false,
    }
    # |> IO.inspect
  end

  def drop_sand(prob=%{abyss_height: y}, {_, y}) do %{prob|done: true} end
  def drop_sand(prob, {x, y}) do
    # {x, y} |> IO.inspect(label: "drop_sand")
    cond do
      Map.get(prob.grid, {x, y+1}) == nil ->
        drop_sand(prob, {x, y+1})
      Map.get(prob.grid, {x-1, y+1}) == nil ->
        drop_sand(prob, {x-1, y+1})
      Map.get(prob.grid, {x+1, y+1}) == nil ->
        drop_sand(prob, {x+1, y+1})
      true ->
        %{prob| grid: Map.put(prob.grid, {x, y}, "o")}
    end
  end


  # Draw the grid in its current state.
  def draw(prob) do
    Util.draw(prob.grid)
    prob
  end

  # All of the points for a list of line segments.
  def point_lines([p|rest]) do point_lines(p, rest, []) end
  def point_lines(_, [], acc) do acc end
  def point_lines({px, py}, [{nx, ny}|rest], acc) do
    # {{px, py}, {nx, ny}} |> IO.inspect(label: "point_lines")
    new_points = for x <- px..nx, y <- py..ny do {x, y} end
    point_lines({nx, ny}, rest, acc ++ new_points)
  end


end

defmodule Part1 do
  def run(rows) do
    dropped = drop_until(Prob.new(rows), 0)
  end
  def drop_until(%{done: true}, count) do count - 1 end
  def drop_until(prob, count) do
    drop_until(Prob.drop_sand(prob, {500, 0}), count+1)
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

  def prepare_point(s) do
    s
    |> String.split(~r/,/)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end
  def prepare_row(s) do
    s
    |> String.split(~r/ -> /)
    |> Enum.map(&prepare_point/1)
  end
  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "498,4 -> 498,6 -> 496,6
    503,4 -> 502,4 -> 502,9 -> 494,9"
    assert 24 == input |> prepare |> Part1.run
    # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p14input.txt")
    assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end
end
