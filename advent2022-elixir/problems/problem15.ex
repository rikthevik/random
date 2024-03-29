
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
  def edge_points(sensor) do
    rad = sensor.rad + 1
    {sx, sy} = sensor.s |> IO.inspect()
    Enum.concat([
      between(sensor, {-rad, 0}, {+1, +1}),
      between(sensor, {0, +rad}, {+1, -1}),
      between(sensor, {+rad, 0}, {-1, -1}),
      between(sensor, {0, -rad}, {-1, +1}),
    ])
    |> Enum.map(fn {x, y} -> {x + sx, y + sy} end)
  end
  def between(sensor, {x, y}, {dx, dy}) do
    for i <- 0..sensor.rad do {x + dx * i, y + dy * i} end
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
    |> Enum.filter(fn p -> not MapSet.member?(beacon_map, p) end)
    |> length()
  end
end

defmodule Part2 do
  def run(sensors, wmax, hmax) do
    try do
      all_points = sensors
      # |> Enum.take(1)
      |> Stream.map(&Sensor.edge_points/1)
      |> Stream.concat()
      |> Stream.filter(fn {x, y} -> 0 <= x and x <= wmax and 0 <= y and y <= hmax end)
      # |> IO.inspect()

      # 1=0
      for {{x, y}, idx} <- Stream.with_index(all_points) do
        if rem(idx, 1000) == 0 do
          idx |> IO.inspect(label: "working")
        end
        contained_in_any = sensors
          |> Stream.map(fn s -> Sensor.contains?(s, {x, y}) end)
          |> Enum.any?()
        # {{x, y}, contained_in_any} |> IO.inspect()
        if not contained_in_any do
          throw({x, y})
        end
      end
    catch
      {nx, ny} -> nx * 4_000_000 + ny
    end
  end

  def naive(sensors, wmax, hmax) do
    try do
      for y <- 0..hmax do
        for x <- 0..wmax do
          contained_in_any = sensors
            |> Stream.map(fn s -> Sensor.contains?(s, {x, y}) end)
            |> Enum.any?()
          case contained_in_any do
            false -> throw({x, y})
            contained_in_any -> contained_in_any
          end
        end
        IO.puts(y)
      end
    catch
      {nx, ny} -> nx * 4_000_000 + ny
    end
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    [_match|captures] = ~r/Sensor at x=([-\d]+), y=([-\d]+): closest beacon is at x=([-\d]+), y=([-\d]+)/
    |> Regex.run(s)

    captures
    # |> IO.inspect()
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
    # assert 26 == input |> prepare |> Part1.run(10)
    # assert 56000011 == input |> prepare |> Part2.run(20, 20)
  end

  test "go time" do
    input = "Sensor at x=2150774, y=3136587: closest beacon is at x=2561642, y=2914773
    Sensor at x=3983829, y=2469869: closest beacon is at x=3665790, y=2180751
    Sensor at x=2237598, y=3361: closest beacon is at x=1780972, y=230594
    Sensor at x=1872170, y=78941: closest beacon is at x=1780972, y=230594
    Sensor at x=3444410, y=3965835: closest beacon is at x=3516124, y=3802509
    Sensor at x=3231566, y=690357: closest beacon is at x=2765025, y=1851710
    Sensor at x=3277640, y=2292194: closest beacon is at x=3665790, y=2180751
    Sensor at x=135769, y=50772: closest beacon is at x=1780972, y=230594
    Sensor at x=29576, y=1865177: closest beacon is at x=255250, y=2000000
    Sensor at x=3567617, y=3020368: closest beacon is at x=3516124, y=3802509
    Sensor at x=1774477, y=148095: closest beacon is at x=1780972, y=230594
    Sensor at x=1807041, y=359900: closest beacon is at x=1780972, y=230594
    Sensor at x=1699781, y=420687: closest beacon is at x=1780972, y=230594
    Sensor at x=2867703, y=3669544: closest beacon is at x=3516124, y=3802509
    Sensor at x=1448060, y=201395: closest beacon is at x=1780972, y=230594
    Sensor at x=3692914, y=3987880: closest beacon is at x=3516124, y=3802509
    Sensor at x=3536880, y=3916422: closest beacon is at x=3516124, y=3802509
    Sensor at x=2348489, y=2489095: closest beacon is at x=2561642, y=2914773
    Sensor at x=990761, y=2771300: closest beacon is at x=255250, y=2000000
    Sensor at x=1608040, y=280476: closest beacon is at x=1780972, y=230594
    Sensor at x=2206669, y=1386195: closest beacon is at x=2765025, y=1851710
    Sensor at x=3932320, y=3765626: closest beacon is at x=3516124, y=3802509
    Sensor at x=777553, y=1030378: closest beacon is at x=255250, y=2000000
    Sensor at x=1844904, y=279512: closest beacon is at x=1780972, y=230594
    Sensor at x=2003315, y=204713: closest beacon is at x=1780972, y=230594
    Sensor at x=2858315, y=2327227: closest beacon is at x=2765025, y=1851710
    Sensor at x=3924483, y=1797070: closest beacon is at x=3665790, y=2180751
    Sensor at x=1572227, y=3984898: closest beacon is at x=1566446, y=4774401
    Sensor at x=1511706, y=1797308: closest beacon is at x=2765025, y=1851710
    Sensor at x=79663, y=2162372: closest beacon is at x=255250, y=2000000
    Sensor at x=3791701, y=2077777: closest beacon is at x=3665790, y=2180751
    Sensor at x=2172093, y=3779847: closest beacon is at x=2561642, y=2914773
    Sensor at x=2950352, y=2883992: closest beacon is at x=2561642, y=2914773
    Sensor at x=3629602, y=3854760: closest beacon is at x=3516124, y=3802509
    Sensor at x=474030, y=3469506: closest beacon is at x=-452614, y=3558516"
    # assert 4560025 == input |> prepare |> Part1.run(2000000)
    assert 12480406634249 == input |> prepare |> Part2.run(4000000, 4000000)
  end
end
