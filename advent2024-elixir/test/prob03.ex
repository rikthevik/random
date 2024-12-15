

defmodule Prob do
  def evaluate_mul([_, l, r]) do
    String.to_integer(l) * String.to_integer(r)
  end

  def run1(s) do
    ~r/mul\((\d+),(\d+)\)/
    |> Regex.scan(s)
    |> Enum.map(&evaluate_mul/1)
    |> Enum.sum()
  end

  def run2(rows) do

  end
end

defmodule Parse do
  def rows(s) do
    s
  end

  def make_row(s) do

  end

end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
    xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
 """
    assert 161 == input
    |> Parse.rows()
    |> Prob.run1()

    # assert 31 == input
    # |> Parse.rows()
    # |> Prob.run2()
  end

  test "part1" do
    assert 189600467 == File.read!("test/input03.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  # test "part2" do
  #   assert 20373490 == File.read!("test/input01.txt")
  #   |> Parse.rows()
  #   |> Prob.run2()
  # end


end
