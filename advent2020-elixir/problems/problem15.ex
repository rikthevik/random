
use Bitwise

defmodule Util do
  
end

defmodule Problem do
  defstruct [:mask, :mem]

  
  def load(inputstr) do
    inputstr
    |> String.trim
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end

  def part1(ints, max_turn) do
    p1(ints, max_turn)
  end
  
  def p1(ints, max_turn) do 
    ints 
    |> Enum.reverse
    |> p1(Enum.count(ints)+1, max_turn+1)
    |> IO.inspect
    |> Enum.at(0)
  end
  def p1(spoken, max_turn, max_turn) do spoken end
  def p1(spoken, turn, max_turn) do 
    # "turn=#{turn} spoken=#{inspect spoken}" |> IO.puts
    
    [lastval|rest] = spoken

    # "lastval=#{lastval}" |> IO.puts

    first_idx = spoken 
    |> Enum.find_index(fn i -> i == lastval end)
    second_idx = spoken 
    |> Enum.slice((first_idx+1)..turn) 
    |> Enum.find_index(fn i -> i == lastval end)

    
    newly_spoken = if second_idx == nil do
      0
    else
      second_idx + 1
    end

    # "first=#{first_idx} second=#{second_idx} newly=#{newly_spoken}\n" |> IO.puts

    p1([newly_spoken|spoken], turn+1, max_turn)

  end

end



defmodule Tests do 
  use ExUnit.Case

  test "examples" do
    assert 0 == "0,3,6" |> Problem.load |> Problem.part1(10)
    assert 1 == "1,3,2" |> Problem.load |> Problem.part1(2020)
    assert 1 == "1,3,2" |> Problem.load |> Problem.part1(2020)
    assert 10 == "2,1,3" |> Problem.load |> Problem.part1(2020)
    assert 27 == "1,2,3" |> Problem.load |> Problem.part1(2020)
    assert 78 == "2,3,1" |> Problem.load |> Problem.part1(2020)
    assert 438 == "3,2,1" |> Problem.load |> Problem.part1(2020)
    assert 1836 == "3,1,2" |> Problem.load |> Problem.part1(2020)
  end

  test "part1" do
    assert 206 == "7,14,0,17,11,1,2" |> Problem.load |> Problem.part1(2020)
  end

end
