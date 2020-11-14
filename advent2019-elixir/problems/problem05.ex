
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
    m = m |> Machine.decode_next()
    m.output |> Enum.reverse
  end

  def read(m, val, :read_immediate) do
    val
  end
  def read(m, val, :read_positional) do
    m.prog[val]
  end

  def two_operand_alu(m, modes, operation_func) do
    left_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    right_val = m |> Machine.read(m.prog[m.pc+2], modes[1])
    target_addr = m.prog[m.pc+3]
    result = operation_func.(left_val, right_val)
    %{m|
      pc: m.pc + 4,
      prog: m.prog |> Map.put(target_addr, result)
    }
  end
  def jump_if_condition(m, modes, condition_func) do
    compare_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    new_pc = m |> Machine.read(m.prog[m.pc+2], modes[1])
    if condition_func.(compare_val) do
      %{m|
        pc: new_pc}
    else
      %{m|
        pc: m.pc+3}
    end
  end


  def instruction(m, 1, modes) do   # add(left, right, target_addr)
    m |> two_operand_alu(modes, fn (l, r) -> l + r end)
  end
  def instruction(m, 2, modes) do   # mult(left, right, target_addr)
    m |> two_operand_alu(modes, fn (l, r) -> l * r end)
  end
  def instruction(m, 3, modes) do   # read_input(target_addr)
    target_addr = m.prog[m.pc+1]
    [input_val|remaining_input] = m.input
    %{m|
      pc: m.pc + 2,
      prog: m.prog |> Map.put(target_addr, input_val)
    }
  end
  def instruction(m, 4, modes) do   # write_output(arg)
    val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    %{m|
      pc: m.pc + 2,
      output: [val|m.output]
    }
  end
  def instruction(m, 5, modes) do   # jump_if_true(comparison, new_pc)
    m |> jump_if_condition(modes, fn (val) -> val != 0 end)
  end
  def instruction(m, 6, modes) do   # jump_if_false(comparison, new_pc)
    m |> jump_if_condition(modes, fn (val) -> val == 0 end)
  end
  def instruction(m, 7, modes) do   # test_lt(left, right, target_addr)
    m |> two_operand_alu(modes, fn (l, r) -> if l < r, do: 1, else: 0 end)
  end
  def instruction(m, 8, modes) do   # test_eq(left, right, target_addr)
    m |> two_operand_alu(modes, fn (l, r) -> if l == r, do: 1, else: 0 end)
  end

  def mode_for_param(s) do
    case s do
      0 -> :read_positional
      1 -> :read_immediate
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
    inst = m.prog[m.pc]
    {opcode, modes} = find_opcode_and_modes(inst)
    "PC=#{m.pc} OPCODE #{opcode} #{inspect modes}" |> IO.puts
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
    # might just leave this alone for now
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

  def prepare_prog_string(prog_string) do
    prog_string
    |> String.trim 
    |> String.split 
    |> Enum.map(fn i -> i |> String.trim |> Problem.parse end)
    |> Enum.at(0)
  end

  test "both read modes work" do
    "1002,4,3,4,33"
    |> prepare_prog_string
    |> Machine.new([])
  end

  test "negative numbers work" do
    "1101,100,-1,4,0"
    |> prepare_prog_string
    |> Machine.new([])
  end

  test "input output works" do
    output = "3,0,4,0,99"
    |> prepare_prog_string
    |> Machine.new([123])
    assert output == [123]
  end

  test "problem 5 part 1" do
    output = "3,225,1,225,6,6,1100,1,238,225,104,0,1101,37,34,224,101,-71,224,224,4,224,1002,223,8,223,101,6,224,224,1,224,223,223,1002,113,50,224,1001,224,-2550,224,4,224,1002,223,8,223,101,2,224,224,1,223,224,223,1101,13,50,225,102,7,187,224,1001,224,-224,224,4,224,1002,223,8,223,1001,224,5,224,1,224,223,223,1101,79,72,225,1101,42,42,225,1102,46,76,224,101,-3496,224,224,4,224,102,8,223,223,101,5,224,224,1,223,224,223,1102,51,90,225,1101,11,91,225,1001,118,49,224,1001,224,-140,224,4,224,102,8,223,223,101,5,224,224,1,224,223,223,2,191,87,224,1001,224,-1218,224,4,224,1002,223,8,223,101,4,224,224,1,224,223,223,1,217,83,224,1001,224,-124,224,4,224,1002,223,8,223,101,5,224,224,1,223,224,223,1101,32,77,225,1101,29,80,225,101,93,58,224,1001,224,-143,224,4,224,102,8,223,223,1001,224,4,224,1,223,224,223,1101,45,69,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,7,226,226,224,102,2,223,223,1005,224,329,101,1,223,223,108,677,226,224,102,2,223,223,1005,224,344,1001,223,1,223,1108,226,677,224,102,2,223,223,1005,224,359,1001,223,1,223,8,677,226,224,102,2,223,223,1006,224,374,1001,223,1,223,107,226,226,224,102,2,223,223,1006,224,389,101,1,223,223,1108,677,226,224,1002,223,2,223,1005,224,404,1001,223,1,223,108,677,677,224,102,2,223,223,1005,224,419,101,1,223,223,7,226,677,224,1002,223,2,223,1006,224,434,1001,223,1,223,107,226,677,224,102,2,223,223,1005,224,449,101,1,223,223,1108,677,677,224,1002,223,2,223,1006,224,464,101,1,223,223,7,677,226,224,102,2,223,223,1006,224,479,101,1,223,223,1007,677,677,224,1002,223,2,223,1005,224,494,101,1,223,223,1008,226,226,224,102,2,223,223,1006,224,509,1001,223,1,223,107,677,677,224,102,2,223,223,1006,224,524,1001,223,1,223,8,226,226,224,1002,223,2,223,1005,224,539,1001,223,1,223,1007,677,226,224,102,2,223,223,1006,224,554,1001,223,1,223,1007,226,226,224,1002,223,2,223,1005,224,569,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,584,101,1,223,223,108,226,226,224,1002,223,2,223,1006,224,599,101,1,223,223,1107,677,226,224,1002,223,2,223,1005,224,614,1001,223,1,223,1107,226,677,224,102,2,223,223,1006,224,629,1001,223,1,223,1008,226,677,224,102,2,223,223,1005,224,644,101,1,223,223,1107,226,226,224,102,2,223,223,1006,224,659,1001,223,1,223,1008,677,677,224,102,2,223,223,1006,224,674,1001,223,1,223,4,223,99,226"
    |> prepare_prog_string
    |> Machine.new([1])
    { zeroes, diagnostic } = output |> Enum.split_while(fn a -> a == 0 end)
    assert Enum.count(zeroes) > 0
    assert Enum.count(diagnostic) == 1
    assert [13294380] == diagnostic
  end

  test "test equal 8" do 
    prog = "3,9,8,9,10,9,4,9,99,-1,8"
    assert [0] == prog |> prepare_prog_string |> Machine.new([7])
    assert [1] == prog |> prepare_prog_string |> Machine.new([8])
    assert [0] == prog |> prepare_prog_string |> Machine.new([9])
    
    prog = "3,3,1108,-1,8,3,4,3,99"
    assert [0] == prog |> prepare_prog_string |> Machine.new([7])
    assert [1] == prog |> prepare_prog_string |> Machine.new([8])
    assert [0] == prog |> prepare_prog_string |> Machine.new([9])
  end

  test "tess lt 8" do
    prog = "3,9,7,9,10,9,4,9,99,-1,8"
    assert [1] == prog |> prepare_prog_string |> Machine.new([7])
    assert [0] == prog |> prepare_prog_string |> Machine.new([8])
    assert [0] == prog |> prepare_prog_string |> Machine.new([9])
    
    prog = "3,3,1107,-1,8,3,4,3,99"
    assert [1] == prog |> prepare_prog_string |> Machine.new([7])
    assert [0] == prog |> prepare_prog_string |> Machine.new([8])
    assert [0] == prog |> prepare_prog_string |> Machine.new([9])
  end

  test "jump tests" do
    prog = "3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9"
    assert [0] == prog |> prepare_prog_string |> Machine.new([0])
    assert [1] == prog |> prepare_prog_string |> Machine.new([1])
    assert [1] == prog |> prepare_prog_string |> Machine.new([12345])

    prog = "3,3,1105,-1,9,1101,0,0,12,4,12,99,1"
    assert [0] == prog |> prepare_prog_string |> Machine.new([0])
    assert [1] == prog |> prepare_prog_string |> Machine.new([1])
    assert [1] == prog |> prepare_prog_string |> Machine.new([12345])
  end

  test "problem 3 still works" do    
    # "1,12,2,3,1,1,2,3,1,3,4,3,1,5,0,3,2,10,1,19,1,19,9,23,1,23,6,27,2,27,13,31,1,10,31,35,1,10,35,39,2,39,6,43,1,43,5,47,2,10,47,51,1,5,51,55,1,55,13,59,1,59,9,63,2,9,63,67,1,6,67,71,1,71,13,75,1,75,10,79,1,5,79,83,1,10,83,87,1,5,87,91,1,91,9,95,2,13,95,99,1,5,99,103,2,103,9,107,1,5,107,111,2,111,9,115,1,115,6,119,2,13,119,123,1,123,5,127,1,127,9,131,1,131,10,135,1,13,135,139,2,9,139,143,1,5,143,147,1,13,147,151,1,151,2,155,1,10,155,0,99,2,14,0,0"
    # |> prepare_prog_string
    # |> Machine.new([])
  end


end

