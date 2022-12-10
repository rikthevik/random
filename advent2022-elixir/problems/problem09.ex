
defmodule Prob do
  defstruct [:knots, :tail_path]
  def new(num_knots) do
    knots = for _ <- 0..num_knots do {0, 0} end
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
    {dx, dy} |> IO.inspect(label: "tail_vec dex")
    cond do
      abs(dx) == 2 ->
        IO.inspect("dx2")
        {sign(dx), dy}
      abs(dy) == 2 ->
        IO.inspect("dy2")
        {dx, sign(dy)}
      true ->
        IO.inspect("true")
        {0, 0}
    end
    |> IO.inspect(label: "tail_vec")
  end


  def tuple(p) do
    [{hx, hy}, {tx, ty}] = p.knots
    {hx, hy, tx, ty}
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
    |> IO.inspect()
    |> Enum.reduce(Prob.new(1), fn dir, p -> Prob.move(p, dir) end)

    p.tail_path
    |> MapSet.new()
    |> MapSet.size()
  end
end

defmodule Part2 do
  def run(rows) do
    rows
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
    assert {0, +1, 0, 0} == Prob.new(1) |> Prob.move("U") |> Prob.tuple()
    assert {0, +2, 0, +1} == Prob.new(1) |> Prob.move("U") |> Prob.move("U") |> Prob.tuple()
    assert {0, -1, 0, 0} == Prob.new(1) |> Prob.move("D") |> Prob.tuple()
    assert {-1, 0, 0, 0} == Prob.new(1) |> Prob.move("L") |> Prob.tuple()
    assert {+1, 0, 0, 0} == Prob.new(1) |> Prob.move("R") |> Prob.tuple()
    assert {+2, 0, +1, 0} == Prob.new(1) |> Prob.move("R") |> Prob.move("R") |> Prob.tuple()
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
    assert 13 == input |> prepare |> Part1.run
    # assert 8 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p9input.txt")
    assert 5735 == input |> prepare |> Part1.run
    # assert 1805 == input |> prepare |> Part2.run
  end
end
