
###
# Doing some simulation.
###

defmodule Util do
  def abs_sum({x, y, z}) do
    Kernel.abs(x) + Kernel.abs(y) + Kernel.abs(z)
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
    Util.abs_sum(m.vec)
  end
  def total_energy(m) do
    pot(m) * kin(m)
  end
end

defmodule Problem do

  def step(moons, iter_count) when iter_count > 10 do [] end
  def step(moons, iter_count) do
    
    new_moons = moons
    "After #{iter_count} steps: " |> IO.write
    new_moons |> IO.inspect

    [moons|step(new_moons, iter_count+1)]
  end


  def part1(rows) do
    names = [:io, :eu, :gm, :ca]
    moons = for {name, v} <- Enum.zip(names, rows) do Moon.new(name, v) end
    |> IO.inspect

    step(moons, 1)
    
  end

  

  def part2(rows) do
    
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
    rows |> Problem.part1

  end

end
