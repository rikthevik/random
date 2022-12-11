
defmodule Prob do
  defstruct [:knots, :tail_path]
  def new(num_knots) do
    knots = for _ <- 1..num_knots do {0, 0} end
    %Prob{knots: knots, tail_path: [{0, 0}]}
  end

  def vec("U") do {0, +1} end
  def vec("D") do {0, -1} end
  def vec("L") do {-1, 0} end
  def vec("R") do {+1, 0} end

  def sign(0) do 0 end
  def sign(i) when i > 0 do +1 end
  def sign(_) do -1 end

  def move(p, dir) do
    [{hx, hy}|rest] = p.knots
    {dx, dy} = vec(dir)
    new_knots = follow({hx+dx, hy+dy}, rest)
    # |> draw_knots()
    new_tail_spot = new_knots |> List.last()

    %{p|
      knots: new_knots,
      tail_path: [new_tail_spot|p.tail_path],
    }
  end

  def follow(curr, []) do [curr] end
  def follow(curr, [next|rest]) do
    {dx, dy} = tail_vec(curr, next)
    {nx, ny} = next
    [curr] ++ follow({nx+dx, ny+dy}, rest)
  end

  def tail_vec({hx, hy}, {tx, ty}) do
    dx = hx - tx
    dy = hy - ty
    {dx, dy}
    cond do
      abs(dx) == 2 ->
        # IO.inspect("dx2")
        {sign(dx), sign(dy)}
      abs(dy) == 2 ->
        # IO.inspect("dy2")
        {sign(dx), sign(dy)}
      true ->
        # IO.inspect("true")
        {0, 0}
    end
    # |> IO.inspect(label: "tail_vec")
  end

  def tuple(p) do
    [{hx, hy}, {tx, ty}] = p.knots
    {hx, hy, tx, ty}
  end

  def draw_knots(knots) do
    knots |> IO.inspect
    xs = for {x, _} <- knots do x end
    ys = for {_, y} <- knots do y end
    {xmin, xmax} = Enum.min_max([0|xs])
    {ymin, ymax} = Enum.min_max([0|ys])
    knot_map = knots ++ [{0, 0}]
    |> Enum.zip(["H", "1", "2", "3", "4", "5", "6", "7", "8", "9", "s"])
    |> Enum.reverse()
    |> Map.new()
    |> IO.inspect
    for y <- (ymax+1)..(ymin-1) do
      for x <- (xmin-1)..(xmax+1) do
        c = Map.get(knot_map, {x, y}, ".")
        IO.write(c)
      end
      IO.puts ""
    end
    IO.puts ""
    knots
  end

end

defmodule Part1 do
  def explode_row({dir, num}) do
    for _ <- 1..num do dir end
  end

  def run(rows) do
    p = rows
    |> Enum.map(&explode_row/1)
    |> Enum.concat()
    |> Enum.reduce(Prob.new(1), fn dir, p -> Prob.move(p, dir) end)

    p.tail_path
    |> MapSet.new()
    |> MapSet.size()
  end
end

defmodule Part2 do
  def run(rows) do
    p = rows
    |> Enum.map(&Part1.explode_row/1)
    |> Enum.concat()
    # |> Enum.take(24)
    # |> Enum.take(13)
    |> Enum.reduce(Prob.new(10), fn dir, p -> Prob.move(p, dir) end)

    p.knots |> Prob.draw_knots()

    p.tail_path

    |> MapSet.new()
    |> MapSet.size()
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    [c, d] = s |> String.split(~r/ +/)
    {c, String.to_integer(d)}
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "tests" do
    # assert {0, +1, 0, 0} == Prob.new(1) |> Prob.move("U") |> Prob.tuple()
    # assert {0, +2, 0, +1} == Prob.new(1) |> Prob.move("U") |> Prob.move("U") |> Prob.tuple()
    # assert {0, -1, 0, 0} == Prob.new(1) |> Prob.move("D") |> Prob.tuple()
    # assert {-1, 0, 0, 0} == Prob.new(1) |> Prob.move("L") |> Prob.tuple()
    # assert {+1, 0, 0, 0} == Prob.new(1) |> Prob.move("R") |> Prob.tuple()
    # assert {+2, 0, +1, 0} == Prob.new(1) |> Prob.move("R") |> Prob.move("R") |> Prob.tuple()
  end

  test "example" do
    input = "R 4
    U 4
    L 3
    D 1
    R 4
    D 1
    L 5
    R 2"
    # assert 13 == input |> prepare |> Part1.run
    # assert 1 == input |> prepare |> Part2.run
  end

  test "example2" do
    input = "R 5
    U 8
    L 8
    D 3
    R 17
    D 10
    L 25
    U 20"
    assert 36 == input |> prepare |> Part2.run
  end


  test "go time" do
    input = File.read!("./inputs/p9input.txt")
    # assert 5735 == input |> prepare |> Part1.run
    assert 5735 == input |> prepare |> Part2.run
  end
end
