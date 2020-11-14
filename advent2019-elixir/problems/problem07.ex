
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
      prog: m.prog |> Map.put(target_addr, input_val),
      input: remaining_input
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

  def run_stage(input, _prog_list, []) do input end
  def run_stage(input, prog_list, [phase|phases]) do
    output = prog_list 
    |> Machine.new([phase, input])
    |> Enum.at(0)
    "OUTPUT = #{output}" |> IO.puts
    run_stage(output, prog_list, phases)
  end

  def part1(prog_list) do

  end

  def attempt(prog_list, phases) do
    "STAGE 0" |> IO.puts
    run_stage(0, prog_list, phases)
    |> IO.inspect
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
    prog_string = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
    prog_list = prog_string |> prepare_prog_string
    assert Problem.attempt(prog_list, [4,3,2,1,0]) == 43210
  end

end

