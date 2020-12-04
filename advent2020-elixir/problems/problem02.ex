
defmodule Util do
  def frequencies(s) do
    String.graphemes(s) |> Enum.frequencies
  end

end


defmodule Problem01 do
  def is_valid(pwline) do
    pwline |> IO.inspect
    freq = Util.frequencies(pwline.s)[pwline.c]
    |> IO.inspect
    freq >= pwline.lo and freq <= pwline.hi
  end

  def part1(pwlines) do
    pwlines
    |> Enum.filter(&is_valid/1)
    |> IO.inspect
    |> Enum.count
  end
end

defmodule Tests do 
  use ExUnit.Case

  def build(capture) do
    m = capture |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end) |> Map.new
    %{m|
      lo: m.lo |> String.to_integer,
      hi: m.hi |> String.to_integer
    }
  end

  def prepare(input) do
    regex = ~r/^(?<lo>\d+)-(?<hi>\d+) (?<c>.): (?<s>\w+)$/
    input
    |> String.trim
    |> String.split("\n")
    |> Enum.map(fn s -> Regex.named_captures(regex, s) |> build end)
    |> IO.inspect
    
    # |> IO.inspect
    # |> Map.new
  end

  test "frequencies" do
    assert 3 == Util.frequencies("ccc")["c"]
    assert 1 == Util.frequencies("abc")["c"]
  end

  test "example" do
    pwlines = "1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc"
    |> prepare() 
    pwlines |> IO.inspect
    assert Problem01.part1(pwlines) == 2
  end

  test "part1" do
    pwlines = "1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc"
    |> prepare() 
    pwlines |> IO.inspect
    assert Problem01.part1(pwlines) == 2
  end

end
