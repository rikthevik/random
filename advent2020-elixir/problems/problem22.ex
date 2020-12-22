

defmodule Util do
  
end

# stolen from
#  https://elixir-lang.org/getting-started/processes.html#state
defmodule Global do
  def start_link() do
    {:ok, pid} = Task.start_link(fn -> loop(%{}) end)
    Process.register(pid, :global)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        retval = Map.get(map, key)
        "GET F(#{inspect key}) => #{inspect retval}" |> IO.puts
        send caller, retval
        loop(map)
      {:all, caller} ->
        send caller, map
        loop(map)
      {:put, key, value} ->
        "SET F(#{inspect key}) := #{inspect value}" |> IO.puts
        loop(Map.put(map, key, value))
    end
  end

  def put(k, v) do
    send :global, {:put, k, v}
  end

  def get(k) do
    send :global, {:get, k, self()}
    receive do v -> v end
  end

  def all() do
    send :global, {:all, self()}
    receive do v -> v end
  end
end


defmodule Problem do

  def load(inputstr) do
    inputstr 
    |> String.trim
    |> String.split(~r/ *\n * \n */)
    |> Enum.map(&load_deck/1)
    |> IO.inspect
  end

  def load_deck(rowstr) do
    [_header|cards] = rowstr 
    |> String.split(~r/ *\n */)
    
    cards
    |> Enum.map(&String.to_integer/1)
  end
    
  def calc_score(deck) do
    deck
    |> Enum.reverse
    |> Enum.with_index
    |> Enum.map(fn {c, idx} -> c * (idx+1) end)
    |> Enum.sum
  end

  def play1([], p2) do p2 end
  def play1(p1, []) do p1 end
  def play1([c|_p1], [c|_p2]) do raise "wat" end  # should never happen
  def play1([hi|p1], [lo|p2]) when hi > lo do
    play1(p1 ++ [hi, lo], p2)  # this is O(n) and may need a deque
  end
  def play1([lo|p1], [hi|p2]) when hi > lo do
    play1(p1, p2 ++ [hi, lo])
  end

  def part1([p1, p2]) do
    play1(p1, p2)
    |> calc_score
  end

  def part2([p1, p2]) do
    {_winner, result} = game(p1, p2)
    result
    |> calc_score
  end

  def game(p1, p2) do
    "game(#{inspect p1}, #{inspect p2})" |> IO.puts
    preround(p1, p2, MapSet.new)
  end

  def preround(p1, p2, visited) do
    if MapSet.member?(visited, {p1, p2}) do
      {:p1, nil}
    else
      round(p1, p2, MapSet.put(visited, {p1, p2}))
    end
  end

  def round([], [], visited) do raise "wat2" end
  def round(winner, [], visited) do {:p1, winner} end
  def round([], winner, visited) do {:p2, winner} end
  def round([c1|p1], [c2|p2], visited) do
    if c1 <= Enum.count(p1) and c2 <= Enum.count(p2) do
      "1 #{c1} #{c2}" |> IO.puts
      case game(Enum.slice(p1, 0, c1), Enum.slice(p2, 0, c2)) do
        {:p1, _} -> preround(p1 ++ [c1, c2], p2, visited)
        {:p2, _} -> preround(p1, p2 ++ [c2, c1], visited)
      end
    else
      "2 #{c1} #{c2}" |> IO.puts
      if c1 > c2 do
        preround(p1 ++ [c1, c2], p2, visited)
      else
        preround(p1, p2 ++ [c2, c1], visited)
      end
    end
  end


end



defmodule Tests do 
  use ExUnit.Case

  @tag :example
  test "example1" do
    inputstr = "Player 1:
    9
    2
    6
    3
    1
    
    Player 2:
    5
    8
    4
    7
    10"
    assert 306 == inputstr |> Problem.load |> Problem.part1
    assert 291 == inputstr |> Problem.load |> Problem.part2
  end

  test "gotime" do
    inputstr = "Player 1:
    45
    10
    43
    46
    25
    36
    16
    38
    30
    15
    26
    34
    9
    2
    44
    1
    4
    40
    5
    24
    49
    3
    41
    19
    13
    
    Player 2:
    28
    50
    37
    20
    6
    42
    32
    47
    39
    22
    14
    7
    21
    17
    27
    8
    48
    11
    23
    12
    18
    35
    29
    33
    31"
    assert 33400 == inputstr |> Problem.load |> Problem.part1
    assert 33400 == inputstr |> Problem.load |> Problem.part2
  end
 
 end
