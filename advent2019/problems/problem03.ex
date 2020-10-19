
input = """
123
456
"""


defmodule Point do
  # Rediscovering structs!
  defstruct [:x, :y]

  def mdist(p) do
    p.x + p.y
  end

  def add(a, b) do
    %Point{x: a.x + b.x, y: a.y + b.y}
  end
end

defmodule Line do
  # Is there a better way to name these?
  # Should we 
  defstruct [:p1, :p2]
  
  def new(p1, p2) do
    # Would it be a good idea to sort these by something?
    %Line{p1: p1, p2: p2}
  end

  def slope(l) do
    if l.p1.y == l.p2.y do
        :infinity
    else
        (l.p1.y - l.p2.y) / (l.p1.x - l.p2.x)
  end
  
end

defmodule Problem do

  def parse(line) do
    String.to_integer(line)
  end

  def run(inputs) do
    "INPUT" |> IO.puts
    inputs |> IO.inspect

    IO.puts("")


  end
end

input
  |> String.trim 
  |> String.split 
  |> Enum.map(&Problem.parse/1)
  |> Problem.run
