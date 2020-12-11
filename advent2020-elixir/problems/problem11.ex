
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
  def seat?("#") do true end
  def seat?("L") do true end
  def seat?(_) do false end

  def seat_change(m, {px, py}, ".") do "." end
  def seat_change(m, {px, py}, "L") do
    adjacent_occupied = m 
    |> adjacent_seats({px, py})
    |> Enum.filter(fn c -> occupied?(c) end)
    |> Enum.count
    if adjacent_occupied == 0, do: "#", else: "L"
  end
  def seat_change(m, {px, py}, "#") do
    adjacent_occupied = m 
    |> adjacent_seats({px, py})
    |> Enum.filter(fn c -> occupied?(c) end)
    |> Enum.count
    if adjacent_occupied >= 4, do: "L", else: "#"
  end
  def adjacent_seats(m, {px, py}) do
    for y <- -1..1, x <- -1..1, {x, y} != {0, 0} do
      m |> Map.get({px+x, py+y})
    end
  end

  def part1(m) do
    step(m)
    |> Enum.filter(fn {{x, y}, c} -> occupied?(c) end)
    |> Enum.count
  end 

  # copy paste
  def seat_change2(m, {px, py}, ".") do "." end
  def seat_change2(m, {px, py}, "L") do
    adjacent_occupied = m 
    |> adjacent_seats2({px, py})
    |> Enum.filter(fn c -> occupied?(c) end)
    |> Enum.count
    if adjacent_occupied == 0, do: "#", else: "L"
  end
  def seat_change2(m, {px, py}, "#") do
    adjacent_occupied = m 
    |> adjacent_seats2({px, py})
    |> Enum.filter(fn c -> occupied?(c) end)
    |> Enum.count
    if adjacent_occupied >= 5, do: "L", else: "#"
  end
  def next_seat(m, {px, py}, {vx, vy}) do 
    1..10000
    |> Stream.map(fn i -> Map.get(m, {px+vx*i, py+vy*i}) end)
    |> Stream.filter(fn c -> c == nil or seat?(c) end)
    |> Stream.take(1)
    |> Enum.to_list
    |> List.first
  end
  def adjacent_seats2(m, {px, py}) do
    for y <- -1..1, x <- -1..1, {x, y} != {0, 0} do
      next_seat(m, {px, py}, {x, y})
    end
  end
  def step2(m) do step2(m, %{}) end
  def step2(m, last) when m == last do m end
  def step2(m, _last) do
    m
    |> Enum.map(fn {{x, y}, c} -> {{x, y}, seat_change2(m, {x, y}, c)} end)
    |> Map.new
    |> step2(m)
  end
  
  def part2(m) do
    step2(m)
    |> Enum.filter(fn {{x, y}, c} -> occupied?(c) end)
    |> Enum.count
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
    assert 26 == inputstr |> Problem.load |> Problem.part2
  end

  test "go time" do
    inputstr = "LLLLL.LLLLLLLLLLLLLLLLL.LLLLLL.LLLLL.L.LLLLLL.LLLLLL.LLL.LLLLLLLL.LLLLL.L.LLLLLLLLLLLLLLLL.LLLLLLL
    LLLLL.LLLLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLL.LLL.LLLLLLLLLLLLL.L.LLLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLL.LLL..LLLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLL.LLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLL.L.LLLLLLLLLLLLLLLL.LLLLL.L
    LLLLL.LLLLLLLLL.LLLLLLL.LLLL.L.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLL.LLLLLLLLLLLLL.LLLLLLLLLLLLL
    L.LLLLLLLLLLLLL.LLLLLLL.LLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LL.LLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LL.LLLLLLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLL
    LLLLLLLLLLLLLLLLLLL.LLL.LLLLLL.L.LLL.LLLLLLLLL.LLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLL.LL.LLLL
    LLLLL.LLLLLLLLL.LLLLLLLLLLL.LL.LLLLL.LLLLLL.LL.LLLLLLLL..LLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    LL.LL.LLL.LLLLLLLLLLLLL.LLLL.L.LLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLL.L.LLLLLLL
    ......L....L...L...L.....L........LLL..LL..LL..L.L..LL.L..L.....LL......L.LLL.L..L....LLL.......LL
    LLLLL.LLLLLLLL.LLLLLLLL.LLLLL..LLLLL.LLL.LLLL..LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    LLLLL.LLLLLLLLL.LL.LLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLL.LL..L.L
    LLLLL.LLLLLLL...LLLLLLLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLL.LLLLLLLLLLLLL.LLLLLL.LLLLLLL
    LLLLL.LLLLLLLL..LLLLLLL.LLLLL.LL.LLL.LLLLLLLLL.LLL.LLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLL.LL.LLLLLLLLLLLL..LLLLLLLL.LLLLLLLLL.LLLLLLLLLLL.LLLL.LL.LLLLLL.LLLLLL.LLLLLLL
    LLLLL.LLLLLLLLLLLLLLLLL.LLLLLLLLL.LL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLL.LL.LLLL
    L.LL..LLLLLLLLL.LLLLLLL.L.LLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL..LLLLLLLLL.LLLLLLLLLLLLLL
    .L.......L..LL.....L.L.....L..............L.L.L.LL..LL.L.L..LLL.L..LL.............LLL.L......L.LL.
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLL.LLLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LL.LLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLL.L.LLLL.LLLLLLL
    LLLLL.LLL.LLLLL.LLLLLLL.LLLLLL..LLLLLLLLLLLLLLLLLLLL.LLL.L.LLLLLLLLLLLLLL.LLLLLLLLLL.LLLLL..L.LLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLL..LLLLLL.LLLLLLLLL.LLLLLLL.LL.LL.
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLL.L.LL.LLLLL..L..LLL.L.LLLLLLL..LLLLLLLL..LLLLL.LLLLLLL
    LLLLL.LLL.LLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLLL.LLLLL.LLL.LLLLL.LL.LL.LLLL.LLLLLL.LL.LLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLL..LLLLLLLLLLLLL.L.LLLLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLL.LL.LLLL
    LLLLL.LLLLLLLLLLLLLLLLLLLLLLLL.L.LLL.LLLLLL.LL.LLLLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLL.LLL.LLLLLLLLLL
    ......L.....L...LL.L.L..L...L....L...LLL...LLLLL..L.....L.....L..L......L...L.L.......L..L.LL...L.
    LL.LLL.LLLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLLLLLL.LL.LLLL.LLLLLLLLL.LL.LLLLLLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLL..LLLLLLLLL..LLLLLLLL.LLLL.LLL..LLLLLLLLLLLLLLLL.LLLL.L.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL..LLLLLL.LLLLLL.LLLLLL.LL.LLLLLLL
    LLLLL..LL.LLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLLL.LLLL..LLLLLLL
    .LLL...LL.....L.L..L.LL..LL......LL.L.L........L.L.....LLLL.L.L.......L......LL.....LLLL....L.L.LL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LL.LLLL.LLLLLLLLLLLLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLL.LLLLLLLLLLLLLL
    LLLL..LLLLLLLLL.LLLLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLLL.L..LLLLLLL..LLLL.L.LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLLLLLL.LL.LLLLLLL.LLLL.L.LLLLLLLLLLLL.LL.LLLLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLL..LLLLL.LLLLLLL
    LLLLLLLLLLL.LLL.LLLLLLLL.LLLLL.LLLLL.LLLLLLLLLLLLLLLLLLL.LLLL.LLL.LLLLLLLLLLLLLLL.L.LLLLLLLLLLLLLL
    .L.L...L...L.....L...LLLLLLL.LL....LL..LLL...L...L.LLL..L.L...L.L.L....L.LL.LLL..L....L..LL..L...L
    LLLLLLLLLLL.LL..LLLL..L.LLLLLL.LLLLLLLLLLLL.LL.LLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL....LLLLLLLLLLL
    LLLLLLLLLLLLLLLLLLLLL.LLLLLLLL.LLLLL.LL.LLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLL.LLLLLLLL.LLLL..LLL.LLLLLLLLLLLLLLL.LLLLLL.L.LLLL.LL.LLLL.LLLLLLLLLL..LLLLLLL
    LLLLL..LLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLLLLLL.LLLLL.LLLLLLLLLLLLLL
    LLLLL.LLLLLLLLL.LLLL.LLLLLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLL.
    LLLLL.LLLLLLLLLLLLL.LLL.LLLLLL..LLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLL..LLLL.LLLL.LLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL
    LLLLLLLLLLLLLLL.LLLLLLL.LLLLLL.LLL.L.LLLLLLLLL..LLLLL.LL..LLLLLLL.LLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    L..L.L.LLL.LL.......LL.LL..LL.L...L..LLL........L.LL....LL...LL.L.....LL......L.L.L...L.L.L..L..L.
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLL.LLLLLL.LLLL.LLLL.LLLLLLLLLLLLLLLLL..LLLL.LL.LLLLLLLLL.LLLLLL.LLLLLLL
    LL.LLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLL.LLLL.LLLL.LLLLLL.L.LLLLL
    LLLLL.LLLLLLL.L.L.L.LLL..LLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL.LLL.LLLLLLLLLLLLLL.LLLLL
    LL....LLLLLLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLL
    L.LLL.LLLLLLLLL.LL.LL.L.LLLLLL.LLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLL..LLLLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLLLLLLLLL.LLLLLLLLLLLLLL..LLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLL..LLLLLLLLLLLLLL.LLLL.LLLLLLLL..LLLLLLLLLLLLLLL..LLLLLL..L.LLLL
    LLLLL.LLL.LL.LL.L.LLLLLLLLLLLLL.LLLLLLLLLLLLLL.LLLL.LLLLLLLLLLLL..LLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLL
    ..LL....L.LL...L.......L.L...L.L..LLL....L...L.L..L...L......L...LLL.L.L...L..L.LL...L..L..L.L...L
    LLLLL.LLLLLL....LLLLLLL.LLLLLL.LLLLLLLLLLL.LLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLLLLL.LLL..LLLLLL.LLLLLLL
    LLLLL..LLLLLLL.LLLLLLLLLLLLLLL.LLLLLL.LL.LLLLLLLLLL.LLLL..LLLLLLLLLLLLL.L.LLLLLLLLLLLLLLLL.LLLL.LL
    LLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLL.LLLL.L.LLLLLLL
    LLLLL.LLLLLLLLL.L.LLLLL.LLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLLLLLLLL.LLLLL..LLLLL.LLLLLLL
    LLLL..LLLLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLL.LLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLL.LLLLLL.LLLLL.L
    LLLLL.LLLLLLLLLLLLLLLLL.LLLLLL.LLLLLLLLLLLLLLLL.LLLLLLLL.LLLLLLLL.LLL.LLLLLLLLLLLLL.LLLLLLLLLLLL.L
    LLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLL.LLLL.LLLLLLLLL.LLLLLLLLL.LLLLL..LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLLLLLLLLLLLLLLLLL.LL.LLL.LLLLL.LLLLLLLLL.LLLL.LLLL.LLLLLLLL.LLLLLLL.LLLLLLLLL.LLLLLL.LLLL.LL
    LLLLL.LLLLLLLLL.LLLLLLL..LLLLL.LLLLLLLL.LLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLL.L.LLLL.LLLL.LL
    .L.....L.LL.......L.L..L.L...LLL.L.LL..LLL..L.L....L........L..L.L...L....L...L.LL..L.....L..LL..L
    LLLLL.LLLLLLLLL.LLLLLLL.LLLL.LLL.LLLLLLLLLLLLL.LLLLLLLLL.LL.LLLLL.LLLLLLL.LLLLLL.LLLLLLLLL.LLLLLLL
    LLLLLLLLLLLLLLL.LL.LLLL.LLLLLL.LLLLL.LL.LLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLLLLLL.LLLLL.LLLLLL.LLLLLLL
    LLLLL.LLLL..LLL.LLLLLLL.LL.LLLLLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLLLL.LLLLLL..LL.LLL
    LLLLL.LLLLLLLLLLLLLLLLLLLLLL.L.LLLLLL.L.LLLLLLLLLLL.LLLL.LL.LLLLLLLLLLLLL.LLLLLLLLLLLLLLL..LLLLLLL
    LLLLL.L.LLLLLL..LLLLL.L.LLLLLL.LLLLLLLLLLLLLLLLLLLLLLLL..LLLLLLLL.LLLLLL..LLLLLLLLLLLLLLLLLLLLLLLL
    LL.LL.LLLLLLLL.LLLLLLL.LLL.LLL...LLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LL.L.LLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLLLLLLL.LLLLLLL.LLLLLL.LL.LLLLLL.LL.LLLL
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLL..LLLLL.LLL.LLLLLLLLL.LLLLL.LLLLLL.L.LLLLLLL.LLLLLL.LL.LLLLL.LLLLLLLL
    LLLLL.LLL.LLLLL.LLLLLLLLLL.LLL.LLLLL.LLLLLLLLLLLLL.LLLLLLLLLLL..LLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLLL
    ........LL..LLL.....L.L...LLL...L.........L.L...L..L...LL.L.....L....L....L.....L....L....L.LLL...
    LLLLL.LLLLL..LLLLLLLLLLLLL.LLL.LLLLL.LLLLLLLLL.LLLLLL.LLLLLLLLLLL.LLLLL.LLLLLLLLLLL.LLL.LL.LLLLLLL
    LLLLL.LLLLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLLLLLL.LLLL.LL.LL
    LL.LL.LLLLLLLL.LLLLL.LLLLLLLL.LLLLLL.LLLLLLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLL..LLLLLLLLLLLLLLLLLLLLLLL
    LLLLL.LLLLLLLLLLLLLLLLL.LLLLLL.LLLLL.LLLL.LLLLLL.LLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLL.LLLLL.L
    LLLLL..LLLLLLLL.LLLLLLL.LLLLLLLLL.LL.LLLLLLLLL.LLLLLLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLLLLLLLLL.LLLLLL..LLLLLL.LLLLL.LLLLLLLL.LL.LLLLLLL.LLLLL.LL.LLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLL
    L.LL.....LL......LL.L.LL...LL..........LL.LLL...L..L..LL....L......L.....LL.....LL.L..L.LL.L.L....
    LLLLL.LLLLLLLLLL.LLLLLL.LLLLLL.LLLLLLLLLLLLLLL.LLLL.LL.L.LLLLL.LLLLLLLLLL.LLLLLLLLLLLLLL.L.LLLLLLL
    LLLLLLL.LLLLLLL.LLLLLLL.LLLLLL.LL.LLLLLLLLLLLL.LLLLLLLLL.L.LLLLLL.LLLLLLLLLLLLLLLLL.LLLLLL.LLLLLLL
    LLLLLLLLLLLLLLL.LL.LLLL.LLLLLL.LL.LL.LLL.LLLLL.LLLLLLLLLLLLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLL.LLLLLLL
    LLLLL.LLLLLLLLL.LLLLLL..LLL.LL.LLLLL.LLLLLLLLLLLLL.LLLLL.LLLLLLLL.LLLLLLL.LLLLLLLLLLLLLLLL.LLLL.L.
    LLLLL.LLLLLLLLL.LLLLLLL.LLLLL.LLLLLLLLLLLLLLLL.LLLLLLLLLLLLLLLLLL.LLLLLLL.LLLLLLLLL.LLLLLL.LLLL.LL
    LLLLL.LLLLLLLLL..LLLLLL.LLLLLL.LLLL.LLLLLL.LLL.LLLLL.LLL.LLLLLLL..LLLLLLLLLLLLL.LLLLLLLLLL.LLLLLLL"
    assert 2303 == inputstr |> Problem.load |> Problem.part1
    assert 8 == inputstr |> Problem.load |> Problem.part2
  end


end
