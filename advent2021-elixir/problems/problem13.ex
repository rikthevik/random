
defmodule Grid do
  def new(points) do
    for {y, cols} <- Enum.zip(0..10000, points) do
      for {x, val} <- Enum.zip(0..10000, cols) do
        {x, y}
      end
    end
    |> List.flatten
    |> MapSet.new
  end

end

defmodule Util do

end

defmodule Part1 do
  def draw(pmap) do
    {max_x, _} = Enum.max_by(pmap, fn {x, _} -> x end)
    {_, max_y} = Enum.max_by(pmap, fn {_, y} -> y end)
    for y <- 0..max_y do
      for x <- 0..max_x do
        IO.write(if MapSet.member?(pmap, {x, y}) do "#" else "." end)
      end
      IO.puts ""
    end
    pmap
  end


  def run({points, folds}) do
    pmap = points
    |> MapSet.new
    |> draw

    IO.puts "hello"

    pmap
    |> fold_over(Enum.at(folds, 0))
    |> draw
    |> Enum.count
  end

  def fold_over(pmap, {"y", foldy}) do
    above = Enum.filter(pmap, fn {_, y} -> y < foldy end)
    below = Enum.filter(pmap, fn {_, y} -> y > foldy end)

    to_add = for {x, y} <- below do
      {x, 2 * foldy - y}
    end

    above
    |> Enum.concat(to_add)
    |> MapSet.new
  end

end

defmodule Part2 do
  def run(rows) do
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_point(s) do
    s
    |> IO.inspect
    |> String.split(~r/,/)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple
  end

  def prepare_fold(s) do
    [_, axis, val] = Regex.run(~r/fold along ([xy])=(\d+)/, s)
    {axis, String.to_integer(val)}
  end

  def prepare(input) do
    [points, folds] = input
    |> String.trim
    |> String.split(~r/ *\n\n */)
    |> Enum.map(fn s -> Regex.split(~r/ *\n */, s) end)

    {
      points |> Enum.map(&prepare_point/1),
      folds |> Enum.map(&prepare_fold/1),
    }
    |> IO.inspect

  end


  test "example" do
    input = "6,10
      0,14
      9,10
      0,3
      10,4
      4,11
      6,0
      6,12
      4,1
      0,13
      10,12
      3,4
      3,0
      8,4
      1,10
      2,14
      8,10
      9,0

      fold along y=7
      fold along x=5"
    assert 17 == input |> prepare |> Part1.run

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
    # assert 1562 == input |> prepare |> Part1.run(100)
    # assert 268 == input |> prepare |> Part1.run(1000000)
  end
end
