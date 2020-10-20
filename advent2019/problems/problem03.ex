
input = """
R75,D30,R83,U83,L12,D49,R71,U7,L72
U62,R66,U55,R34,D71,R55,D58,R83
"""


defmodule Point do
  # Rediscovering structs!
  defstruct [:x, :y]
  def new(x, y) do
    %Point{x: x, y: y}
  end

  def mdist(p) do
    p.x + p.y
  end

  def add(a, b) do
    %Point{x: a.x + b.x, y: a.y + b.y}
  end
end

defmodule Line do
  # Is there a better way to name these fields?
  defstruct [:p1, :p2]
  
  def new(p1, p2) do
    # Would it be a good idea to sort these by something?
    %Line{p1: p1, p2: p2}
  end

  def slope(l) do
    if l.p1.x == l.p2.x do
        :infinity
    else
        (l.p1.y - l.p2.y) / (l.p1.x - l.p2.x)
    end
  end
end

defmodule Problem do

  def parse_line(line) do
    line 
    |> String.split(",")
    |> Enum.map(&parse_chunk/1)    
  end

  def parse_chunk(chunk) do
    dir = chunk |> String.at(0) |> String.downcase() |> String.to_atom()
    length = chunk |> String.slice(1..100) |> String.to_integer()
    case dir do
      :u -> Point.new(0, +length)
      :d -> Point.new(0, -length)
      :l -> Point.new(-length, 0)
      :r -> Point.new(+length, 0)
    end
  end

  def wire_to_lines(wire) do
    step(Point.new(0, 0), wire)
  end

  def step(p, [next|rest]) do
    # today we are fancy recursive people
    continued = p |> Point.add(next)
    [Line.new(p, continued) | step(continued, rest)]
  end
  def step(p, []) do
    []
  end

  def run(inputs) do
    "INPUT" |> IO.puts
    inputs |> IO.inspect
    wire1 = inputs |> Enum.at(0)
    wire2 = inputs |> Enum.at(1)

    # here = Point.new(0.0, 0.0)
  end

  def suite(input) do 
    input
    |> String.trim 
    |> String.split 
    |> Enum.map(&parse_line/1)
    |> Problem.run
  end

end

defmodule Tests do 
  use ExUnit.Case
  test "points do point things" do
    p = Point.new(1, 3)
    assert p.x == 1.0
    assert p.y == 3.0
    assert p |> Point.add(Point.new(2, 1)) == Point.new(3, 4)
  end

  test "lines do line things" do
    l = Line.new(Point.new(0, 0), Point.new(2, 4))
    assert l |> Line.slope() == 2
  end

  test "parse chunk" do
    assert "R123" |> Problem.parse_chunk() == Point.new(123, 0)
  end

  test "parse line" do
    assert "R123,U23" |> Problem.parse_line() == [Point.new(123, 0), Point.new(0, 23)]
  end

  test "wire to lines" do 
    wire = [Point.new(123, 0), Point.new(0, 23)]
    assert wire |> Problem.wire_to_lines() == [
      Line.new(Point.new(0, 0), Point.new(123, 0)),
      Line.new(Point.new(123, 0), Point.new(123, 23)),
    ]
  end

  # test "sample input 1" do
  #   input = "R8,U5,L5,D3\nU7,R6,D4,L4"
  #   assert input |> Problem.suite() == 6
  # end



end


