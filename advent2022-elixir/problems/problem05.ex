
defmodule Util do
  def transpose(rows) do
    rows
    |> Enum.map(&String.graphemes/1)
    |> List.zip
    |> Enum.map(&Tuple.to_list/1)
  end
end
defmodule Part1 do
  def do_chunk(%{num: 0}, stacks) do stacks end
  def do_chunk(move, stacks) do
    [item|new_from] = stacks[move.from]
    new_to = [item|stacks[move.to]]
    new_stacks = stacks
    |> Map.put(move.from, new_from)
    |> Map.put(move.to, new_to)
    do_chunk(%{move| num: move.num-1}, new_stacks)
  end

  def do_move([], stacks) do stacks end
  def do_move([move|moves], stacks) do
    new_stacks = do_chunk(move, stacks)
    do_move(moves, new_stacks)
  end

  def run({stacks, moves}) do
    moves
    |> do_move(stacks)
    |> Enum.map(fn {_, stack} -> List.first(stack) end)
    |> Enum.join()
  end
end

defmodule Part2 do
  def do_chunk(move, stacks) do
    {moving, new_from} = stacks[move.from] |> Enum.split(move.num)
    new_to = moving
    |> Enum.concat(stacks[move.to])

    new_stacks = stacks
    |> Map.put(move.from, new_from)
    |> Map.put(move.to, new_to)
  end

  def do_move([], stacks) do stacks end
  def do_move([move|moves], stacks) do
    new_stacks = do_chunk(move, stacks)
    do_move(moves, new_stacks)
  end

  def run({stacks, moves}) do
    moves
    |> do_move(stacks)
    |> Enum.map(fn {_, stack} -> List.first(stack) end)
    |> Enum.join()
  end
end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
  end

  def parse_stacks(stack_lines) do
    stack_lines
    |> Util.transpose()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.filter(fn [s|_] -> Regex.match?(~r/^\d$/, s) end)
    |> Enum.map(fn [num|vals] -> {String.to_integer(num),
      vals
      |> Enum.filter(fn s -> s != " " end)
      |> Enum.reverse()}   # top of the stack is the first item
    end)
    |> Map.new
  end

  def parse_moves(lines) do
    lines
    |> Enum.drop(1)
    |> Enum.map(&parse_move/1)
  end

  def parse_move(line) do
    m = Regex.named_captures(~r/move (?<num>\d+) from (?<from>\d) to (?<to>\d)/, line)\
    |> Enum.map(fn {k, v} -> {String.to_atom(k), String.to_integer(v)} end)
    |> Map.new
  end

  def prepare(input) do
    lines = input
    |> String.split(~r/\n/)

    {stack_lines, move_lines} = lines
    |> Enum.split(Enum.find_index(lines, fn a -> a == "" end))

    {stack_lines |> parse_stacks(), move_lines |> parse_moves()}
  end

  test "example" do
    input = File.read!("./inputs/p5example.txt")
    assert "CMZ" == input |> prepare |> Part1.run
    assert "MCD" == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p5input.txt")
    assert "RNZLFZSJH" == input |> prepare |> Part1.run
    assert "CNSFCGJSM" == input |> prepare |> Part2.run
  end
end
