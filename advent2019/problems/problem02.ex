
test_input = """
1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,9,23,1,23,6,27,2,27,13,31,1,10,31,35,1,10,35,39,2,39,6,43,1,43,5,47,2,10,47,51,1,5,51,55,1,55,13,59,1,59,9,63,2,9,63,67,1,6,67,71,1,71,13,75,1,75,10,79,1,5,79,83,1,10,83,87,1,5,87,91,1,91,9,95,2,13,95,99,1,5,99,103,2,103,9,107,1,5,107,111,2,111,9,115,1,115,6,119,2,13,119,123,1,123,5,127,1,127,9,131,1,131,10,135,1,13,135,139,2,9,139,143,1,5,143,147,1,13,147,151,1,151,2,155,1,10,155,0,99,2,14,0,0
"""
left = """
1,0,0,0,99
2,3,0,3,99
2,3,0,3,99
2,4,4,5,99,0
1,1,1,4,99,5,6,0,99
"""

defmodule Machine do
  def new(prog_list) do
    # Take the list of program memory and put it in a map.  
    # Afaict we don't really get direct-access arrays.
    # Zip together a list of addresses (0..whatever) with the program contents.
    prog = Map.new(Enum.zip(0..Enum.count(prog_list), prog_list))
    # IO.inspect(prog)
    prog |> decode_next(0)
  end

  def instruction(prog, 1, {left, right, target}) do
    prog |> Map.put(target, prog[left] + prog[right])
  end

  def instruction(prog, 2, {left, right, target}) do
    prog |> Map.put(target, prog[left] * prog[right])
  end

  def decode_next(prog, pc) do
    opcode = prog[pc]
    # "pc=#{pc} opcode=#{opcode}" |> IO.puts
    case opcode do
      _ when opcode < 99 ->
        # long instructions?
        prog
        |> instruction(opcode, {prog[pc+1], prog[pc+2], prog[pc+3]})
        |> decode_next(pc+4)
      99 ->
        # "DONE prog[0]=#{prog[0]}" |> IO.puts
        prog[0]
      end
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
    # for prog_list <- inputs do
    #     Machine.new(prog_list)
    # end

    IO.puts("")
    "PART 2" |> IO.puts
    for prog_list <- inputs do
      for noun <- 0..1 do
        for verb <- 0..1 do
          noun = 12
          verb = 2
          # [prog_list[0]] + [noun, verb] + prog_list[3:] -- ???
          new_prog_list = [prog_list |> Enum.at(0)] ++ [noun, verb] ++ (prog_list |> Enum.slice(3, 100000))
          # new_prog_list |> IO.inspect
          result = Machine.new(new_prog_list)
          calc = 100 * noun + verb
          "noun=#{noun} verb=#{verb} result=#{result} calc=#{calc}" |> IO.puts
        end
      end
    end
    # do something else
  end
end

test_input
|> String.trim 
|> String.split 
|> Enum.map(fn i -> i |> String.trim |> Problem.parse end)
|> Problem.run
