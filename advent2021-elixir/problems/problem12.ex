
defmodule Util do
  def is_small?(s) do
    Regex.match?(~r/^[a-z]+$/, s)
  end
end

defmodule Path2 do
  defstruct [:m, :l]
  def new() do
    %Path2{
      m: Map.new,
      l: [],
    }
  end

  def add(p, next) do
    freq = Map.get(p.m, next, 0) + 1
    %Path2{
      m: if Util.is_small?(next) do Map.put(p.m, next, freq) else p.m end,
      l: [next|p.l]
    }
  end

  def is_valid_path?(p) do
    retval = (Enum.count(p.m, fn {_, freq} -> freq == 2 end) <= 1
      and Enum.count(p.m, fn {_, freq} -> freq > 2 end) == 0)
    # IO.inspect(p, label: "is_valid_path? #{retval}")
    retval
  end
end


defmodule Part1 do
  def run(rows) do
    # [{"WELCOME", "start"}|rows]

    reversed_edges = rows
    |> Enum.filter(fn {from, to} -> to != "end" and from != "start" end)
    |> Enum.map(fn {from, to} -> {to, from} end)

    rows
    |> Enum.concat(reversed_edges)
    |> traverse
  end

  def is_small?(s) do
    Regex.match?(~r/^[a-z]+$/, s)
  end

  def traverse(edges) do
    traverse(edges, "start", [])
    |> List.flatten
    |> Enum.sum
  end

  def traverse(edges, "end", path) do
    # Enum.reverse(["end"|path])
    # |> IO.inspect
    1
  end

  def traverse(edges, curr, path) do
    curr
    # |> IO.inspect(label: "curr")

    nexts = edges
    |> Enum.filter(fn {from, to} -> from == curr end)
    |> Enum.map(fn {from, to} -> to end)
    |> Enum.filter(fn n -> not is_small?(n) or not Enum.member?(path, n) end)
    # |> IO.inspect(label: "next")

    for next <- nexts do
      traverse(edges, next, [curr|path])
    end

  end
end

defmodule Part2 do
  # largely the same, let's just copy and paste

  def run(rows) do
    reversed_edges = rows
    |> Enum.map(fn {from, to} -> {to, from} end)

    paths = rows
    |> Enum.concat(reversed_edges)
    |> Enum.filter(fn {from, to} -> from != "end" and to != "start" end)
    # |> IO.inspect
    |> traverse

    # IO.puts "paths #{Enum.count(paths)}"

    valid_paths = paths
    |> Enum.filter(&Path2.is_valid_path?/1)
    IO.puts "valid_paths #{Enum.count(valid_paths)}"

    valid_paths
    |> Enum.count
  end



  def traverse(edges) do
    traverse(edges, "start", Path2.new)
    # |> IO.inspect
    |> List.flatten
    # |> Enum.sum
  end

  def traverse(_edges, "end", path) do
    # |> IO.inspect
    path
  end

  def traverse(edges, curr, path) do
    if not Path2.is_valid_path?(path) do
      IO.puts "WAT"
      IO.inspect path
      throw :wat
    end

    nexts = edges
    |> Enum.filter(fn {from, to} -> from == curr end)
    |> Enum.map(fn {from, to} -> to end)
    |> Enum.filter(fn n -> (path |> Path2.add(n) |> Path2.is_valid_path?) end)

    for next <- nexts do
      traverse(edges, next, Path2.add(path, next))
    end

  end


end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    [_|[from, to]] = Regex.run(~r/([^\-]+)-([^\-]+)/, s)
    {from, to}
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "pre-example" do
    input = "start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end"
    assert 10 == input |> prepare |> Part1.run
    assert 36 == input |> prepare |> Part2.run
  end


  test "example" do
      input = "dc-end
      HN-start
      start-kj
      dc-start
      dc-HN
      LN-dc
      HN-end
      kj-sa
      kj-HN
      kj-dc"
      assert 19 == input |> prepare |> Part1.run
      assert 103 == input |> prepare |> Part2.run
  end

  test "examples2" do
    input = "fs-end
    he-DX
    fs-he
    start-DX
    pj-DX
    end-zg
    zg-sl
    zg-pj
    pj-he
    RW-he
    fs-DX
    pj-RW
    zg-RW
    start-pj
    he-WI
    zg-he
    pj-fs
    start-RW"
    assert 226 == input |> prepare |> Part1.run
    assert 3509 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = "VJ-nx
    start-sv
    nx-UL
    FN-nx
    FN-zl
    end-VJ
    sv-hi
    em-VJ
    start-hi
    sv-em
    end-zl
    zl-em
    hi-VJ
    FN-em
    start-VJ
    jx-FN
    zl-sv
    FN-sv
    FN-hi
    nx-end"
    assert 5254 == input |> prepare |> Part1.run
    assert 149385 == input |> prepare |> Part2.run
  end
end
