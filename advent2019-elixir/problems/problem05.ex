
# I feel like reading the spec was the hard part here.

defmodule Util do
  # :math.pow() is all about floats and i don't want to convert back
  # and this looks like CMPT 340 homework  :)
  def ipow(i, 0) do 1 end
  def ipow(i, exponent) when exponent > 0 do
    i * ipow(i, exponent-1)
  end

  def base10_digit(i, digit_idx) do
    # This is a lot of cpu time for me not to repeat a few digits.
    m = ipow(10, digit_idx)
    i |> Integer.mod(10 * m) |> Integer.floor_div(m)
  end
end

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

  def read(m, val, :read_mode_immediate) do
    val
  end
  def read(m, val, :read_mode_positional) do
    m.prog[val]
  end

  def read_read_write(m, modes, operation_func) do
    left_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    right_val = m |> Machine.read(m.prog[m.pc+2], modes[1])
    target_addr = m.prog[m.pc+3]
    result = operation_func.(left_val, right_val)
    %{m|
      pc: m.pc + 4,
      prog: m.prog |> Map.put(target_addr, result)
    }
  end

  def instruction(m, 1, modes) do   # add(left, right, target_addr)
    m |> read_read_write(modes, fn (left, right) -> left + right end)
  end
  def instruction(m, 2, modes) do   # mult(left, right, target_addr)
    m |> read_read_write(modes, fn (left, right) -> left * right end)
  end
    
  def mode_for_param(s) do
    case s do
      0 -> :read_mode_positional
      1 -> :read_mode_immediate
    end
  end

  def find_opcode_and_modes(inst) do
    opcode = inst |> Integer.mod(100)
    modes = for mode_idx <- 4..2, into: %{} do
      {mode_idx - 2, inst |> Util.base10_digit(mode_idx) |> mode_for_param()}
    end
    {opcode, modes}
  end

  def decode_next(m) do
    m.prog |> IO.inspect
    
    inst = m.prog[m.pc]
    "pc=#{m.pc} inst=#{inst}" |> IO.puts

    {opcode, modes} = find_opcode_and_modes(inst)
    "OPCODE #{opcode} #{inspect modes}" |> IO.puts
    
    if opcode == 99 do
      m
    else
      m 
      |> instruction(opcode, modes) 
      |> decode_next()
    end
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

  def prepare_input_string(input_string) do
    input_string
    |> String.trim 
    |> String.split 
    |> Enum.map(fn i -> i |> String.trim |> Problem.parse end)
    |> Enum.at(0)
  end

  
  test "both read modes work" do
    test_input = "1002,4,3,4,33"
    test_input
    |> prepare_input_string
    |> Machine.new([])
  end

  test "negative numbers work" do
    test_input = "1101,100,-1,4,0"
    test_input
    |> prepare_input_string
    |> Machine.new([])
  end

  test "problem 3 still works" do    
    test_input = """
1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,9,23,1,23,6,27,2,27,13,31,1,10,31,35,1,10,35,39,2,39,6,43,1,43,5,47,2,10,47,51,1,5,51,55,1,55,13,59,1,59,9,63,2,9,63,67,1,6,67,71,1,71,13,75,1,75,10,79,1,5,79,83,1,10,83,87,1,5,87,91,1,91,9,95,2,13,95,99,1,5,99,103,2,103,9,107,1,5,107,111,2,111,9,115,1,115,6,119,2,13,119,123,1,123,5,127,1,127,9,131,1,131,10,135,1,13,135,139,2,9,139,143,1,5,143,147,1,13,147,151,1,151,2,155,1,10,155,0,99,2,14,0,0
"""    
    test_input
    |> prepare_input_string
    |> Machine.new([])
  end


end

