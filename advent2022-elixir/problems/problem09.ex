
defmodule Prob do
  defstruct [:hx, :hy, :tx, :ty, :tail_path]
  def new() do
    %Prob{hx: nil, hy: nil, tx: 0, ty: 0, tail_path: []}
  end

  def vec("U") do {0, +1} end
  def vec("D") do {0, -1} end
  def vec("L") do {-1, 0} end
  def vec("R") do {+1, 0} end

  def sign(0) do 0 end
  def sign(i) when i > 0 do +1 end
  def sign(_) do -1 end

  def move(p=%{hx: nil, hy: nil}, dir) do
    {dx, dy} = vec(dir)
    %{p|hx: dx, hy: dy, tail_path: [{0, 0}]}
  end
  def move(p, dir) do
    p
    |> move_head(dir)
    |> snap_tail(dir)
  end

  def move_head(p, dir) do
    {dhx, dhy} = vec(dir)
    %{p|
      hx: p.hx+dhx,
      hy: p.hy+dhy,
    }
  end

  def snap_tail(p, dir) do
    {dtx, dty} = p |> tail_vec(dir)
    {tx, ty} = {p.tx+dtx, p.ty+dty}
    %{p|
      tx: tx,
      ty: ty,
      tail_path: [{tx, ty}|p.tail_path],
    }
  end

  def tail_vec(p, dir) do
    dx = p.hx - p.tx
    dy = p.hy - p.ty
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
    {p.hx, p.hy, p.tx, p.ty}
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
    |> Enum.reduce(Prob.new(), fn dir, p -> Prob.move(p, dir) end)

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
    assert {0, +1, 0, 0} == Prob.new() |> Prob.move("U") |> Prob.tuple()
    assert {0, +2, 0, +1} == Prob.new() |> Prob.move("U") |> Prob.move("U") |> Prob.tuple()
    assert {0, -1, 0, 0} == Prob.new() |> Prob.move("D") |> Prob.tuple()
    assert {-1, 0, 0, 0} == Prob.new() |> Prob.move("L") |> Prob.tuple()
    assert {+1, 0, 0, 0} == Prob.new() |> Prob.move("R") |> Prob.tuple()
    assert {+2, 0, +1, 0} == Prob.new() |> Prob.move("R") |> Prob.move("R") |> Prob.tuple()
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
    # assert 5735 == input |> prepare |> Part1.run
    # assert 1805 == input |> prepare |> Part2.run
  end
end
