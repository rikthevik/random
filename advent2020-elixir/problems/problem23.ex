

alias Dlist.DoublyLinkedList, as: DLL

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
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
    |> IO.inspect
  end

  def finish(cups) do
    # find 1 and show everything after
    cups
  end
  
  def part1(cups, times) do

    {:ok, dll} = DLL.new
    for c <- cups do
      dll |> DLL.append(c)
    end

    result = play1(dll, times, Enum.max(cups))
    |> IO.inspect
    {left, [1|right]} = Enum.split_while(result, fn a -> 1 != a end)
    (right ++ left)
    |> Enum.join("")
  end

  def insert_on_match([c|rest], c, to_insert) do
    # "insert_on_match1 c=#{c} rest=#{inspect rest} to_insert=#{inspect to_insert}" |> IO.puts
    [c|to_insert] ++ rest
  end
  def insert_on_match([not_c|rest], c, to_insert) do
    # "insert_on_match2 c=#{c} rest=#{inspect rest} not_c=#{not_c} to_insert=#{inspect to_insert}" |> IO.puts
    [not_c|insert_on_match(rest, c, to_insert)]
  end


  def play1(cups, 0, _) do cups end
  def play1(cups, times, max_val) do

    c = cups |> DLL.first
    pickup = for i <- 0..2 do cups |> DLL.first end

    rest = 12
    "c=#{c} #{inspect pickup}" |> IO.inspect

    1=0

    if Integer.mod(times, 1000) == 0 do
      "times: #{times}" |> IO.puts
    end
    # "cups: (#{c}) #{inspect cups}" |> IO.puts
    # "pick up: #{inspect pickup}" |> IO.puts
    dest = prefind_dest(c-1, pickup, max_val)
    # "destination: #{dest}" |> IO.puts
    
    newcups = rest 
    |> insert_on_match(dest, pickup)
    
    # "newcups = #{inspect newcups}\n" |> IO.puts
    play1(newcups ++ [c], times-1, max_val)
  end

  def prefind_dest(c, pickup, max_val) do
    # "prefind_dest c=#{c} pickup=#{inspect pickup}" |> IO.puts
    find_dest(c, pickup, max_val)
  end
  def find_dest(0, pickup, max_val) do
    # "2 find_dest" |> IO.puts
    prefind_dest(max_val, pickup, max_val)
  end
  def find_dest(c, pickup, max_val) do
    if Enum.member?(pickup, c) do
      # "1 find_dest" |> IO.puts
      prefind_dest(c-1, pickup, max_val)
    else
      c
    end
  end

  def part2(cups, times) do
    max_val = cups |> Enum.max
    result = play1(cups ++ Enum.to_list(max_val..1_000_000), times, max_val)
    {left, [1, a, b|right]} = Enum.split_while(result, fn a -> 1 != a end)
    a * b
  end


end



defmodule Tests do 
  use ExUnit.Case

  @tag :example
  test "example1" do
    inputstr = "389125467"
    assert "92658374" == inputstr |> Problem.load |> Problem.part1(10)
    assert "67384529" == inputstr |> Problem.load |> Problem.part1(100)
  end

  test "go time" do
    inputstr = "368195742"
    assert "95648732" == inputstr |> Problem.load |> Problem.part1(100)
    assert 149245887792 == inputstr |> Problem.load |> Problem.part2(10_000_000)
  end

 end
