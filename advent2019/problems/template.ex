
input = """
123
456
"""

defmodule Problem do

  def parse(line) do
    String.to_integer(line)
  end

  def run(inputs) do
    "INPUT" |> IO.puts
    inputs |> IO.inspect

    IO.puts("")
    "PART 1" |> IO.puts
    # do something

    IO.puts("")
    "PART 2" |> IO.puts
    # do something else
  end
end

input
  |> String.trim 
  |> String.split 
  |> Enum.map(&Problem.parse/1)
  |> Problem.run
