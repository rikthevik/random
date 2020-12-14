
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
    # first_bus = Enum.at(buses, 0)

    variables = "abcdfghlmnop" |> String.graphemes

    buses = Enum.filter(buses, fn b -> b != nil end)

    Enum.zip([buses, 0..Enum.count(buses), variables])
    |> Enum.map(fn {b, i, v} -> "y=#{b}*x_#{i}-#{i}" end)
    |> Enum.join(", ")
  end

  def part2actual(buses) do
    buses_and_rems = Enum.zip(buses, 0..Enum.count(buses))
    |> Enum.filter(fn {b, _} -> b != nil end)
    |> Enum.map(fn {b, i} -> {b, Integer.mod(b - i, b)} end)
    |> Enum.sort
    |> Enum.reverse
    |> IO.inspect

    {max_bus, max_rem} = buses_and_rems
    |> Enum.max

    # trying to be sneaky
    # if max_rem == 937 do
    #   max_rem = 100000000000000 - 456
    # end

    go(buses_and_rems, max_rem, max_bus)
  end

  def okay(buses_and_rems, t) do
    buses_and_rems 
    |> Stream.map(fn {bus, rem} ->
      rem == Integer.mod(t, bus)
    end)
    |> Enum.all?
    
    # if t == 3417 do
    #   for {bus, rem} <- buses_and_rems do    
    #     remainder = Integer.mod(t, bus)
    #     "bus=#{bus} rem=#{rem} remainder=#{remainder}" |> IO.inspect
    #     rem == remainder
    #   end
    #   |> IO.inspect
    #   1 = 0
    # end
  end

  def go(buses_and_rems, t, step) do
    # "go t=#{t} step=#{step}" |> IO.inspect
    if okay(buses_and_rems, t) do
      t
    else
      # t
      go(buses_and_rems, t+step, step)
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
    assert 1068781 == inputstr |> Problem.load2 |> Problem.part2
    assert Problem.part2(Problem.load2("67,7,59,61")) == 754018
    assert Problem.part2(Problem.load2("67,x,7,59,61")) == 779210
    assert Problem.part2(Problem.load2("67,7,x,59,61")) == 1261476
    assert Problem.part2(Problem.load2("1789,37,47,1889")) == 1202161486
  end

  test "go time" do
    inputstr = "1007125
    13,x,x,41,x,x,x,x,x,x,x,x,x,569,x,29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19,x,x,x,23,x,x,x,x,x,x,x,937,x,x,x,x,x,37,x,x,x,x,x,x,x,x,x,x,17"
    assert 2845 == inputstr |> Problem.load |> Problem.part1
    inputstr = "13,x,x,41,x,x,x,x,x,x,x,x,x,569,x,29,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,x,19,x,x,x,23,x,x,x,x,x,x,x,937,x,x,x,x,x,37,x,x,x,x,x,x,x,x,x,x,17"
    assert 286 == inputstr |> Problem.load2 |> Problem.part2
  end
  


end
