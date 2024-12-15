

defmodule Prob do
  def run1(rows) do

  end

  def run2(rows) do

  end
end

defmodule Parse do
  def rows(s) do

  end

  def make_row(s) do

  end

end



defmodule Tests do
  use ExUnit.Case

  test "example1" do
    input = """
 """
    assert 11 == input
    |> Parse.rows()
    |> Prob.run1()

    assert 31 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 1722302 == File.read!("test/input01.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 20373490 == File.read!("test/input01.txt")
    |> Parse.rows()
    |> Prob.run2()
  end


end
