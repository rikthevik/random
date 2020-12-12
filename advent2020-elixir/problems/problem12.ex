
defmodule Util do
  
end

defmodule Problem do
  defstruct [:x, :y, :dir]

  def load_line(line) do
    line = line |> String.trim
    {line |> String.at(0), line |> String.slice(1..String.length(line)) |> String.to_integer}
  end

  def load(inputstr) do
    lines = inputstr
    |> String.split("\n")
    |> Enum.map(&load_line/1)
  end

  def instruction(prob, {"N", c}) do %{prob| y: prob.y+c} end
  def instruction(prob, {"S", c}) do %{prob| y: prob.y-c} end
  def instruction(prob, {"E", c}) do %{prob| x: prob.x+c} end
  def instruction(prob, {"W", c}) do %{prob| x: prob.x-c} end
  def instruction(prob, {"L", c}) do add_dir(prob, +c) end
  def instruction(prob, {"R", c}) do add_dir(prob, -c) end
  def instruction(prob, {"F", c}) do
    instruction(prob, {compass_for_dir(prob.dir), c})
  end

  def add_dir(prob, delta) do
    %{prob| dir: Integer.mod(prob.dir + delta + 360, 360)}
  end
  def compass_for_dir(0), do: "E"
  def compass_for_dir(90), do: "N"
  def compass_for_dir(180), do: "W"
  def compass_for_dir(270), do: "S"
  
  def process_rows(prob, []) do prob end
  def process_rows(prob, [inst|rows]) do
    newprob = instruction(prob, inst)
    # |> IO.inspect
    process_rows(newprob, rows)
  end

  def part1(rows) do

    prob = %Problem{x: 0, y: 0, dir: 0}
    prob2 = process_rows(prob, rows)
    Kernel.abs(prob2.x) + Kernel.abs(prob2.y)

  end
end


defmodule Problem2 do
  defstruct [:sx, :sy, :wx, :wy]

  def instruction(prob, {"N", c}) do %{prob| wy: prob.wy+c} end
  def instruction(prob, {"S", c}) do %{prob| wy: prob.wy-c} end
  def instruction(prob, {"E", c}) do %{prob| wx: prob.wx+c} end
  def instruction(prob, {"W", c}) do %{prob| wx: prob.wx-c} end
  def instruction(prob, {"L", deg}) do rotate_waypoint(prob, deg) end
  def instruction(prob, {"R", deg}) do rotate_waypoint(prob, -deg) end
  def instruction(prob, {"F", c}) do
    %{prob|
      sx: prob.sx + prob.wx * c,
      sy: prob.sy + prob.wy * c,
    }
  end

  def clamp(deg) when deg < 0 do clamp(deg+360) end
  def clamp(deg) when deg >= 360 do Integer.mod(deg, 360) end
  def clamp(deg) do deg end

  def cos(deg) do cos2(clamp(deg)) end
  def cos2(0) do 1 end
  def cos2(90) do 0 end
  def cos2(180) do -1 end
  def cos2(270) do 0 end

  def sin(deg) do sin2(clamp(deg)) end
  def sin2(0) do 0 end
  def sin2(90) do 1 end
  def sin2(180) do 0 end
  def sin2(270) do -1 end

  def rotate_waypoint(prob, deg) do
    newx = prob.wx * cos(deg) - prob.wy * sin(deg)
    newy = prob.wx * sin(deg) + prob.wy * cos(deg)
    # "rotate #{prob.wx} #{prob.wy} : #{deg} => #{newx} #{newy}" |> IO.inspect
    %{prob|
      wx: newx,
      wy: newy
    }
  end

  def process_rows(prob, []) do prob end
  def process_rows(prob, [inst|rows]) do
    newprob = instruction(prob, inst)
    # |> IO.inspect
    process_rows(newprob, rows)
  end

  def part2(rows) do
    prob = %Problem2{sx: 0, sy: 0, wx: 10, wy: 1}
    prob2 = process_rows(prob, rows)
    Kernel.abs(prob2.sx) + Kernel.abs(prob2.sy)
  end
end


defmodule Tests do 
  use ExUnit.Case
  
  def get_waypoint(p) do {p.wx, p.wy} end

  @tag :functions
  test "functions" do
    assert -1 == Problem2.sin(-90)
    assert 0 == Problem2.sin(-180)
    assert +1 == Problem2.sin(-270)
    assert 0 == Problem2.sin(-360)
    assert 0 == Problem2.sin(0)
    assert +1 == Problem2.sin(90)
    assert 0 == Problem2.sin(180)
    assert -1 == Problem2.sin(270)
    assert 0 == Problem2.sin(360)
    assert +1 == Problem2.sin(450)
    assert -1 == Problem2.sin(-90)
    assert 0 == Problem2.sin(-180)

    assert 0 == Problem2.cos(-90)
    assert -1 == Problem2.cos(-180)
    assert 0 == Problem2.cos(-270)
    assert +1 == Problem2.cos(-360)
    assert +1 == Problem2.cos(0)
    assert 0 == Problem2.cos(90)
    assert -1 == Problem2.cos(180)
    assert 0 == Problem2.cos(270)
    assert +1 == Problem2.cos(360)
    assert 0 == Problem2.cos(450)

    p = %{wx: 2, wy: 1}
    assert {-1, 2} == Problem2.rotate_waypoint(p, 90) |> get_waypoint
    assert {-2, -1} == Problem2.rotate_waypoint(p, 180) |> get_waypoint
    assert {1, -2} == Problem2.rotate_waypoint(p, 270) |> get_waypoint
    assert {2, 1} == Problem2.rotate_waypoint(p, 360) |> get_waypoint
  end

  test "examples" do
    inputstr = "F10
    N3
    N1
    S1
    E1
    W1
    R90
    R90
    R90
    R90
    L90
    L90
    L90
    L90
    F7
    R90
    L90
    R90
    L270
    R270
    F11"
    assert 25 == inputstr |> Problem.load |> Problem.part1
    assert 286 == inputstr |> Problem.load |> Problem2.part2
  end

  test "go time" do
    inputstr = "W5
    F91
    S3
    R90
    F98
    S3
    E1
    F51
    E3
    S5
    E4
    N2
    R180
    N3
    F25
    N1
    W4
    R90
    S1
    E1
    F18
    W2
    F13
    W5
    R180
    S5
    L90
    W1
    F23
    L270
    F7
    R180
    E2
    R90
    E4
    S3
    L90
    W2
    R90
    F47
    R90
    W5
    L270
    F8
    E2
    F72
    W3
    N4
    E1
    S2
    R90
    F8
    S1
    L270
    F59
    L90
    F100
    L90
    W1
    R90
    F73
    E5
    R180
    E2
    N4
    E3
    N3
    E1
    F42
    W3
    S3
    L180
    F8
    W5
    R180
    R180
    F88
    W3
    F49
    W3
    S1
    R270
    N1
    F63
    W1
    F87
    W3
    S4
    L90
    E2
    N5
    F12
    E3
    F32
    W3
    R180
    L90
    S2
    L180
    N4
    F41
    S2
    R180
    S3
    E3
    N1
    L270
    E3
    F33
    R90
    F94
    R270
    S5
    E3
    F75
    S3
    R180
    W2
    N4
    W4
    R90
    F61
    N3
    F33
    E5
    R180
    S3
    F39
    N5
    R90
    R180
    W3
    F67
    L90
    R90
    F83
    E3
    S2
    L270
    W2
    F13
    S5
    E5
    L90
    N2
    W5
    N4
    F68
    N1
    F95
    W1
    F56
    S1
    F55
    L90
    F85
    W5
    L90
    F25
    E3
    S3
    W3
    N3
    W5
    F27
    L90
    E5
    N2
    F62
    R180
    S3
    E4
    R90
    F31
    S2
    F24
    R180
    F20
    S2
    F26
    R90
    F55
    W1
    R90
    N3
    F53
    L180
    W4
    N3
    E3
    R90
    S2
    R90
    R90
    S5
    W1
    W3
    F100
    R90
    F27
    E2
    R90
    N5
    R90
    S1
    L90
    S3
    E5
    S5
    F23
    S5
    W2
    S5
    R180
    E5
    F79
    R90
    S5
    E3
    F68
    E3
    N1
    W4
    R90
    F46
    W3
    R90
    F31
    W2
    N4
    R90
    F33
    E4
    S2
    R180
    F69
    E2
    N5
    E4
    N1
    F30
    L90
    E2
    F40
    W4
    F27
    W2
    N3
    F30
    E3
    N1
    R90
    N2
    W3
    R90
    W2
    S5
    W3
    F77
    S3
    W2
    F86
    L90
    N3
    F45
    R180
    F58
    R90
    F75
    N2
    E1
    N1
    E4
    R90
    S4
    S2
    R180
    E4
    S4
    R180
    F16
    W1
    L180
    E5
    F10
    N5
    E3
    S1
    W1
    F36
    S4
    S3
    F28
    N3
    F21
    S5
    W4
    F78
    W4
    R180
    F93
    E5
    F47
    R90
    W2
    S1
    F52
    R270
    W5
    F24
    N5
    S3
    E2
    L270
    L90
    N4
    R90
    E1
    N1
    F73
    N4
    F67
    W4
    R90
    E5
    F8
    W3
    F5
    S5
    E4
    N5
    R180
    N2
    F46
    L90
    F69
    W5
    R90
    W3
    N3
    L180
    F78
    W1
    F47
    F9
    N4
    F76
    N4
    F2
    L90
    S1
    F61
    L90
    E1
    R90
    W2
    F75
    R90
    W1
    N3
    R90
    F22
    N2
    E5
    L180
    E2
    F20
    E4
    F29
    R90
    S5
    E1
    R90
    S3
    F51
    S1
    R90
    E2
    F15
    R90
    S2
    R180
    F18
    W3
    L90
    N4
    F20
    S1
    R90
    S2
    F30
    W4
    S2
    W2
    F52
    E4
    F76
    W5
    R90
    F2
    L180
    F82
    E1
    R180
    F94
    E4
    N1
    F78
    N1
    W2
    L90
    E1
    F14
    W1
    F50
    E5
    L90
    E4
    N5
    E3
    F51
    L90
    F91
    S2
    L90
    W4
    F46
    N1
    F52
    R90
    F91
    W5
    S4
    W3
    R90
    W3
    F94
    R90
    S3
    W3
    R90
    F88
    E5
    F15
    L90
    F46
    R90
    S5
    E5
    S3
    L180
    S1
    F29
    R270
    F13
    S4
    W2
    R90
    F40
    N3
    F85
    S3
    F18
    N3
    R180
    S5
    E1
    S5
    R90
    W1
    L90
    F94
    R270
    E5
    S1
    L270
    W5
    F78
    S5
    E1
    N3
    F98
    N1
    E2
    W3
    F80
    N4
    E1
    F78
    S1
    L270
    E4
    R90
    F15
    W4
    R90
    E5
    F53
    N1
    W4
    F19
    E1
    S2
    F21
    N2
    W2
    F2
    E4
    F27
    W5
    R180
    F85
    R180
    F40
    W3
    N1
    F52
    E2
    F77
    L180
    E1
    N3
    R90
    F55
    N2
    R90
    E5
    S3
    L90
    F88
    N3
    W5
    R90
    S3
    F85
    F52
    L90
    W3
    R270
    S5
    F34
    N2
    W1
    F65
    W2
    N4
    L180
    N1
    F73
    E2
    N5
    E3
    S4
    R90
    W4
    N5
    F24
    N3
    L90
    N4
    F99
    E2
    N2
    L180
    W3
    S4
    W5
    N2
    L180
    F66
    R90
    W1
    R180
    F100
    S2
    E4
    R90
    W4
    F51
    S1
    W2
    F26
    N3
    N1
    E2
    S2
    F11
    R90
    F25
    E4
    F78
    N2
    N2
    R180
    F68
    N3
    R180
    W4
    F21
    E2
    N2
    E5
    S5
    E3
    F23
    R90
    F30
    W5
    F3
    L90
    F82
    N4
    W5
    S3
    E2
    N4
    F4
    S2
    R90
    W3
    R90
    F14
    W4
    F14
    W4
    F92
    S1
    W4
    S5
    S3
    F77
    S1
    F45
    N1
    L180
    E5
    F86
    L90
    E4
    F12
    S1
    E3
    F46
    W1
    L90
    F20
    S4
    F89
    N2
    S2
    F18
    E4
    F37
    S4
    F48
    W4
    L180
    F93
    R90
    W5
    L90
    S1
    E4
    L90
    S4
    E4
    S5
    E4
    L90
    E5
    R180
    N4
    R90
    W2
    F44
    S1
    L180
    F15
    W2
    F84
    S5
    L90
    N5
    W4
    R180
    F11
    R90
    F47
    S4
    R180
    S4
    F48
    L90
    W4
    L90
    S2
    F22
    E3
    F85
    N4
    F53
    R90
    F65
    L90
    S3
    R90
    F80
    R90
    F40
    R90
    F9
    L180
    W5
    N5
    W1
    S4
    F87
    S5
    F43
    S3
    L90
    E5
    R180
    S4
    W2
    N3
    N3
    F98
    E2
    R90
    W5
    F4
    L90
    E4
    F48
    S5
    F81
    E3
    S3
    L90
    S2
    F62
    E1
    F17
    S3
    F95
    N3
    W5
    E2
    R90
    R180
    W5
    L90
    W3
    F31
    S3
    W3
    S4
    L90
    W5
    R90
    W4
    S3
    L90
    S2
    F11
    S4
    F93"
    assert 759 == inputstr |> Problem.load |> Problem.part1
    assert 45763 == inputstr |> Problem.load |> Problem2.part2
  end


end
