
defmodule Util do
  
end

defmodule Problem do
  
  def parse("x") do nil end
  def parse(a) do String.to_integer(a) end

  def load_line(line) do
    line = line 
    |> String.trim
    |> String.split(",")
    |> Enum.map(&parse/1)
  end

  def load(inputstr) do
    [tstr, busstrs] = inputstr 
    |> String.split("\n")
    |> Enum.map(&String.trim/1)

    {String.to_integer(tstr), load_line(busstrs)}
  end

  def part1({t, buses}) do
    {t, buses}
    
    # t |> IO.inspect

    valid_buses = buses |> Enum.filter(fn b -> b != nil end)

    {total_minutes, minutes_waiting, b} = for b <- valid_buses do
      total_minutes = b * (1 + Kernel.floor(t / b))
      minutes_waiting = b - Integer.mod(t, b)
      {total_minutes, minutes_waiting, b}
    end
    # |> IO.inspect
    |> Enum.min
    # |> IO.inspect
  
    b * minutes_waiting

  end
  
  def load2(inputstr) do
    load_line(inputstr |> String.trim)
    |> IO.inspect
  end

  def part2(buses) do
    buses |> IO.inspect

    buses_and_offsets = Enum.zip(buses, 0..Enum.count(buses))
    |> Enum.filter(fn {b, o} -> b != nil end)
    |> IO.inspect

    # Not sure if this needs to be super efficient.
    # So let's try something real simple.

    go(buses_and_offsets, 1)
  end

  def okay(buses_and_offsets, i) do
    for {bus, offset} <- buses_and_offsets do
      offset == bus - Integer.mod(i, bus)
    end
    |> Enum.all?
  end

  def go(buses_and_offsets, i) do
    if okay(buses_and_offsets, i) do
      i
    else
      go(buses_and_offsets, i+1)
    end
  end

end



defmodule Tests do 
  use ExUnit.Case
  
  test "example" do
    inputstr = "939
    7,13,x,x,59,x,31,19"
    assert 295 == inputstr |> Problem.load |> Problem.part1

    inputstr = "17,x,13,19"
    assert 3417 == inputstr |> Problem.load2 |> Problem.part2

    inputstr = "7,13,x,x,59,x,31,19"
    # assert 1068781 == inputstr |> Problem.load2 |> Problem.part2
  end

  test "go time" do
    inputstr = "1007125
    13,x,x,41,x,x,x,x,x,x,x,x,x,569,x,29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19,x,x,x,23,x,x,x,x,x,x,x,937,x,x,x,x,x,37,x,x,x,x,x,x,x,x,x,x,17"
    assert 2845 == inputstr |> Problem.load |> Problem.part1
    # assert 286 == inputstr |> Problem.load |> Problem2.part2
  end
  


end
