
defmodule Util do
  
end

defmodule Problem do
  
  def load_line(line) do
    if String.starts_with?(line, "mask") do
      ["mask", "=", mask] = String.split(line, " ")
      {:mask, mask}
    else
      [m, addrstr, valstr] = Regex.run(~r/^mem\[(\d+)\] = (\d+)$/, line)
      {:set, String.to_integer(addrstr), String.to_integer(valstr)}
    end
  end

  def load(inputstr) do
    inputstr
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&load_line/1)

  end

  def part1(rows) do
    rows |> IO.inspect

  end
  
end



defmodule Tests do 
  use ExUnit.Case
  
  test "example" do
    inputstr = "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0"
    assert 2845 == inputstr |> Problem.load |> Problem.part1
  end

  test "go time" do
    IO.puts "hi"    
  end
  


end
