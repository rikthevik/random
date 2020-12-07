
###
# Doing some simulation.
###

defmodule Util do
  def abs_sum({x, y, z}) do
    Kernel.abs(x) + Kernel.abs(y) + Kernel.abs(z)
  end

  def vec_add({ax, ay, az}, {bx, by, bz}) do
    {ax+bx, ay+by, az+bz}
  end

  def sign(0) do 0 end
  def sign(delta) when delta > 0 do +1 end
  def sign(delta) when delta < 0 do -1 end

  def lcm(0, 0) do 0 end
  def lcm(a, b) do 
    floor((a*b)/Integer.gcd(a,b))
  end

  # found online
  def transpose(rows) do
    rows
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end

  # I'd use itertools for this, thanks to rosettacode.
  def combinations(_, 0), do: [[]] 
  def combinations([], _), do: [] 
  def combinations([h|t], m) do 
      (for l <- combinations(t, m-1), do: [h|l]) ++ combinations(t, m) 
  end 
end

defmodule Moon do
  defstruct [:name, :pos, :vel]
  def new(name, pos) do
    %Moon{
      name: name,
      pos: pos,
      vel: {0, 0, 0},
    }
  end

  def pot(m) do
    Util.abs_sum(m.pos)
  end
  def kin(m) do
    Util.abs_sum(m.vel)
  end
  def total_energy(m) do
    pot(m) * kin(m)
  end

  def gravity_vec(m, o) do
    {mx, my, mz} = m.pos
    {ox, oy, oz} = o.pos
    {gravity_elem(ox-mx), gravity_elem(oy-my), gravity_elem(oz-mz)}
  end
  defp gravity_elem(0) do 0 end
  defp gravity_elem(delta) when delta > 0 do +1 end
  defp gravity_elem(delta) when delta < 0 do -1 end
end

defmodule MoonAxis do

  def new([pa, pb, pc, pd]) do
    {{pa, pb, pc, pd}, {0, 0, 0, 0}}
  end

  def step({{pa, pb, pc, pd}, {va, vb, vc, vd}}) do
    # broke this out a little, not sure if it helps
    va = va + grav(pa, [pb, pc, pd])
    vb = vb + grav(pb, [pa, pc, pd])
    vc = vc + grav(pc, [pa, pb, pd])
    vd = vd + grav(pd, [pa, pb, pc])
    {{pa+va, pb+vb, pc+vc, pd+vd}, {va, vb, vc, vd}}
  end
  defp grav(p, others) do
    others |> Enum.map(fn o -> Util.sign(o-p) end) |> Enum.sum
  end

end

defmodule Problem do

  def step(moons) do step(moons, 1) end
  def step(moons, 0) do [] end
  def step(moons, steps_remaining) do
    # "After #{iter_count} steps: " |> IO.write
    # moons |> IO.inspect
    new_moons = move_moons(moons)
    [new_moons|step(new_moons, steps_remaining-1)]
  end

  def step2(axis) do
    step2(axis, 0, MapSet.new |> MapSet.put(axis))
  end
  def step2(axis, step_count, visited) do
    if step_count > 0 and Integer.mod(step_count, 100) == 0 do
      step_count |> IO.inspect
    end

    if step_count > 0 and MapSet.member?(visited, axis) do
      step_count
    else
      new_axis = axis |> MoonAxis.step
      step2(new_axis, step_count+1, MapSet.put(visited, axis))
    end
  end
  
  def move_moons(moons) do
    for m <- moons do
      vel = for o <- moons, m.name != o.name do
        m |> Moon.gravity_vec(o)
      end 
      |> Enum.reduce(m.vel, &Util.vec_add/2)  # add to the original velocity
      %{m|
        pos: m.pos |> Util.vec_add(vel),
        vel: vel
      }
    end
  end

  def part1(rows, steps) do
    names = [:io, :eu, :gm, :ca]
    moons = for {name, v} <- Enum.zip(names, rows) do Moon.new(name, v) end
    |> IO.inspect

    step(moons, steps) 
    |> Enum.at(-1)
    |> Enum.map(&Moon.total_energy/1)
    |> Enum.sum
  end

  def part2(rows) do
    
    # yuck.  is there a better way to transpose this thing?
    [xs, ys, zs] = 0..2 
    |> Enum.map(fn i -> for r <- rows do r |> Tuple.to_list |> Enum.at(i) end end)
    |> IO.inspect
    
    [xs, ys, zs] = Util.transpose(rows)
    xcycle = xs |> MoonAxis.new |> step2 |> IO.inspect
    ycycle = ys |> MoonAxis.new |> step2 |> IO.inspect
    zcycle = zs |> MoonAxis.new |> step2 |> IO.inspect
    xcycle |> Util.lcm(ycycle) |> Util.lcm(zcycle)

  end

end

defmodule Tests do 
  use ExUnit.Case

  test "example 1" do
    rows = [
      {-1, 0, 2},
      {2, -10, -7},
      {4, -8, 8},
      {3, 5, -1},
    ]
    assert 179 == rows |> Problem.part1(10)
    assert 2772 == rows |> Problem.part2
  end

  test "example 2" do
    rows = [
      {-8, -10, 0},
      {5, 5, 10},
      {2, -7, 3},
      {9, -8, -3},
    ]
    assert 1940 == rows |> Problem.part1(100)
    # assert 4686774924 == rows |> Problem.part2
  end

  test "go time" do
    rows = [
      {14, 9, 14},
      {9, 11, 6},
      {-6, 14, -4},
      {4, -4, -3}
    ]
    assert 9999 == rows |> Problem.part1(1000)
  end

end
