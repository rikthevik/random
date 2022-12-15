
defmodule Util do
  def dist({x1, y1}, {x2, y2}) do
    abs(x2-x1) + abs(y2-y1)
  end
  def add({x, y}, {dx, dy}) do
    {x+dx, y+dy}
  end
end

defmodule Sensor do
  defstruct [:s, :b, :rad]
  def new([sx, sy, bx, by]) do
    %Sensor{
      s: {sx, sy},
      b: {bx, by},
      rad: Util.dist({sx, sy}, {bx, by}),
    }
  end
  def extremities(sensor) do
    [{+sensor.rad, 0}, {-sensor.rad, 0}, {0, +sensor.rad}, {0, -sensor.rad}]
    |> Enum.map(&(Util.add(sensor.s, &1)))
  end
  def contains?(sensor, p) do
    Util.dist(sensor.s, p) <= sensor.rad
  end
end

defmodule Part1 do
  def run(sensors, yval) do
    sensors
    |> IO.inspect()

    {xmin, xmax} = sensors
    |> Enum.map(&Sensor.extremities/1)
    |> Enum.concat()
    |> Enum.map(fn {x, _y} -> x end)
    |> Enum.min_max()
    |> IO.inspect()

    beacon_map = sensors
    |> Enum.map(fn s -> s.b end)
    |> MapSet.new()

    xmin..xmax
    |> Enum.map(fn x -> {x, yval} end)
    |> Enum.filter(fn p ->
        sensors
        |> Stream.map(fn s -> Sensor.contains?(s, p) end)
        |> Enum.any?()
    end)
    |> IO.inspect()
    |> Enum.filter(fn p -> not MapSet.member?(beacon_map, p) end)
    |> IO.inspect()
    |> length()

  end
end

defmodule Part2 do
  def run(rows) do
    rows
    |> IO.inspect()
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s |> IO.inspect()

    [_match|captures] = ~r/Sensor at x=([-\d]+), y=([-\d]+): closest beacon is at x=([-\d]+), y=([-\d]+)/
    |> Regex.run(s)

    captures
    |> IO.inspect()
    |> Enum.map(&String.to_integer/1)
    |> Sensor.new()
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "Sensor at x=2, y=18: closest beacon is at x=-2, y=15
    Sensor at x=9, y=16: closest beacon is at x=10, y=16
    Sensor at x=13, y=2: closest beacon is at x=15, y=3
    Sensor at x=12, y=14: closest beacon is at x=10, y=16
    Sensor at x=10, y=20: closest beacon is at x=10, y=16
    Sensor at x=14, y=17: closest beacon is at x=10, y=16
    Sensor at x=8, y=7: closest beacon is at x=2, y=10
    Sensor at x=2, y=0: closest beacon is at x=2, y=10
    Sensor at x=0, y=11: closest beacon is at x=2, y=10
    Sensor at x=20, y=14: closest beacon is at x=25, y=17
    Sensor at x=17, y=20: closest beacon is at x=21, y=22
    Sensor at x=16, y=7: closest beacon is at x=15, y=3
    Sensor at x=14, y=3: closest beacon is at x=15, y=3
    Sensor at x=20, y=1: closest beacon is at x=15, y=3"
    assert 26 == input |> prepare |> Part1.run(10)
  end

  test "go time" do
    input = "122"
    # assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end
end
