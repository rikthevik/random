
defmodule Util do
  def pairs(l) do
    for {a, i} <- Enum.with_index(l), {b, j} <- Enum.with_index(l), i != j do
      {a, b}
    end
  end
end

# stolen from
#  https://elixir-lang.org/getting-started/processes.html#state
defmodule KV do
  def start_link do
    Task.start_link(fn -> loop(%{}) end)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        send caller, Map.get(map, key)
        loop(map)
      {:put, key, value} ->
        # "SET F(#{key})=#{value}" |> IO.puts
        loop(Map.put(map, key, value))
    end
  end
end

defmodule Problem do

  def load_line(line) do
    line |> String.trim |> String.to_integer
  end

  def load(inputstr) do
    inputstr
    |> String.split("\n")
    |> Enum.map(&load_line/1)
  end

  def part1(ints) do
    ints = [0] ++ Enum.sort(ints) ++ [Enum.max(ints)+3]
    diffs = ints
    |> Enum.slice(0, Enum.count(ints)-1)
    |> Enum.zip(Enum.slice(ints, 1, Enum.count(ints)-1))
    |> Enum.map(fn {a, b} -> b-a end)

    ones = Enum.filter(diffs, fn d -> d == 1 end) |> Enum.count
    threes = Enum.filter(diffs, fn d -> d == 3 end) |> Enum.count
    ones * threes
  end 

  def part2(ints) do
    ints = [0] ++ Enum.sort(ints) ++ [Enum.max(ints)+3]
    |> IO.inspect
    # i think we can memoize and reuse a bunch of previous work

    {:ok, pid} = KV.start_link
    Process.register(pid, :memo)

    intmap = Enum.zip(0..Enum.count(ints), ints) |> Map.new
    traverse(intmap, 0)
    |> IO.inspect
    
  end

  def traverse(intmap, idx) do
    # if we've seen it before, return it
    # if we haven't seen it, 
    #  figure out the paths from this point
    #  set the result in the memo

    # for _ <- 0..memo do IO.write(" ") end
    # "F(#{idx})" |> IO.puts

    send :memo, {:get, idx, self()}
    received = receive do v -> v end

    if received != nil do
      # "memo(#{idx}) => #{received}" |> IO.puts 
      received
    else
      val = Map.get(intmap, idx)

      idx_to_traverse = 1..3
      |> Enum.filter(fn (i) ->
        diff = Map.get(intmap, idx+i, -9999) - val
        1 <= diff and diff <= 3
      end)
  
      result = idx_to_traverse
      |> Enum.map(fn i ->
        traverse(intmap, idx+i)
      end)
      |> Enum.sum
      
      result = if result == 0, do: 1, else: result

      # "set f(#{idx})=#{result}" |> IO.puts
      send :memo, {:put, idx, result}

      result
    end
  end
end

defmodule Tests do 
  use ExUnit.Case
  
  @tag :simple
  test "examples" do
    inputstr = "16
    10
    15
    5
    1
    11
    7
    19
    6
    12
    4"
    assert 35 == inputstr |> Problem.load |> Problem.part1
    assert 8 == inputstr |> Problem.load |> Problem.part2
  end

  test "example2" do
    inputstr = "28
    33
    18
    42
    31
    14
    46
    20
    48
    47
    24
    23
    49
    45
    19
    38
    39
    11
    1
    32
    25
    35
    8
    17
    7
    9
    4
    2
    34
    10
    3"
    assert 220 == inputstr |> Problem.load |> Problem.part1
    assert 19208 == inputstr |> Problem.load |> Problem.part2
  end

  test "go time" do
    inputstr = "59
    134
    159
    125
    95
    92
    169
    43
    154
    46
    110
    79
    117
    151
    141
    56
    87
    10
    65
    170
    89
    32
    40
    118
    36
    94
    124
    173
    164
    166
    113
    67
    76
    102
    107
    52
    144
    119
    2
    72
    86
    73
    66
    13
    15
    38
    47
    109
    103
    128
    165
    148
    116
    146
    18
    135
    68
    83
    133
    171
    145
    48
    31
    106
    161
    6
    21
    22
    77
    172
    28
    78
    96
    55
    132
    39
    100
    108
    33
    23
    54
    157
    80
    153
    9
    62
    26
    147
    1
    27
    131
    88
    138
    93
    14
    123
    122
    158
    152
    71
    49
    101
    37
    99
    160
    53
    3"
    assert 2516 == inputstr |> Problem.load |> Problem.part1
    assert 19208 == inputstr |> Problem.load |> Problem.part2    
  end

end
