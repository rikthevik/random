
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

  def parse(line) do
    String.split(line, ",") 
    |> Enum.map(&String.to_integer/1)
  end

end

defmodule Machine do
  defstruct [:id, :pc, :relbase, :prog, :input, :output]

  def new(prog_list, id, input \\ []) do
    # Take the list of program memory and put it in a map.  
    # Afaict we don't really get direct-access arrays.
    # Zip together a list of addresses (0..whatever) with the program contents.
    %Machine{
      id: id,
      pc: 0,
      relbase: 0,
      prog: Map.new(Enum.zip(0..Enum.count(prog_list), prog_list)),
      input: input,
      output: []}
  end

  def run(m, new_input) do
    %{m| 
      input: m.input ++ new_input}
    |> Machine.decode_next()
  end
  def run_until_stop(m, new_input \\ []) do
    # I don't love this function but it gets the job done.
    run_result = m |> Machine.run(new_input)
    case run_result do
      {m, :stopped} -> m
      {m, :output} -> run_until_stop(m, [])
    end
  end

  defp inner_read(m, addr) when addr >= 0 do
    # If this isn't value included in our program, read a 0.
    m.prog |> Map.get(addr, 0)
  end
  def read(m, val, :read_immediate) do
    val
  end
  def read(m, addr, :read_positional) do
    inner_read(m, addr)
  end
  def read(m, offset, :read_relative) do
    inner_read(m, m.relbase+offset)
  end  

  def write(m, addr, val) when addr >= 0 do    
    %{m|
      prog: m.prog |> Map.put(addr, val)
    }
  end

  def two_operand_alu(m, modes, operation_func) do
    left_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    right_val = m |> Machine.read(m.prog[m.pc+2], modes[1])
    target_addr = m.prog[m.pc+3]
    result = operation_func.(left_val, right_val)
    %{m|
      pc: m.pc + 4,
    } |> Machine.write(target_addr, result)
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
    # read the most recent input and store in target addr
    target_addr = m.prog[m.pc+1]
    [input_val|remaining_input] = m.input
    # "#{m.id} read_input() => #{input_val}" |> IO.puts
    %{m|
      pc: m.pc + 2,
      input: remaining_input
    } |> Machine.write(target_addr, input_val)
  end
  def instruction(m, 4, modes) do   # write_output(arg)
    output_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    # "#{m.id} write_output(#{output_val})" |> IO.puts
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
  def instruction(m, 9, modes) do   # adjust_relbase(offset)
    offset_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    %{m|
      pc: m.pc + 2,
      relbase: m.relbase + offset_val,
    }
  end

  def mode_for_param(s) do
    case s do
      0 -> :read_positional
      1 -> :read_immediate
      2 -> :read_relative
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
      4 ->
        { m |> instruction(opcode, modes), :output }
      _ ->
        m 
        |> instruction(opcode, modes) 
        |> decode_next()
    end
  end
end

defmodule Problem09 do
  
  def part1(prog_list) do
    prog_list 
    |> Machine.new("part1")
    |> Machine.run_until_stop
  end
end

defmodule Tests do 
  use ExUnit.Case

  def prepare_prog_string(prog_string) do
    prog_string
    |> String.trim 
    |> String.split 
    |> Enum.map(fn i -> i |> String.trim |> Util.parse end)
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
    Problem07.part1(prog_list)
  end

  test "example program 2" do
    prog_string = "3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0"
    prog_list = prog_string |> prepare_prog_string
    assert Problem07.part1(prog_list) == 54321
  end

  test "example program 3" do
    prog_string = "3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0"
    prog_list = prog_string |> prepare_prog_string
    assert Problem07.part1(prog_list) == 65210
  end

  test "problem 07 part 1 go time" do
    prog_string = "3,8,1001,8,10,8,105,1,0,0,21,34,47,72,81,102,183,264,345,426,99999,3,9,102,5,9,9,1001,9,3,9,4,9,99,3,9,101,4,9,9,1002,9,3,9,4,9,99,3,9,102,3,9,9,101,2,9,9,102,5,9,9,1001,9,3,9,1002,9,4,9,4,9,99,3,9,101,5,9,9,4,9,99,3,9,101,3,9,9,1002,9,5,9,101,4,9,9,102,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,99"
    prog_list = prog_string |> prepare_prog_string
    assert Problem07.part1(prog_list) == 92663
  end

  test "problem 07 part 2 example 1" do
    prog_list = "3,26,1001,26,-4,26,3,27,1002,27,2,27,1,27,26,27,4,27,1001,28,-1,28,1005,28,6,99,0,0,5"
    |> prepare_prog_string
    assert Problem07.part2_attempt(prog_list, [9,8,7,6,5]) == 139629729
    assert Problem07.part2(prog_list) == 139629729
  end

  test "problem 07 part 2 example 2" do
    prog_list = "3,52,1001,52,-5,52,3,53,1,52,56,54,1007,54,5,55,1005,55,26,1001,54,-5,54,1105,1,12,1,53,54,53,1008,54,0,55,1001,55,1,55,2,53,55,53,4,53,1001,56,-1,56,1005,56,6,99,0,0,0,0,10"
    |> prepare_prog_string
    assert Problem07.part2_attempt(prog_list, [9,7,8,5,6]) == 18216
    assert Problem07.part2(prog_list) == 18216
  end

  test "problem 07 part 2 go time" do
    prog_string = "3,8,1001,8,10,8,105,1,0,0,21,34,47,72,81,102,183,264,345,426,99999,3,9,102,5,9,9,1001,9,3,9,4,9,99,3,9,101,4,9,9,1002,9,3,9,4,9,99,3,9,102,3,9,9,101,2,9,9,102,5,9,9,1001,9,3,9,1002,9,4,9,4,9,99,3,9,101,5,9,9,4,9,99,3,9,101,3,9,9,1002,9,5,9,101,4,9,9,102,2,9,9,4,9,99,3,9,1002,9,2,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,1,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,1001,9,2,9,4,9,3,9,101,2,9,9,4,9,99,3,9,101,1,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,99,3,9,1001,9,2,9,4,9,3,9,101,1,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,101,1,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,3,9,101,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,102,2,9,9,4,9,99,3,9,102,2,9,9,4,9,3,9,1001,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,101,2,9,9,4,9,3,9,1001,9,1,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,102,2,9,9,4,9,3,9,1002,9,2,9,4,9,3,9,1001,9,1,9,4,9,99"
    prog_list = prog_string |> prepare_prog_string
    assert Problem07.part2(prog_list) == 14365052
  end

  test "output pauses" do
    m = "3,0,4,0,99"
    |> prepare_prog_string
    |> Machine.new("machine1")
    |> Machine.run_until_stop([123])
    assert m.output == [123]
  end

  test "problem 09 examples" do
    prog_list = "104,1125899906842624,99"
    |> prepare_prog_string
    m = Problem09.part1(prog_list)
    assert 1125899906842624 == m.output |> Enum.at(0)
  end
end

defmodule Problem07 do

  def run_stage(input_val, _prog_list, []) do input_val end
  def run_stage(input_val, prog_list, [phase|phases]) do
    # Supply the phase and the input to the program as per the spec.
    # Run the program and get the output.
    # Send the output as the input to the next stage.
    # .. is that it? ..
    m = prog_list
    |> Machine.new("phase #{phase}")
    |> Machine.run_until_stop([phase, input_val])
    run_stage(m.output |> Enum.at(0), prog_list, phases)
  end

  def part1(prog_list) do
    for phases <- Util.permutations(Enum.to_list(0..4)) do
      run_stage(0, prog_list, phases)
    end |> Enum.max()
  end

  # -- part 2 --------
  def part2(prog_list) do
    for phases <- Util.permutations(Enum.to_list(5..9)) do
      part2_attempt(prog_list, phases)
    end |> Enum.max()
  end

  def part2_attempt(prog_list, phases) do
    phase_string = phases |> Enum.join("")
    machines = for p <- phases do
      Machine.new(prog_list, "#{phase_string}-#{p}", [p])
    end
    run_stage2(0, machines)
  end

  def run_stage2(input_val, []) do input_val end
  def run_stage2(input_val, [m|mlist]) do
    run_result = m |> Machine.run([input_val])
    case run_result do
      {m, :output} -> 
        output_val = m.output |> Enum.at(0)
        run_stage2(output_val, mlist ++ [m])
      {m, :stopped} ->
        output_val = m.output |> Enum.at(0)
        run_stage2(output_val, mlist)
    end
  end

end
