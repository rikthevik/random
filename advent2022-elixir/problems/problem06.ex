
defmodule Util do

end

defmodule Part1 do
  def chunk([a, b, c, d|rest], idx) do
    if a != b and a != c and a != d and b != c and b != d and c != d do
      idx + 4
    else
      chunk([b, c, d|rest], idx+1)
    end
  end
  def chunk(_, idx) do idx end

  def run(input) do
    input
    |> chunk(0)
  end
end

defmodule Part2 do
  # Let's do this inefficiently...
  def chunk(l = [_|rest], idx) do
    set_size = l
    |> Enum.slice(0, 14)
    |> MapSet.new()
    |> MapSet.size()

    if set_size != 14 do
      chunk(rest, idx+1)
    else
      idx + 14
    end

  end

  def run(input) do
    input
    |> chunk(0)
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
    |> List.first()
    |> String.graphemes()
  end

  test "examples" do
    assert 5 == "bvwbjplbgvbhsrlpgdmjqwftvncz" |> prepare |> Part1.run
    assert 6 == "nppdvjthqldpwncqszvftbrmjlhg" |> prepare |> Part1.run
    assert 10 == "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" |> prepare |> Part1.run
    assert 11 == "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" |> prepare |> Part1.run
  end

  test "examples2" do
    assert 19 == "mjqjpqmgbljsphdztnvjfqwrcgsmlb" |> prepare |> Part2.run
    assert 23 == "bvwbjplbgvbhsrlpgdmjqwftvncz" |> prepare |> Part2.run
    assert 23 == "nppdvjthqldpwncqszvftbrmjlhg" |> prepare |> Part2.run
    assert 29 == "nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg" |> prepare |> Part2.run
    assert 26 == "zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw" |> prepare |> Part2.run
  end


  test "gotime" do
    input = ProblemInputs.problem06()
    assert 1647 == input |> prepare |> Part1.run
    assert 2447 == input |> prepare |> Part2.run
  end

end
