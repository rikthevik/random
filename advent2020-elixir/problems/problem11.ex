
defmodule Util do
  def draw_map(m) do
    {minx, maxx} = m |> Enum.map(fn {{x, _y}, _v} -> x end) |> Enum.min_max
    {miny, maxy} = m |> Enum.map(fn {{_x, y}, _v} -> y end) |> Enum.min_max
    for y <- miny..maxy do
      for x <- minx..maxx do
        m |> Map.get({x, y}) |> IO.write
      end
      IO.puts ""
    end
  end
end

defmodule Problem do

  def load_line(line) do
    line |> String.trim
  end

  def load(inputstr) do
    lines = inputstr
    |> String.split("\n")
    |> Enum.map(&load_line/1)

    m = for {l, y} <- Enum.with_index(lines), {c, x} <- Enum.with_index(String.graphemes(l)), into: %{} do
      {{x, y}, c}
    end

    
  end

  def step(m) do step(m, %{}) end
  def step(m, last) when m == last do m end
  def step(m, _last) do
    m
    |> Enum.map(fn {{x, y}, c} -> {{x, y}, seat_change(m, {x, y}, c)} end)
    |> Map.new
    |> step(m)
  end
  
  def occupied?("#") do true end
  def occupied?(_) do false end

  def seat_change(m, {px, py}, ".") do "." end
  def seat_change(m, {px, py}, "L") do
    adjacent_occupied = m 
    |> adjacent_points({px, py})
    |> Enum.filter(fn c -> occupied?(c) end)
    |> Enum.count
    if adjacent_occupied == 0, do: "#", else: "L"
  end
  def seat_change(m, {px, py}, "#") do
    adjacent_occupied = m 
    |> adjacent_points({px, py})
    |> Enum.filter(fn c -> occupied?(c) end)
    |> Enum.count
    if adjacent_occupied >= 4, do: "L", else: "#"
  end

  def adjacent_points(m, {px, py}) do
    for y <- -1..1, x <- -1..1, {x, y} != {0, 0} do
      m |> Map.get({px+x, py+y})
    end
  end

  def part1(m) do
    step(m)
    |> Enum.filter(fn {{x, y}, c} -> occupied?(c) end)
    |> Enum.count
  end 

  def part2(ints) do
    
  end

  
end

defmodule Tests do 
  use ExUnit.Case
  
  test "examples" do
    inputstr = "L.LL.LL.LL
    LLLLLLL.LL
    L.L.L..L..
    LLLL.LL.LL
    L.LL.LL.LL
    L.LLLLL.LL
    ..L.L.....
    LLLLLLLLLL
    L.LLLLLL.L
    L.LLLLL.LL"
    assert 37 == inputstr |> Problem.load |> Problem.part1
    # assert 8 == inputstr |> Problem.load |> Problem.part2
  end

  

end
