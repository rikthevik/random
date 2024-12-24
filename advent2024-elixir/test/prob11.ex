

defmodule Prob do
  def split_int_str(s) do
    mid = String.length(s) |> div(2)
    {l, r} = String.split_at(s, mid)
    [String.to_integer(l), String.to_integer(r)]
  end

  def rule(0) do 1 end
  def rule(i) do
    s = Integer.to_string(i)
    if rem(String.length(s), 2) == 0 do
      split_int_str(s)
    else
      i * 2024
    end
  end

  def p1_go_wrapper(iter, rows) do
    result = p1_go(rows)

    # result
    # |> List.flatten()
    # |> Enum.map(&Integer.to_string/1)
    # |> Enum.join(" ")
    # |> IO.inspect(label: "after iter=#{iter}")

    result
  end

  def p1_go([]) do
    []
  end
  def p1_go(l) when is_list(l) do
    l |> Enum.map(&p1_go/1)
  end
  def p1_go(a) do
    rule(a)
  end

  def evaluate_tree(l) when is_list(l) do
    l
    |> Enum.map(&evaluate_tree/1)
    |> Enum.sum()
  end
  def evaluate_tree(i) do i end

  def run1(rows, iterations) do
    rows
    |> IO.inspect(label: "start")

    tree = 1..iterations
    |> Enum.reduce(rows, &p1_go_wrapper/2)

    tree
    |> List.flatten()
    |> Enum.count()
  end



  def run2(rows) do

  end
end

defmodule Parse do
  def rows(s) do
    s
    |> String.trim()
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
  end
end



defmodule Tests do
  use ExUnit.Case

  test "functions" do
    assert [253, 0] = Prob.split_int_str("253000")
  end

  test "example1" do
    input = """
125 17
"""
    assert 22 == input
    |> Parse.rows()
    |> Prob.run1(6)

    assert 55312 == input
    |> Parse.rows()
    |> Prob.run1(25)

    # assert 31 == input
    # |> Parse.rows()
    # |> Prob.run2()
  end

  test "part1" do
    assert 193269 == File.read!("test/input11.txt")
    |> Parse.rows()
    |> Prob.run1(25)
  end

#   test "part2" do
#     assert 20373490 == File.read!("test/input11.txt")
#     |> Parse.rows()
#     |> Prob.run2()
#   end


end
