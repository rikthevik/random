
# I feel like reading the spec was the hard part here.

defmodule Machine do
  defstruct [:pc, :prog, :input, :output]

  def new(prog_list, input) do
    # Take the list of program memory and put it in a map.  
    # Afaict we don't really get direct-access arrays.
    # Zip together a list of addresses (0..whatever) with the program contents.
    m = %Machine{
      pc: 0,
      prog: Map.new(Enum.zip(0..Enum.count(prog_list), prog_list)),
      input: input,
      output: [],
    }
    m |> IO.inspect
    m = m |> Machine.decode_next()
    m.output |> IO.inspect
  end

  def instruction(m, 1, {left, right, target}) do
    # add left and right and store in target address
    # m |> Map.put(target, prog[left] + prog[right])
  end
  def instruction(m, 2, {left, right, target}) do
    # multiply left and right and store in target address
    # m |> Map.put(target, prog[left] * prog[right])
  end
  def instruction(m, 3, {target}) do
    # consume input and store in target address
  end
  def instruction(m, 4, {addr}) do
    # read from addr and output
  end

  def read(m, 0, value) do
    # positional mode
    value
  end
  def read(m, 1, addr) do
    # immediate mode
    m.prog[addr]
  end

  def mode_for_param(s) do
    case s do
      0 -> :pos
      1 -> :imm
    end
  end

  # :math.pow() is all about floats and i don't want to convert
  def ipow(i, 0) do 1 end
  def ipow(i, exponent) when exponent > 0 do
    i * ipow(i, exponent-1)
  end

  def base10_digit(i, digit_idx) do
    m = ipow(10, digit_idx)
    i |> Integer.mod(10 * m) |> Integer.floor_div(m)
  end

  def bust_inst(inst) do
    a = inst |> base10_digit(4) |> mode_for_param()
    b = inst |> base10_digit(3) |> mode_for_param()
    c = inst |> base10_digit(2) |> mode_for_param()
    opcode = inst |> Integer.mod(100)
    "#{a} #{b} #{c} op=#{opcode}" |> IO.puts
    {opcode, [a, b, c]}
    |> IO.inspect
  end

  def decode_next(m) do
    m.prog |> IO.inspect
    
    inst = m.prog[m.pc]
    "pc=#{m.pc} inst=#{inst}" |> IO.puts

    bust_inst(inst)

  #   case chunk do
  #     _ when opcode < 99 ->
  #       # long instructions?
  #       prog
  #       |> instruction(opcode, {prog[pc+1], prog[pc+2], prog[pc+3]})
  #       |> decode_next(pc+4)
  #     99 ->
  #       # "DONE prog[0]=#{prog[0]}" |> IO.puts
  #       prog[0]
  #     end
    m
  end
end

defmodule Problem do

  def parse(line) do
    String.split(line, ",") 
    |> Enum.map(&String.to_integer/1)
  end

  def problem3(prog_list) do
    "INPUT" |> IO.puts
    prog_list |> IO.inspect
    m = Machine.new(prog_list, [])
  end

  def something() do

    IO.puts("")
    "PART 1" |> IO.puts
    # for prog_list <- inputs do
    #     Machine.new(prog_list)
    # end

    # IO.puts("")
    # "PART 2" |> IO.puts
    # output_tuples = []
    # for prog_list <- inputs do
    #   for noun <- 0..99 do
    #     for verb <- 0..99 do
    #       # [prog_list[0]] + [noun, verb] + prog_list[3:] -- ???
    #       new_prog_list = [prog_list |> Enum.at(0)] ++ [noun, verb] ++ (prog_list |> Enum.slice(3, 100000))
    #       # new_prog_list |> IO.inspect
    #       output = Machine.new(new_prog_list)
    #       "noun=#{noun} verb=#{verb} output=#{output}" |> IO.puts
    #       output_tuples = [{ noun, verb, output }|output_tuples]
    #     end
    #   end
    # end
    # # do something else
    # output_tuples |> IO.inspect
    # IO.puts "wat"

    # output_tuples
    # |> IO.inspect
    # |> Enum.filter(fn { noun, verb, output } -> output == 19690720 end)
    # |> Enum.map(fn { noun, verb, output } -> 100 * noun + verb end)
    # |> List.first
  end
end

defmodule Tests do 
  use ExUnit.Case
  test "problem 3 still works" do    
    test_input = """
1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,9,23,1,23,6,27,2,27,13,31,1,10,31,35,1,10,35,39,2,39,6,43,1,43,5,47,2,10,47,51,1,5,51,55,1,55,13,59,1,59,9,63,2,9,63,67,1,6,67,71,1,71,13,75,1,75,10,79,1,5,79,83,1,10,83,87,1,5,87,91,1,91,9,95,2,13,95,99,1,5,99,103,2,103,9,107,1,5,107,111,2,111,9,115,1,115,6,119,2,13,119,123,1,123,5,127,1,127,9,131,1,131,10,135,1,13,135,139,2,9,139,143,1,5,143,147,1,13,147,151,1,151,2,155,1,10,155,0,99,2,14,0,0
"""
    test_input = "1002,4,3,4,33"
    test_input
    |> String.trim 
    |> String.split 
    |> Enum.map(fn i -> i |> String.trim |> Problem.parse end)
    |> Enum.at(0)
    |> Problem.problem3
    # |> IO.inspect
  end
end

