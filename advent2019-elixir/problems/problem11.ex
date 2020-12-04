
###
# Okay, so the general approach for problem 11.  
# Before we had to have the machine pause when it produced output.
# Now we need to have the machine pause when it asks for input
#  (the color of the current square we're on top of)
# The design from Problem09 should mostly work okay I think.
###

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
  def read(m, val, :immediate) do
    val
  end
  def read(m, addr, :positional) do
    inner_read(m, addr)
  end
  def read(m, offset, :relative) do
    inner_read(m, m.relbase+offset)
  end  

  defp inner_write(m, addr, val) when addr >= 0 do 
    # !! Had a bug earlier where I wasn't using the addressing
    #  mode in writes, because they were all positional before. !!
    # Note that we can write to addresses that weren't 
    # originally in our program.  Free memory!
    %{m|
      prog: m.prog |> Map.put(addr, val)
    }
  end  
  def write(m, addr, val, :positional) do 
    inner_write(m, addr, val)
  end
  def write(m, offset, val, :relative) do 
    inner_write(m, m.relbase+offset, val)
  end

  def two_operand_alu(m, modes, operation_func) do
    left_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    right_val = m |> Machine.read(m.prog[m.pc+2], modes[1])
    target_addr = m.prog[m.pc+3]
    result = operation_func.(left_val, right_val)
    %{m|
      pc: m.pc + 4,
    } |> Machine.write(target_addr, result, modes[2])
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
    } |> Machine.write(target_addr, input_val, modes[0])
  end
  def instruction(m, 4, modes) do   # write_output(arg)
    output_val = m |> Machine.read(m.prog[m.pc+1], modes[0])
    # "#{m.id}:pc=#{m.pc} write_output(#{output_val})" |> IO.puts
    %{m|
      pc: m.pc + 2,
      output: [output_val|m.output]  # we kinda store the output backwards...
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
    # "#{m.id}:pc=#{m.pc} adjust_relbase(#{offset_val}) => #{m.relbase+offset_val}" |> IO.puts
    %{m|
      pc: m.pc + 2,
      relbase: m.relbase + offset_val,
    }
  end

  def mode_for_param(s) do
    case s do
      0 -> :positional
      1 -> :immediate
      2 -> :relative
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
      3 when m.input == [] ->
        # If there's no input, block.
        { m, :input }
      4 ->
        { m |> instruction(opcode, modes), :output }
      _ ->
        m 
        |> instruction(opcode, modes) 
        |> decode_next()
    end
  end
end

defmodule Robot do
  defstruct [:m, :dir, :x, :y, :floor, :paint_path]
  def new(prog_list) do
    %Robot{
      m: Machine.new(prog_list, "roBBo"),
      dir: :dir_up,
      x: 0,
      y: 0,
      paint_path: [],   # [{{x, y}, color}]
      floor: Map.new  # fuck it, let's store the floor here
    }
  end

  def run(r, new_input) do
    run_result = r.m |> Machine.run(new_input)  # camera input
    case run_result do
      {m, :input} -> 
        floor_color = r.floor |> Map.get({r.x, r.y}, 0)
        %{r| m: m}
          |> run([floor_color])
      {m, :output} ->
        paint_color = m.output |> Enum.at(0)
        {m, :output} = m |> Machine.run([])  # get another output
        turn_dir = m.output |> Enum.at(0)
        %{r| m: m}
          |> paint(paint_color)
          |> turn(turn_dir)
          |> walk_forward()
          |> run([])
      {m, :stopped} -> r
    end    
  end

  def paint(r, color) do
    %{r|
      floor: r.floor |> Map.set({r.x, r.y}, color),
      paint_path: r.paint_path ++ [{{r.x, r.y}, color}],
    }
  end

  def turn(r, 0) do r |> turn_ccw(1) end
  def turn(r, 1) do r |> turn_ccw(3) end  # Turning right is like turning left 3 times.
  defp turn_ccw(r, 0) do r end
  defp turn_ccw(r, times) when times > 0 do
    %{r|
      dir: case r.dir do
        :dir_up -> :dir_left
        :dir_left -> :dir_down
        :dir_down -> :dir_right
        :dir_right -> :dir_up
      end
    } |> turn_ccw(times-1)
  end
  
  def walk_forward(r) do
    {dx, dy} = walk_vec(r.dir)
    %{r|
      x: r.x + dx,
      y: r.y + dy,
    }
  end
  defp walk_vec(:dir_up) do {0, 1} end
  defp walk_vec(:dir_right) do {1, 0} end
  defp walk_vec(:dir_down) do {0, -1} end
  defp walk_vec(:dir_left) do {-1, 0} end

end

defmodule Problem11 do
  defstruct [:robot]

  def part1(prog_list, input \\ []) do
    p = %{
      robot: Robot.new(prog_list),     
    }
    |> Robot.run([])
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

  test "robot movement" do
    r = Robot.new([])
    assert r.dir == :dir_up
    r = r |> Robot.turn(0)
    assert r.dir == :dir_left
    r = r |> Robot.turn(1)
    assert r.dir == :dir_up
    assert {r.x, r.y} == {0, 0}
    r = r |> Robot.walk_forward
    assert {r.x, r.y} == {0, 1}
    r = r |> Robot.turn(1)
    assert r.dir == :dir_right
    r = r |> Robot.walk_forward
    r = r |> Robot.walk_forward
    assert {r.x, r.y} == {2, 1}



  end
end
