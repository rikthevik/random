
# stolen from
#  https://elixir-lang.org/getting-started/processes.html#state
defmodule Global do
  def start_link() do
    {:ok, pid} = Task.start_link(fn -> loop(%{}) end)
    Process.register(pid, :global)
  end

  defp loop(map) do
    receive do
      {:get, key, caller} ->
        retval = Map.get(map, key)
        # "GET F(#{inspect key}) => #{inspect retval}" |> IO.puts
        send caller, retval
        loop(map)
      {:all, caller} ->
        send caller, map
        loop(map)
      {:put, key, value} ->
        # "SET F(#{inspect key}) := #{inspect value}" |> IO.puts
        loop(Map.put(map, key, value))
      {:reset} ->
        loop(Map.new())
    end
  end

  def put(k, v) do
    send :global, {:put, k, v}
  end

  def get(k) do
    send :global, {:get, k, self()}
    receive do v -> v end
  end

  def all() do
    send :global, {:all, self()}
    receive do v -> v end
  end

  def reset() do
    send :global, {:reset}
  end
end

defmodule Util do

end

defmodule Part1 do
  def read_lines_intro(lines) do
    read_lines_wrap(lines, [], Map.new())
  end

  def read_lines_wrap([l|lines], stack, db) do
    # {l, stack} |> IO.inspect
    read_lines([l|lines], stack, db)
  end
  def read_lines_wrap(lines, stack, db) do
    read_lines(lines, stack, db)
  end

  def read_lines([], _, db) do db end
  def read_lines([["$", "cd", ".."]|lines], [_|popped_stack], db) do
    read_lines_wrap(lines, popped_stack, db)
  end
  def read_lines([["$", "cd", "/"]|lines], _stack, db) do
    read_lines_wrap(lines, [], db)
  end
  def read_lines([["$", "cd", dir]|lines], stack, db) do
    read_lines_wrap(lines, [dir|stack], db)
  end
  def read_lines([["$", "ls"]|lines], stack, db) do
    read_lines_wrap(lines, stack, db)
  end
  def read_lines([["dir", dir]|lines], stack, db) do
    contents = Map.get(db, stack, [])
    row = {:dir, dir}
    new_contents = [row|contents]
    new_db = Map.put(db, stack, new_contents)
    read_lines_wrap(lines, stack, new_db)
  end
  def read_lines([[size_str, filename]|lines], stack, db) do
    contents = Map.get(db, stack, [])
    row = {:file, filename, String.to_integer(size_str)}
    new_contents = [row|contents]
    new_db = Map.put(db, stack, new_contents)
    read_lines_wrap(lines, stack, new_db)
  end

  def print_traverse(db, stack, depth) do
    dir_size = for item <- Map.get(db, stack) do

      for i <- 0..depth do
        IO.write " "
      end
      # IO.inspect(item)

      case item do
        {:dir, dir} ->
          print_traverse(db, [dir|stack], depth+1)
        {:file, filename, size} ->
          size
      end
    end
    |> Enum.sum()

    Global.put(stack, dir_size)
    dir_size
  end

  def run(rows) do
    db = rows
    |> read_lines_intro()
    # |> IO.inspect()

    db
    |> print_traverse([], 0)

    Global.all()
    # |> IO.inspect(label: "cache")
    |> Enum.filter(fn {_, size} -> size < 100_000 end)
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.sum()
  end

  def run2(rows) do
    db = rows
    |> read_lines_intro()
    # |> IO.inspect()

    db
    |> print_traverse([], 0)

    total_avail = 70_000_000
    min_unused = 30_000_000
    total_used = Global.get([])
    total_unused = total_avail - total_used
    to_delete = min_unused - total_unused
    |> IO.inspect(label: "to_delete")

    Global.all()
    # |> IO.inspect(label: "cache")
    |> Enum.filter(fn {_, size} -> size > to_delete end)
    |> Enum.map(fn {_, size} -> size end)
    |> Enum.sort()
    |> List.first()
  end
 end

defmodule Part2 do
  def run(rows) do
    rows
    |> IO.inspect()
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
    |> String.split(~r/ +/)
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  setup do
    Global.start_link()
    :ok
    # on_exit(fn -> Global.reset() end)
  end



  test "example" do
    input = File.read!("./inputs/p7example.txt")
    IO.puts "\n"
    assert 95437 == input |> prepare |> Part1.run
  end

  test "example2" do
    input = File.read!("./inputs/p7example.txt")
    IO.puts "\n"
    assert 24933642 == input |> prepare |> Part1.run2
  end

  test "go time" do
    input = File.read!("./inputs/p7input.txt")
    IO.puts "\n"
    assert 1667443 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end

  test "go time2" do
    input = File.read!("./inputs/p7input.txt")
    IO.puts "\n"
    assert 1667443 == input |> prepare |> Part1.run2
  end
end
