
use Bitwise

defmodule Util do
  
end

defmodule Problem do
  defstruct [:turn, :mem]
  def new(ints) do
    %Problem{
      turn: Enum.count(ints)+1,
      mem: ints
      |> Enum.with_index
      |> Enum.map(fn {e, idx} -> {e, {idx+1, nil}} end)
      |> Map.new
    }
  end
  def speak(p, int) do
    %{p|
      mem: p.mem |> Map.put(int, if Map.has_key?(p.mem, int) do
        {last, _beforelast} = Map.get(p.mem, int)
        {p.turn, last}
      else
        {p.turn, nil}
      end)      
    }
  end
  def last_spoken(p, int) do
    "last_spoken(#{int}) :: #{inspect p.mem}" |> IO.puts
    Map.get(p.mem, int)
  end
  
  def load(inputstr) do
    inputstr
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part1(ints, max_turn) do
    ints |> IO.inspect
    p1(Problem.new(ints), Enum.at(ints, -1), max_turn)
  end
  
  def p1(%Problem{turn: max_turn}, val, max_turn) do val end
  def p1(p, val, max_turn) do 
    "turn=#{p.turn} val=#{val} #{inspect p}" |> IO.puts
    
    {first_idx, second_idx} = p |> last_spoken(val)
    
    newly_spoken = if second_idx == nil do
      0
    else
      first_idx - second_idx - 1
    end

    # "first=#{first_idx} second=#{second_idx} newly=#{newly_spoken}\n" |> IO.puts
    %{p| turn: p.turn+1}
    |> speak(newly_spoken)
    |> p1(newly_spoken, max_turn)

  end

end



defmodule Tests do 
  use ExUnit.Case

  test "examples" do
    assert 0 == "0,3,6" |> Problem.load |> Problem.part1(10)
    # assert 175594 == "0,3,6" |> Problem.load |> Problem.part1(30000000)
    assert 1 == "1,3,2" |> Problem.load |> Problem.part1(2020)
    # assert 1 == "1,3,2" |> Problem.load |> Problem.part1(2020)
    # assert 10 == "2,1,3" |> Problem.load |> Problem.part1(2020)
    # assert 27 == "1,2,3" |> Problem.load |> Problem.part1(2020)
    # assert 78 == "2,3,1" |> Problem.load |> Problem.part1(2020)
    # assert 438 == "3,2,1" |> Problem.load |> Problem.part1(2020)
    # assert 1836 == "3,1,2" |> Problem.load |> Problem.part1(2020)
  end

  test "part1" do
    # assert 206 == "7,14,0,17,11,1,2" |> Problem.load |> Problem.part1(2020)
  end

end
