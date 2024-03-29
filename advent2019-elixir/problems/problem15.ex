
# This was untracked and I have no idea where I left this.


defmodule Util do
  # :math.pow() is all about floats and i don't want to convert back
  # and this looks like CMPT 340 homework  :)
  def ipow(_i, 0) do 1 end
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
  def read(_m, val, :immediate) do
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
        # Is it this easy?
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

  


defmodule Problem do
  defstruct [:m, :score, :screen, :ballx, :bally, :paddlex, :paddley]

  def process_chunk(p, [-1, 0, score]) do 
    %{p| score: score}
  end
  def process_chunk(p, [x, y, 3]) do
    # " SET PADDLE = #{x},#{y}" |> IO.puts
    %{p| paddlex: x, paddley: y}
    |> add_to_screen({x, y}, 3)
  end
  def process_chunk(p, [x, y, 4]) do
    # " SET BALL = #{x},#{y}" |> IO.puts
    %{p| ballx: x, bally: y}
    |> add_to_screen({x, y}, 4)
  end
  def process_chunk(p, [x, y, v]) when 0 <= v and v <= 2 do
    p
    |> add_to_screen({x, y}, v)
  end

  def add_to_screen(p, {x, y}, v) do
    %{p|
      screen: p.screen |> Map.put({x, y}, v)
    }
  end

  def process_output(p) do
    output_chunks = p.m.output |> Enum.reverse |> Enum.chunk_every(3)
    p = %{p| 
      m: %{p.m| output: []}  # clear the output
    } |> process_chunks(output_chunks)
    draw_screen(p.screen)
    " SCORE: #{p.score}" |> IO.puts
    :timer.sleep(5)
    p
  end
  def process_chunks(p, []) do p end
  def process_chunks(p, [chunk|chunks]) do
    process_chunks(process_chunk(p, chunk), chunks)
  end

  def draw_screen(screen) do
    {minx, maxx} = screen |> Enum.map(fn {{x, _y}, _v} -> x end) |> Enum.min_max
    {miny, maxy} = screen |> Enum.map(fn {{_x, y}, _v} -> y end) |> Enum.min_max
    for y <- miny..maxy do
      for x <- minx..maxx do
        screen_char(Map.get(screen, {x, y})) |> IO.write
      end
      IO.puts ""
    end
  end

  def screen_char(nil) do " " end  # ???
  def screen_char(0) do "." end    # empty
  def screen_char(1) do "o" end    # wall
  def screen_char(2) do "w" end    # block
  def screen_char(3) do "-" end    # horiz paddle
  def screen_char(4) do "@" end    # ball

  def part1(prog_list) do  
    m = prog_list
    |> Machine.new("bintento")
    |> Machine.run_until_stop
    
    p = %Problem{
      m: m,
      screen: Map.new,
    }
    p = process_output(p)
    p.screen
    |> Enum.filter(fn {{_x, _y}, v} -> v == 2 end)
    |> Enum.count
  end

  def part2(prog_list) do  
    # set the free play
    prog_list = [2|Enum.slice(prog_list, 1..Enum.count(prog_list))]

    m = prog_list
    |> Machine.new("bintento")
    
    output = m.output |> Enum.reverse
    p = %Problem{
      m: m,
      screen: Map.new,
      score: 0,
    }
    p2 = frame(p, [])
    p2.score |> IO.inspect
  end

  def frame(p, input) do
    
    case Machine.run(p.m, input) do
      {m, :output} ->
        frame(%{p| m: m}, [])
      {m, :input} -> 
        p = %{p| m: m} |> process_output
        joy_input = joystick_input(p.paddlex, p.ballx)
        # "supplying paddlex=#{p.paddlex} ballx=#{p.ballx} joystick_input=#{inspect joy_input}" |> IO.puts
        frame(p, joy_input)
      {m, :stopped} ->
        %{p| m: m} |> process_output
    end
  end

  def joystick_input(paddlex, ballx) when paddlex > ballx do [-1] end
  def joystick_input(paddlex, ballx) when paddlex < ballx do [+1] end
  def joystick_input(paddlex, ballx) when paddlex == ballx do [0] end
  
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


  test "go time" do
    prog_list = "1,380,379,385,1008,2151,871073,381,1005,381,12,99,109,2152,1102,1,0,383,1101,0,0,382,21001,382,0,1,20102,1,383,2,21102,37,1,0,1106,0,578,4,382,4,383,204,1,1001,382,1,382,1007,382,36,381,1005,381,22,1001,383,1,383,1007,383,21,381,1005,381,18,1006,385,69,99,104,-1,104,0,4,386,3,384,1007,384,0,381,1005,381,94,107,0,384,381,1005,381,108,1106,0,161,107,1,392,381,1006,381,161,1102,1,-1,384,1106,0,119,1007,392,34,381,1006,381,161,1101,0,1,384,21002,392,1,1,21102,1,19,2,21102,0,1,3,21102,1,138,0,1106,0,549,1,392,384,392,20101,0,392,1,21102,19,1,2,21102,3,1,3,21101,161,0,0,1106,0,549,1101,0,0,384,20001,388,390,1,21001,389,0,2,21102,1,180,0,1105,1,578,1206,1,213,1208,1,2,381,1006,381,205,20001,388,390,1,20101,0,389,2,21102,205,1,0,1105,1,393,1002,390,-1,390,1101,1,0,384,20102,1,388,1,20001,389,391,2,21101,228,0,0,1105,1,578,1206,1,261,1208,1,2,381,1006,381,253,21002,388,1,1,20001,389,391,2,21101,0,253,0,1105,1,393,1002,391,-1,391,1101,1,0,384,1005,384,161,20001,388,390,1,20001,389,391,2,21102,1,279,0,1105,1,578,1206,1,316,1208,1,2,381,1006,381,304,20001,388,390,1,20001,389,391,2,21102,304,1,0,1105,1,393,1002,390,-1,390,1002,391,-1,391,1102,1,1,384,1005,384,161,21002,388,1,1,20101,0,389,2,21102,0,1,3,21101,338,0,0,1106,0,549,1,388,390,388,1,389,391,389,21001,388,0,1,20102,1,389,2,21101,0,4,3,21102,1,365,0,1105,1,549,1007,389,20,381,1005,381,75,104,-1,104,0,104,0,99,0,1,0,0,0,0,0,0,180,16,16,1,1,18,109,3,22101,0,-2,1,21201,-1,0,2,21102,1,0,3,21101,414,0,0,1105,1,549,22102,1,-2,1,21201,-1,0,2,21102,429,1,0,1106,0,601,1202,1,1,435,1,386,0,386,104,-1,104,0,4,386,1001,387,-1,387,1005,387,451,99,109,-3,2105,1,0,109,8,22202,-7,-6,-3,22201,-3,-5,-3,21202,-4,64,-2,2207,-3,-2,381,1005,381,492,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,481,21202,-4,8,-2,2207,-3,-2,381,1005,381,518,21202,-2,-1,-1,22201,-3,-1,-3,2207,-3,-2,381,1006,381,507,2207,-3,-4,381,1005,381,540,21202,-4,-1,-1,22201,-3,-1,-3,2207,-3,-4,381,1006,381,529,22101,0,-3,-7,109,-8,2106,0,0,109,4,1202,-2,36,566,201,-3,566,566,101,639,566,566,1201,-1,0,0,204,-3,204,-2,204,-1,109,-4,2106,0,0,109,3,1202,-1,36,593,201,-2,593,593,101,639,593,593,21001,0,0,-2,109,-3,2105,1,0,109,3,22102,21,-2,1,22201,1,-1,1,21101,383,0,2,21101,0,250,3,21101,756,0,4,21101,630,0,0,1106,0,456,21201,1,1395,-2,109,-3,2105,1,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,2,2,0,2,0,0,0,0,0,0,2,2,0,2,2,0,2,2,0,0,2,2,2,0,0,0,0,2,2,2,0,1,1,0,0,0,0,2,0,2,2,0,0,2,2,0,0,2,2,0,0,2,2,2,2,0,2,0,2,2,2,2,0,2,0,0,0,1,1,0,0,2,2,0,0,0,0,0,0,2,2,2,0,0,0,0,0,2,0,2,0,0,0,0,0,2,0,2,2,0,2,0,0,1,1,0,0,0,2,0,0,0,2,0,0,0,0,0,0,0,2,0,0,2,0,2,0,0,0,0,0,0,0,2,2,2,0,2,0,1,1,0,0,2,2,2,2,0,0,0,0,0,0,0,0,0,2,0,0,0,2,2,0,0,0,2,0,0,0,2,0,2,2,2,0,1,1,0,0,0,0,2,2,2,2,2,0,2,0,0,0,0,2,0,2,0,2,0,2,0,0,2,2,0,2,0,2,0,2,0,0,1,1,0,2,2,0,2,2,2,2,0,2,2,2,2,0,0,2,0,0,2,0,2,0,0,0,2,0,0,2,2,2,0,0,0,0,1,1,0,0,2,0,0,2,2,0,0,0,0,2,2,0,0,2,0,0,0,2,2,0,2,0,2,2,0,2,2,0,0,0,2,0,1,1,0,0,0,0,0,0,0,2,0,0,0,2,0,2,0,0,0,2,2,2,2,0,2,2,0,2,2,0,0,0,2,0,0,0,1,1,0,0,0,0,0,0,0,0,2,2,2,0,0,0,0,2,0,2,0,0,0,0,2,2,0,2,2,2,0,0,2,0,2,0,1,1,0,0,0,0,2,2,0,2,2,0,2,0,2,2,2,0,0,2,2,0,0,0,0,0,0,2,0,2,2,2,0,2,2,0,1,1,0,2,0,0,2,0,0,0,0,0,2,0,0,2,2,0,2,2,2,0,2,2,0,0,2,2,0,0,2,2,0,0,2,0,1,1,0,2,0,2,0,2,0,2,0,0,2,2,0,0,2,0,0,0,2,0,2,2,0,2,0,0,0,2,0,2,2,0,2,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,52,20,53,45,54,10,5,35,28,96,68,78,29,94,94,57,42,27,61,91,60,22,54,59,33,71,63,62,97,30,76,40,87,10,30,83,68,41,63,55,24,65,56,57,21,91,17,7,60,94,34,54,75,10,16,88,32,34,41,36,57,39,14,89,23,47,7,94,89,60,56,36,44,77,29,17,93,55,58,62,61,18,50,54,22,75,45,1,29,64,32,97,98,50,37,64,39,61,23,39,61,85,85,10,37,56,84,13,43,91,20,73,77,34,87,33,36,42,48,3,39,6,18,58,38,63,48,38,96,32,72,51,22,37,76,4,95,17,3,79,89,19,12,22,71,98,95,22,82,31,70,98,48,46,6,80,95,98,1,81,27,91,14,98,13,46,21,6,75,59,73,9,52,6,44,92,9,11,65,71,19,52,84,71,38,60,43,10,78,25,22,27,90,4,23,96,19,42,54,80,63,64,26,29,58,75,35,95,38,48,1,47,61,20,74,39,85,33,10,70,90,39,93,61,9,65,19,56,84,59,57,30,76,19,52,66,89,93,19,86,4,67,59,37,28,71,1,21,40,18,92,72,57,63,88,42,17,92,42,88,93,17,19,26,63,31,1,8,76,62,31,49,36,18,19,63,50,50,13,77,22,45,11,92,7,92,69,66,49,34,2,58,61,4,18,26,20,7,51,84,81,38,72,22,83,92,16,97,20,81,25,74,13,84,71,2,81,35,83,6,73,93,60,47,2,98,27,55,68,59,67,63,61,48,65,28,71,56,39,30,93,96,3,47,93,77,11,28,86,79,90,83,39,21,68,2,49,50,78,68,81,97,49,9,44,79,31,69,81,76,93,17,31,66,46,26,18,1,17,72,1,28,47,15,85,50,95,75,52,86,5,35,59,51,41,88,33,9,7,77,1,46,6,40,39,36,52,10,12,34,87,64,13,23,96,15,89,13,64,65,29,27,28,50,57,91,68,97,5,38,57,28,45,6,10,90,7,26,79,89,93,74,77,58,51,86,75,49,80,80,28,94,11,56,36,69,88,50,10,22,77,51,83,47,53,2,46,33,45,44,23,4,28,62,21,88,61,58,72,16,4,6,47,25,37,46,72,65,74,9,69,60,62,39,82,63,17,4,79,43,68,80,17,20,20,49,59,70,5,3,69,44,95,38,90,11,98,76,36,59,80,74,85,1,46,19,97,14,89,96,14,65,68,13,90,13,46,24,39,63,73,84,46,66,92,84,56,86,44,33,23,6,91,13,25,75,76,31,68,4,40,83,51,85,70,84,27,71,40,53,75,59,77,79,98,90,33,94,63,19,65,44,90,18,71,17,72,40,32,16,43,16,55,28,93,76,68,40,25,1,11,79,42,49,46,80,14,41,75,10,84,67,94,91,83,51,41,78,57,75,10,71,33,47,69,34,5,81,26,82,39,51,55,38,23,2,87,54,45,3,34,44,65,54,5,74,3,51,18,42,37,52,20,57,80,66,91,66,62,38,56,36,77,18,27,55,97,43,53,25,92,14,55,87,91,81,33,65,12,18,76,21,77,90,40,35,36,30,87,32,12,86,10,93,49,12,25,44,15,37,11,57,2,2,16,21,58,35,77,26,15,86,49,62,57,90,8,10,81,35,85,25,76,76,61,40,69,9,34,59,29,16,71,41,61,87,62,17,37,51,14,59,67,66,65,87,4,85,82,98,48,17,9,92,12,71,871073"
    |> prepare_prog_string

    # Holy shit it worked...
    assert 180 == Problem.part1(prog_list)
    assert 8777 = Problem.part2(prog_list)


  end


end
