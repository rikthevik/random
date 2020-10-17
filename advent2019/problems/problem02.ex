
test_input = """
1,0,0,0,99
2,3,0,3,99
2,3,0,3,99
2,4,4,5,99,0
1,1,1,4,99,5,6,0,99
1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,9,23,1,23,6,27,2,27,13,31,1,10,31,35,1,10,35,39,2,39,6,43,1,43,5,47,2,10,47,51,1,5,51,55,1,55,13,59,1,59,9,63,2,9,63,67,1,6,67,71,1,71,13,75,1,75,10,79,1,5,79,83,1,10,83,87,1,5,87,91,1,91,9,95,2,13,95,99,1,5,99,103,2,103,9,107,1,5,107,111,2,111,9,115,1,115,6,119,2,13,119,123,1,123,5,127,1,127,9,131,1,131,10,135,1,13,135,139,2,9,139,143,1,5,143,147,1,13,147,151,1,151,2,155,1,10,155,0,99,2,14,0,0
"""
left = """
"""

defmodule Machine do
  def new(prog_list) do
    prog = Map.new(Enum.zip(0..Enum.count(prog_list), prog_list))
    IO.inspect(prog)
    instruction(prog[0], 0, prog)
  end

  def instruction(1, pc, prog) do
    target = prog[pc+3]
    left = prog[pc+1]
    right = prog[pc+2]
    "prog[#{target}] = prog[#{left}](#{prog[left]}) + prog[#{right}](#{prog[right]})" |> IO.puts
    # well that could be nicer
    prog = prog |> Map.put(target, prog[left] + prog[right])
    decode(pc + 4, prog)
  end

  def instruction(2, pc, prog) do
    target = prog[pc+3]
    left = prog[pc+1]
    right = prog[pc+2]
    "prog[#{target}] = prog[#{left}](#{prog[left]}) * prog[#{right}](#{prog[right]})" |> IO.puts
    prog = prog |> Map.put(target, prog[left] * prog[right])
    decode(pc + 4, prog)
  end

  def instruction(99, pc, prog) do
    "DONE prog[0]=#{prog[0]}" |> IO.puts
    prog |> Map.values |> IO.inspect
  end

  def decode(pc, prog) do
    opcode = prog[pc]
    "pc=#{pc} opcode=#{opcode}" |> IO.puts
    instruction(opcode, pc, prog)
  end
end

defmodule Problem do

  def parse(line) do
    String.split(line, ",") 
    |> Enum.map(&String.to_integer/1)
  end

  def run(inputs) do
    "INPUT" |> IO.puts
    inputs |> IO.inspect

    IO.puts("")
    "PART 1" |> IO.puts
    for prog_list <- inputs do
        Machine.new(prog_list)
    end
    # do something

    IO.puts("")
    "PART 2" |> IO.puts
    # do something else
  end
end

test_input
|> String.trim 
|> String.split 
|> Enum.map(fn i -> i |> String.trim |> Problem.parse end)
|> Problem.run
