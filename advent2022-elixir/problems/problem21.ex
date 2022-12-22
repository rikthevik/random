
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
  def traverse_inner(_p, "humn") do "humn" end
  def traverse_inner(p, {left, op, right}) do
    perform_op(traverse(p, left), op, traverse(p, right))
  end

  def perform_op(left, op, rval) when not is_integer(left) do {left, op, rval} end
  def perform_op(lval, op, right) when not is_integer(right) do {lval, op, right} end
  def perform_op(lval, "+", rval) do lval + rval end
  def perform_op(lval, "-", rval) do lval - rval end
  def perform_op(lval, "*", rval) do lval * rval end
  def perform_op(lval, "/", rval) do div(lval, rval) end

  def equalize({left, "=", num}) when is_integer(num) do equalize_inner(left, num) end
  def equalize({num, "=", right}) when is_integer(num) do equalize_inner(right, num) end

  def equalize_inner("humn", eq) do eq end
  def equalize_inner({left, "/", rval}, eq) when is_integer(rval) do
    # l / r = e, l = e * r
    equalize_inner(left, eq * rval)
  end
  # Hmm, it doesn't use this case.  It seems right to me...
  # def equalize_inner({lval, "/", right}, eq) when is_integer(lval) do
  #   equalize_inner(right, div(lval, eq))
  # end
  def equalize_inner({left, "+", rval}, eq) when is_integer(rval) do
    equalize_inner(left, eq - rval)
  end
  def equalize_inner({lval, "+", right}, eq) when is_integer(lval) do
    equalize_inner(right, eq - lval)
  end
  def equalize_inner({left, "*", rval}, eq) when is_integer(rval) do
    equalize_inner(left, div(eq, rval))
  end
  def equalize_inner({lval, "*", right}, eq) when is_integer(lval) do
    equalize_inner(right, div(eq, lval))
  end
  def equalize_inner({left, "-", rval}, eq) when is_integer(rval) do
    # l - r = e, l = e + r
    equalize_inner(left, eq + rval)
  end
  def equalize_inner({lval, "-", right}, eq) when is_integer(lval) do
    # l - r = e, r = e - l   # tricky case
    equalize_inner(right, lval - eq)
  end

end

defmodule Part1 do
  def run(rows) do
    # The first part is basically a tree traversal.  Rather than
    # building a proper tree structure, the "tree" is just
    # {from->to} pairs in a map.  I guess I could have folded that
    # out into a recursive tree structure.
    rows
    |> Prob.new()
    |> Prob.traverse("root")
  end
end

defmodule Part2 do
  def run(rows) do
    p = rows
    |> Prob.new()

    {left, _op, right} = Map.get(p, "root")

    # So the part 2 approach is to leave the half of the tree
    # with "humn" in it unevaluated.  We'll have a single number
    # on one side and huge tree on the other.  Then we can perform
    # inverse operations on the number we're trying to equalize to.
    # I feel like I could have returned a new tree of all inverse
    # operations, but this works, it's not too crazy to read and
    # it's fast.  Good enough for me.
    p
    |> Map.put("humn", "humn")
    |> Map.put("root", {left, "=", right})
    |> Prob.traverse("root")
    |> Prob.equalize()

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
    assert 301 == input |> prepare |> Part2.run
  end

  test "go time" do
    input = File.read!("./inputs/p21input.txt")
    assert 85616733059734 == input |> prepare |> Part1.run
    assert 3560324848168 == input |> prepare |> Part2.run
  end
end
