
defmodule Util do

end

defmodule Prob do
  def new(rows) do
    rows
    |> Map.new()
  end

  def traverse(p, curr) do
    traverse_inner(p, Map.get(p, curr))
  end
  def traverse_inner(_p, num) when is_integer(num) do num end
  def traverse_inner(p, {left, op, right}) do
    perform_op(traverse(p, left), op, traverse(p, right))
  end

  def perform_op(lval, "+", rval) do lval + rval end
  def perform_op(lval, "-", rval) do lval - rval end
  def perform_op(lval, "*", rval) do lval * rval end
  def perform_op(lval, "/", rval) do div(lval, rval) end
end

defmodule Part1 do
  def run(rows) do
    rows
    |> Prob.new()
    |> IO.inspect()
    |> Prob.traverse("root")
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

  def parse_row([from, num]) do {from, String.to_integer(num)} end
  def parse_row([from, left, op, right]) do {from, {left, op, right}} end
  def prepare_row(s) do
    s
    |> String.split(~r/:? +/)
    |> parse_row()
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "root: pppw + sjmn
    dbpl: 5
    cczh: sllz + lgvd
    zczc: 2
    ptdq: humn - dvpt
    dvpt: 3
    lfqf: 4
    humn: 5
    ljgn: 2
    sjmn: drzm * dbpl
    sllz: 4
    pppw: cczh / lfqf
    lgvd: ljgn * ptdq
    drzm: hmdt - zczc
    hmdt: 32"
    assert 152 == input |> prepare |> Part1.run
    # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    # input = "122"
    # assert 7 == input |> prepare |> Part1.run
    # assert 7 == input |> prepare |> Part2.run
  end
end
