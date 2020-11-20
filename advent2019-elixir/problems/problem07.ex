
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

  # Pulled this from somewhere online.
  # Considering I'd use itertools in python, I think that's okay.
  def permutations([]) do [[]] end
  def permutations(list) do
    for head <- list, tail <- permutations(list -- [head]), do: [head | tail]
  end

end

defmodule Machine do
  defstruct [:id, :pc, :prog, :input, :output]

  def new(prog_list, id) do
    # Take the list of program memory and put it in a map.  
    # Afaict we don't really get direct-access arrays.
    # Zip together a list of addresses (0..whatever) with the program contents.
    %Machine{
      id: id,
      pc: 0,
      prog: Map.new(Enum.zip(0..Enum.count(prog_list), prog_list)),
      input: [],
      output: []}
  end

  def run(m, new_input) do
    %{m| 
      input: m.input ++ new_input}
    |> Machine.decode_next()
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
    # read the most recent input
    target_addr = m.prog[m.pc+1]
    [input_val|remaining_input] = m.input
    "#{m.id} read_input() => #{input_val}" |> IO.puts
    %{m|
      pc: m.pc + 2,
      prog: m.prog |> Map.put(target_addr, input_val),
      input: remaining_input
    }
  end
  def instruction(m, 4, modes) do   # write_output(arg)
    output_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    "#{m.id} write_output(#{output_val})" |> IO.puts
    %{m|
      pc: m.pc + 2,
      output: [output_val|m.output]
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
    # "PC=#{m.pc} OPCODE #{opcode} #{inspect modes}" |> IO.puts
    case opcode do
      99 ->
        { m, :stopped }
      _ ->
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

  def run_stage(input_val, _prog_list, []) do input_val end
  def run_stage(input_val, prog_list, [phase|phases]) do
    # Supply the phase and the input to the program as per the spec.
    # Run the program and get the output.
    # Send the output as the input to the next stage.
    # .. is that it? ..
    { m, :stopped } = prog_list
    |> Machine.new("phase #{phase}")
    |> Machine.run([phase, input_val])
    run_stage(m.output |> Enum.at(0), prog_list, phases)
  end

  def part1(prog_list) do
    for phases <- Util.permutations(Enum.to_list(0..4)) do
      attempt(prog_list, phases)
    end |> Enum.max()
  end

  def attempt(prog_list, phases) do
    run_stage(0, prog_list, phases)
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

  test "cycle through items forever" do
    assert [1, 2, 3, 1, 2, 3, 1] == [1, 2, 3]
    |> Stream.cycle
    |> Enum.take(7)
  end

  test "example program 1" do
    prog_string = "3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0"
    prog_list = prog_string |> prepare_prog_string
    Problem.part1(prog_list)
  end

  # test "example program 2" do
  #   prog_string = "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
  #   prog_list = prog_string |> prepare_prog_string
  #   assert Problem.part1(prog_list) == 54321
  # end

  # test "example program 3" do
  #   prog_string = "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
  #   prog_list = prog_string |> prepare_prog_string
  #   assert Problem.part1(prog_list) == 65210
  # end

  # test "part 1 go time" do
  #   prog_string = "3,8,1001,8,10,8,105,1,0,0,21,34,47,72,81,102,183,264,345,426,99999,3,9,102,5,9,9,1001,9,3,9,4,9,99,3,9,101,4,9,9,1002,9,3,9,4,9,99,3,9,102,3,9,9,101,2,9,9,102,5,9,9,1001,9,3,9,1002,9,4,9,4,9,99,3,9,101,5,9,9,4,9,99,3,9,101,3,9,9,1002,9,5,9,101,4,9,9,102,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,99"
  #   prog_list = prog_string |> prepare_prog_string
  #   assert Problem.part1(prog_list) == 92663
  # end

  test "output pauses" do
    { m, :stopped } = "3,0,4,0,99"
    |> prepare_prog_string
    |> Machine.new("machine1")
    |> Machine.run([123])
    |> IO.inspect
    assert m.output == [123]
  end
end

