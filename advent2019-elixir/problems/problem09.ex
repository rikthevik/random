
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
    # Note that we can write to addresses that weren't 
    # originally in our program.  Free memory!
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
    "#{m.id}:pc=#{m.pc} write_output(#{output_val})" |> IO.puts
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
  
  def part1(prog_list, input \\ []) do
    prog_list
    |> Machine.new("p09p1")
    |> Machine.run_until_stop(input)
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

  test "problem09 part1 quine example" do
    # it outputs itself
    prog_string = "109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99" 
    prog_list = prog_string |> prepare_prog_string
    m = Problem09.part1(prog_list)
    assert Enum.reverse(m.output) |> Enum.join(",") == prog_string
  end

  test "problem09 part1 16digit number example" do
    prog_list = "1102,34915192,34915192,7,4,7,99,0" |> prepare_prog_string
    m = Problem09.part1(prog_list)
    assert 16 == m.output |> Enum.at(0) |> Integer.to_string |> String.length
  end

  test "problem09 part1 i think this just outputs a value" do
    prog_list = "104,1125899906842624,99" |> prepare_prog_string
    m = Problem09.part1(prog_list)
    assert 1125899906842624 == m.output |> Enum.at(0)
  end

  test "problem05part2 test suite still works" do
    prog_string = "3,225,1,225,6,6,1100,1,238,225,104,0,1101,37,34,224,101,-71,224,224,4,224,1002,223,8,223,101,6,224,224,1,224,223,223,1002,113,50,224,1001,224,-2550,224,4,224,1002,223,8,223,101,2,224,224,1,223,224,223,1101,13,50,225,102,7,187,224,1001,224,-224,224,4,224,1002,223,8,223,1001,224,5,224,1,224,223,223,1101,79,72,225,1101,42,42,225,1102,46,76,224,101,-3496,224,224,4,224,102,8,223,223,101,5,224,224,1,223,224,223,1102,51,90,225,1101,11,91,225,1001,118,49,224,1001,224,-140,224,4,224,102,8,223,223,101,5,224,224,1,224,223,223,2,191,87,224,1001,224,-1218,224,4,224,1002,223,8,223,101,4,224,224,1,224,223,223,1,217,83,224,1001,224,-124,224,4,224,1002,223,8,223,101,5,224,224,1,223,224,223,1101,32,77,225,1101,29,80,225,101,93,58,224,1001,224,-143,224,4,224,102,8,223,223,1001,224,4,224,1,223,224,223,1101,45,69,225,4,223,99,0,0,0,677,0,0,0,0,0,0,0,0,0,0,0,1105,0,99999,1105,227,247,1105,1,99999,1005,227,99999,1005,0,256,1105,1,99999,1106,227,99999,1106,0,265,1105,1,99999,1006,0,99999,1006,227,274,1105,1,99999,1105,1,280,1105,1,99999,1,225,225,225,1101,294,0,0,105,1,0,1105,1,99999,1106,0,300,1105,1,99999,1,225,225,225,1101,314,0,0,106,0,0,1105,1,99999,7,226,226,224,102,2,223,223,1005,224,329,101,1,223,223,108,677,226,224,102,2,223,223,1005,224,344,1001,223,1,223,1108,226,677,224,102,2,223,223,1005,224,359,1001,223,1,223,8,677,226,224,102,2,223,223,1006,224,374,1001,223,1,223,107,226,226,224,102,2,223,223,1006,224,389,101,1,223,223,1108,677,226,224,1002,223,2,223,1005,224,404,1001,223,1,223,108,677,677,224,102,2,223,223,1005,224,419,101,1,223,223,7,226,677,224,1002,223,2,223,1006,224,434,1001,223,1,223,107,226,677,224,102,2,223,223,1005,224,449,101,1,223,223,1108,677,677,224,1002,223,2,223,1006,224,464,101,1,223,223,7,677,226,224,102,2,223,223,1006,224,479,101,1,223,223,1007,677,677,224,1002,223,2,223,1005,224,494,101,1,223,223,1008,226,226,224,102,2,223,223,1006,224,509,1001,223,1,223,107,677,677,224,102,2,223,223,1006,224,524,1001,223,1,223,8,226,226,224,1002,223,2,223,1005,224,539,1001,223,1,223,1007,677,226,224,102,2,223,223,1006,224,554,1001,223,1,223,1007,226,226,224,1002,223,2,223,1005,224,569,1001,223,1,223,8,226,677,224,1002,223,2,223,1006,224,584,101,1,223,223,108,226,226,224,1002,223,2,223,1006,224,599,101,1,223,223,1107,677,226,224,1002,223,2,223,1005,224,614,1001,223,1,223,1107,226,677,224,102,2,223,223,1006,224,629,1001,223,1,223,1008,226,677,224,102,2,223,223,1005,224,644,101,1,223,223,1107,226,226,224,102,2,223,223,1006,224,659,1001,223,1,223,1008,677,677,224,102,2,223,223,1006,224,674,1001,223,1,223,4,223,99,226"
    prog_list = prog_string |> prepare_prog_string
    m = prog_list 
    |> Machine.new("something") 
    |> Machine.run_until_stop([5])
    assert [11460760] == m.output
  end

  @tag :part1
  test "problem09 part 1 go time" do
    prog_string = "1102,34463338,34463338,63,1007,63,34463338,63,1005,63,53,1102,3,1,1000,109,988,209,12,9,1000,209,6,209,3,203,0,1008,1000,1,63,1005,63,65,1008,1000,2,63,1005,63,904,1008,1000,0,63,1005,63,58,4,25,104,0,99,4,0,104,0,99,4,17,104,0,99,0,0,1101,0,33,1017,1101,24,0,1014,1101,519,0,1028,1102,34,1,1004,1101,0,31,1007,1101,0,844,1025,1102,0,1,1020,1102,38,1,1003,1102,39,1,1008,1102,849,1,1024,1101,0,22,1001,1102,25,1,1009,1101,1,0,1021,1101,0,407,1022,1101,404,0,1023,1101,0,35,1013,1101,27,0,1011,1101,0,37,1016,1102,1,26,1019,1102,28,1,1015,1101,0,30,1000,1102,1,36,1005,1101,0,29,1002,1101,23,0,1012,1102,1,32,1010,1102,21,1,1006,1101,808,0,1027,1102,20,1,1018,1101,0,514,1029,1102,1,815,1026,109,14,2107,24,-5,63,1005,63,199,4,187,1105,1,203,1001,64,1,64,1002,64,2,64,109,-1,2108,21,-7,63,1005,63,225,4,209,1001,64,1,64,1106,0,225,1002,64,2,64,109,-16,1201,6,0,63,1008,63,35,63,1005,63,249,1001,64,1,64,1106,0,251,4,231,1002,64,2,64,109,9,2102,1,2,63,1008,63,37,63,1005,63,271,1105,1,277,4,257,1001,64,1,64,1002,64,2,64,109,11,1208,-8,23,63,1005,63,293,1105,1,299,4,283,1001,64,1,64,1002,64,2,64,109,8,21107,40,39,-8,1005,1017,319,1001,64,1,64,1106,0,321,4,305,1002,64,2,64,109,-28,2101,0,6,63,1008,63,39,63,1005,63,341,1106,0,347,4,327,1001,64,1,64,1002,64,2,64,109,19,2107,26,-7,63,1005,63,363,1106,0,369,4,353,1001,64,1,64,1002,64,2,64,109,1,1202,-9,1,63,1008,63,39,63,1005,63,395,4,375,1001,64,1,64,1105,1,395,1002,64,2,64,109,9,2105,1,-3,1106,0,413,4,401,1001,64,1,64,1002,64,2,64,109,-13,1207,-4,26,63,1005,63,435,4,419,1001,64,1,64,1105,1,435,1002,64,2,64,109,-1,21101,41,0,7,1008,1019,41,63,1005,63,461,4,441,1001,64,1,64,1105,1,461,1002,64,2,64,109,7,21107,42,43,-2,1005,1017,479,4,467,1105,1,483,1001,64,1,64,1002,64,2,64,109,-6,21108,43,46,0,1005,1013,499,1106,0,505,4,489,1001,64,1,64,1002,64,2,64,109,17,2106,0,-2,4,511,1105,1,523,1001,64,1,64,1002,64,2,64,109,-27,1202,-1,1,63,1008,63,28,63,1005,63,547,1001,64,1,64,1106,0,549,4,529,1002,64,2,64,109,18,1206,-1,567,4,555,1001,64,1,64,1106,0,567,1002,64,2,64,109,-16,21102,44,1,6,1008,1011,43,63,1005,63,587,1106,0,593,4,573,1001,64,1,64,1002,64,2,64,109,8,21102,45,1,-1,1008,1012,45,63,1005,63,619,4,599,1001,64,1,64,1105,1,619,1002,64,2,64,109,7,1205,1,633,4,625,1106,0,637,1001,64,1,64,1002,64,2,64,109,-8,2102,1,-3,63,1008,63,25,63,1005,63,659,4,643,1105,1,663,1001,64,1,64,1002,64,2,64,109,14,1206,-5,679,1001,64,1,64,1105,1,681,4,669,1002,64,2,64,109,-28,2101,0,2,63,1008,63,30,63,1005,63,707,4,687,1001,64,1,64,1106,0,707,1002,64,2,64,109,21,21101,46,0,0,1008,1019,48,63,1005,63,727,1106,0,733,4,713,1001,64,1,64,1002,64,2,64,109,-3,21108,47,47,1,1005,1017,751,4,739,1106,0,755,1001,64,1,64,1002,64,2,64,109,-13,1207,0,37,63,1005,63,771,1105,1,777,4,761,1001,64,1,64,1002,64,2,64,109,7,2108,21,-9,63,1005,63,797,1001,64,1,64,1105,1,799,4,783,1002,64,2,64,109,22,2106,0,-5,1001,64,1,64,1106,0,817,4,805,1002,64,2,64,109,-4,1205,-8,829,1106,0,835,4,823,1001,64,1,64,1002,64,2,64,109,-4,2105,1,0,4,841,1105,1,853,1001,64,1,64,1002,64,2,64,109,-30,1208,6,30,63,1005,63,871,4,859,1105,1,875,1001,64,1,64,1002,64,2,64,109,-2,1201,9,0,63,1008,63,22,63,1005,63,897,4,881,1106,0,901,1001,64,1,64,4,64,99,21101,27,0,1,21102,1,915,0,1106,0,922,21201,1,66266,1,204,1,99,109,3,1207,-2,3,63,1005,63,964,21201,-2,-1,1,21102,942,1,0,1105,1,922,22101,0,1,-1,21201,-2,-3,1,21101,0,957,0,1106,0,922,22201,1,-1,-2,1105,1,968,21202,-2,1,-2,109,-3,2106,0,0"
    prog_list = prog_string |> prepare_prog_string
    m = Problem09.part1(prog_list, [1])
    assert [123] == m.output
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
