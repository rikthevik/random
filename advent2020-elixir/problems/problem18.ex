
use Bitwise

defmodule Util do
  
end

defmodule Problem do
  
  def try_int(s) do
    case Integer.parse(s) do
      :error -> s
      {val, ""} -> val
    end
  end

  def tokenize(l) do
    l 
    |> String.replace(" ", "")
    |> String.graphemes
    |> Enum.map(&try_int/1)
  end

  def load(inputstr) do
    rows = inputstr
    |> String.trim
    |> String.split("\n")
  end

  def parse(s) do
    tokens = tokenize(s)
    # tokens = tokenize("(" <> s <> ")")
    {[], expr} = parse_tokens(tokens, [])
    expr
    |> Enum.filter(fn i -> i != [] end)
  end
  def parse_tokens([], expr) do {[], expr} end
  def parse_tokens(["("|rest], expr) do
    "( rest=#{inspect rest} acc=#{inspect expr}" |> IO.puts
    {remaining, newexpr} = parse_tokens(rest, [])
    {something, remainingexpr} = parse_tokens(remaining, [])
    # "SOMETHING=#{inspect something}" |> IO.inspect
    {something, expr ++ [newexpr] ++ remainingexpr}
  end
  def parse_tokens([")"|rest], expr) do 
    ") rest=#{inspect rest} acc=#{inspect expr}" |> IO.puts
    # {}
    {rest, expr}
  end
  def parse_tokens([token|rest], expr) do
    "token=#{token} rest=#{inspect rest} acc=#{inspect expr}" |> IO.puts
    parse_tokens(rest, expr ++ [token])
  end
  
  def eval1([token]) do eval1(token) end
  def eval1(token) when is_integer(token) do token end
  def eval1([left, operator, right|rest]) do
    value = case operator do
      "+" -> eval1(left) + eval1(right)
      "*" -> eval1(left) * eval1(right)
    end
    eval1([value|rest])
  end

  def part1(lines) do
    lines
    |> Enum.map(fn l -> l |> parse |> eval1 end)
    |> Enum.sum
  end

end

defmodule Attempt2 do

  def eval([token]) do eval(token) end
  def eval(token) when is_integer(token) do token end
  def eval(tokens) do
    "eval tokens=#{inspect tokens}" |> IO.puts
    # so these would be all of our grammar rules in reverse order of precedence
    if Enum.member?(tokens, "*") do
      {left, ["*"|right]} = tokens |> Enum.split_while(&(&1 != "*"))
      eval(left) * eval(right)
    else
      if Enum.member?(tokens, "+") do
        {left, ["+"|right]} = tokens |> Enum.split_while(&(&1 != "+"))
        eval(left) + eval(right)
      else
        1 = 0
      end
    end
  end


  def part2(lines) do
    lines
    |> Enum.map(fn l -> l |> Problem.parse |> eval end)
    |> Enum.sum
  end


end



defmodule Tests do 
  use ExUnit.Case

  test "example1" do
    assert [1] == "1" |> Problem.parse
    assert 1 == "1" |> Problem.parse |> Problem.eval1
    assert 1 == "(1)" |> Problem.parse |> Problem.eval1
    assert [1, "+", 2] == "1 + 2" |> Problem.parse
    assert 3 == "1 + 2" |> Problem.parse |> Problem.eval1
    assert [1, "+", 2, "*", 3] == "1 + 2 * 3" |> Problem.parse
    assert 9 == "1 + 2 * 3" |> Problem.parse |> Problem.eval1
    assert 5 == "1 * 2 + 3" |> Problem.parse |> Problem.eval1
    assert [1, "+", [2, "*", 3]] == "1 + (2 * 3)" |> Problem.parse
    assert 7 == "1 + (2 * 3)" |> Problem.parse |> Problem.eval1
    assert [[1, "+", 2], "*", 3] == "(1 + 2) * 3" |> Problem.parse
    assert 9 == "(1 + 2) * 3" |> Problem.parse |> Problem.eval1
    assert 71 == "1 + 2 * 3 + 4 * 5 + 6" |> Problem.load |> Problem.part1
  end

  @tag :example2
  test "example2" do
    assert 2 == "1 * 2" |> Problem.load |> Attempt2.part2
    # assert 71 == "1 * 2 + 3 + 4 * 5 + 6" |> Problem.load |> Attempt2.part2
    assert 51 == "1 + (2 * 3) + (4 * (5 + 6))" |> Problem.load |> Attempt2.part2
    assert 46 == "2 * 3 + (4 * 5)" |> Problem.load |> Attempt2.part2
    assert 1445 == "5 + (8 * 3 + 9 + 3 * 4 * 3)" |> Problem.load |> Attempt2.part2
    assert 669060 == "5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))" |> Problem.load |> Attempt2.part2
    assert 23340 == "((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2" |> Problem.load |> Attempt2.part2
  end

  test "go time" do
    inputstr = "2 + (2 + 6 * (4 * 5 * 8 * 7) + 3) * (9 + (4 * 3 * 7 * 9)) * 7
    7 * ((9 + 3 + 2 * 8 + 8 + 6) * 5 * 7 * 4 * 9 * 4) + (2 + 9 * (7 * 8 * 2 + 9 + 7) + 8 + (4 + 9 * 7) * 3) * 4 + 9 * (4 * 8 * 4)
    9 * 2 + (9 * 7 * 4 + 4 * 6 + (8 + 9 + 3 * 3))
    (2 * (2 + 4 * 7 + 8) * 5 * 7) * 6 + 4 + 4
    9 + 7 * (2 * (3 * 3 + 9 + 8 * 4) + 8 * 9) * 6 * 9 + 8
    7 + (9 + 4 * 5 * 4 + 6 + (8 + 7 + 4 + 7 + 6)) + (3 * 7 * 8 * 2) * 3 * 3 + 5
    7 * 2 + (2 + 5 + 4 * 5) + (4 * 2 * 5 * (5 * 2 * 6 * 9)) * (7 + 6 + 5 + (4 * 2 + 4 + 6 + 6) + 9 + 2)
    ((4 * 4 + 4) + 3 * 2) * 3 * 8 + 7 + 8 + 6
    (4 + 8 + 5 + 3 + (8 + 8 + 4)) * 5 + 5 * (9 * 8 * 2 + (4 * 3)) + 7
    2 * 7 + 8 * 3 + 8
    8 + 7 * ((4 + 4 + 3 * 8 + 3) * 7 * 6 * 6 * 2)
    4 + 2 + (6 * 4) * 5 + 7 * 9
    8 * 6 + 9 * (8 + 4) + 3
    9 + 2 + 2 + ((4 + 4 * 8 + 6 * 6 * 5) * 8 * 2) * 9 * (6 + 3)
    (2 * 7 + 7 + 9 + 3) * (3 + 8 + 7) + 4 * (9 + 9 + (2 + 2 + 3 * 5 * 5 * 3) * (6 * 2) + 9) * 3
    (2 + 4 * 6 * (5 * 8) * 2) * 3 * 3 + 3 * 3
    (5 + 4 * (3 * 2 * 9 * 4 + 9) * 4) * 5
    2 * (4 + (7 * 9 * 9) + 8 * (8 * 4 + 5 + 2) + 4) + 7 + (5 * 5 + 7 + (4 * 8 * 5 * 2 * 2)) * (4 + 5 + 4 + 8 + 6) + 4
    4 * 2 * ((6 * 2 * 5) * 8 * (5 + 8 * 7))
    9 * (7 + 2 + 7 * 3) * 6 * 3
    6 * 6 * 8 + 6
    2 * 2 + 8 + 3 * (6 + 3 + (9 + 2 * 3 * 5 * 4 * 2) * 7)
    ((8 * 9) + 6 + (2 + 7 * 9 + 8 + 3 * 8) * 8) + 6 + 6 * (9 * (5 + 7 + 3 + 8 + 8 * 3) + (2 + 4 + 2 + 5) + (2 * 8 * 8 * 9 * 4 * 4) + 3 * 2) + (5 * 7 + 3)
    4 + 6 * 7 * 7 * (9 * (2 + 8) + 3 + 4 * 2 * (2 * 8 + 9 * 9))
    (5 + 3) * (5 * (4 * 4) + (7 * 7 + 7 * 5 + 6) + 3 * (8 + 7 + 4 * 8 + 8 + 5) + 5) * 8 * 9
    (7 * 8 * 3 * 4 + 7 * 3) + 9 * 2 + 7 * (8 * 2 + 8 * 2)
    7 + 5 + 4 + (9 + 7 * 9 * 4) + 2 * 6
    ((3 * 5 + 4) + 3 * 4) + 2 * 3
    8 + (5 * 5 + (2 + 4) + 3 + (5 + 9 + 4) * 6) + ((5 * 7 + 4 + 8 * 2) + 3 * 4) + 5 * (7 * (7 + 2) * (5 + 5) + 5 * (6 * 4 + 8) * (3 * 6 + 5 * 2 * 2 * 3)) + 6
    4 * (7 * 2 * 2 + 7 + 3 + (7 * 4 + 4 + 4)) + 4 + 8 * 5 * 4
    6 + 3 * 7 * ((5 + 9 + 3 * 2 + 5) + (8 * 8 * 4 * 4 * 7 * 2))
    8 + 5 * 8 * 4 * (6 * 5 + 3 * (6 * 3 * 7) * 6)
    ((7 * 5) * (3 * 3 * 5 * 8 + 8) + 4 * (6 * 8 * 6) * 9) + 8 * 7 + 9 * 6
    (2 * 5 * 3 * 3 + 6) + (8 * 4 + (2 + 3 * 8) * 6) + 2 + 5
    (5 + 2 * 6 * 7 * 3 * 7) + (7 + (3 + 2))
    6 + (8 + 7 + 5 + (2 * 5 + 4 + 5 * 7 * 3) * 7) * 7 * 5
    4 + 4 + 4 * 6 * 2 * 5
    4 + (3 * (3 * 2 * 5 * 8 * 3)) + 5 * 9
    8 + 6 + (2 + 2 * 7 + 3)
    5 * 6 * 5 + 5
    (7 * 2 * 8 * 6 + 7) * 9 + 9
    5 + 3 + (5 * (7 * 5)) * (7 + 2 * 3 + (3 * 6 + 3) * 3) + 6 + 4
    (5 + (9 + 5 + 7 + 3 + 9 * 8) + 4 + 5 * 9) * 4 * 5
    4 + ((9 * 6 + 8) * 6 * (8 + 9 + 3) * 8) * 9
    2 + (9 + (9 * 9 + 3 * 3)) + 3 + 6
    4 * ((8 + 6 * 5 + 5) * 3 + 2 + 2) * ((9 * 9) * 5)
    8 * ((2 + 6 * 3) * (8 * 2) + 8 + 8) + 8 + (5 + 5 + 2)
    8 * (4 * (5 + 9 + 3 + 3 * 2) + 7 + 5 * 5)
    9 + 4 + 4 * 7 * (2 + 4)
    6 + 4 * (8 + 4 + (5 + 7 + 6 + 4 * 7)) * 6 * (8 * (7 + 7 + 6 * 2) + 4 * 4 + 3) * (4 + (8 + 5 + 6) * 9 * 8 * 4)
    7 * (2 * 4 * (7 + 5 + 8 + 2) * 8) * 2
    ((7 + 4 * 8) * 9) + (6 * (7 * 6) + 9 * 9) * 7 + 2 * 8 + 2
    (8 * 4 * 6 + (7 * 3 + 2 * 7) + (6 + 2 + 7 * 9 * 6 + 2)) + 9 * 6 + (2 * 5 + (7 * 2) * 8 * 2) + 9 + 9
    (3 + (7 * 3 + 3 * 5 + 6 * 6)) * 3
    8 + 2 * 7 * 3 * (3 * 5 + 4 + 8)
    (9 * (9 * 2 + 7 + 6 * 6)) * 2 * 2 + 9 + ((9 + 7 * 7 + 4 + 6) * 5 + 9 + 3 * 8 + 6)
    5 * 7 + 5 * (3 + 3 * 3 * 6 * 4 * 2) * (3 * 3 + 2 + 4 * 7 + 3) + 9
    7 + (3 + 7 + 4 * 3 * 3 * (4 + 9 + 4)) + 3
    6 * 8 * 7 * ((2 * 7 * 2 + 7 + 7 * 2) * (4 * 9 + 3 * 7 * 7)) * 9 * 3
    5 * 5 + 8 * 5
    (4 + 6 * 9 * 4 + 9) * 5 * 3 + 2 * 7 + (6 * 9)
    (2 + 9 + 3 * 7) * 8
    4 * ((3 * 8 + 3 + 9 * 9) * 9 * 3 * 6 * 7 * 3) + (8 + 7)
    2 * (2 + 4 + 9 * 4 + 9) * 6 + 5
    5 + 9 + 7 + (2 + (2 * 5 * 6 + 5 * 2)) + (9 * 3 * 7)
    5 + 4 * (7 + 7) + (2 * 5)
    5 * 5 + 3 * (7 + 5 * (8 + 8 + 2 * 4 * 9 * 6) + 6)
    4 + (7 * (6 * 5) * 9 * 4 + (6 + 6 * 7 + 2)) + 9 * 2
    (6 * 7 + (8 * 7 + 2 * 2 * 8 * 9) + 8 + 8) + 6 * 8 * (9 + 6 + (4 + 4 + 6 * 2) * 9 * 8 + 4)
    (4 + 9 * 3) * 3
    5 + ((3 * 9 + 2 + 7 * 4) + (8 * 7) * 6) * 2 * (2 + 8 * 7 * 8) + 3
    7 * 4
    (4 * 6 * (3 * 3 + 2) * 3 + 2) + 2
    4 * 6 + (3 * 7 * 4 * 4) + 3 * 8 + 2
    2 + 6 + ((4 + 7 * 6) * (5 + 4 + 7 + 8 + 8) + 4) + 2 * (4 + 3 + 6 + 7 + (9 * 4 * 7 * 3 + 3) + 3)
    9 * 7 * (8 * 6 * 2 * 7) + (3 * 5) + 6 + 3
    7 * 4 * 3 + 2 + (7 + 5 + 5 * (5 + 6 * 2 * 6) + (2 + 8) * 9) + 2
    (6 * 7 * 8) + (7 + 9 * 6 * 2 * 9 * 2) * (3 * 5 * 6 + 9 * 4) * 5 + 4
    ((6 + 9 * 8 + 3) + 5 + 4) + (3 * 5 + (2 * 9)) * 8 + 8 + 5
    (7 + 5 + 7) * 6 * (6 + 6) * (3 + 9 + 8 * (6 + 3 * 7 * 9) + 2) * ((8 + 7 + 7) * 8 + 6) + 3
    3 * 5 * 8 * 9
    (7 + 2 * 7 + 9 * (6 * 6 * 2 + 9 * 3 + 3)) * 3 * (4 + 8 + 2 + 7 + 9 * 7) + (7 + 5 * 4 * 3 + 8) * 7
    8 + 3 + 7 + 3 * (7 * 5 * 4 * 3 + 7 * (9 * 5 + 4))
    5 + 4 + 9 + 8 + 4 * ((5 * 8 + 5 + 4) * 5)
    (2 + 4 + 3) * 2 * (8 * (3 * 7 * 5 + 7 + 3) + 7 * (7 * 2 * 7 * 2 + 8 + 9))
    6 * (3 * 7 * 5 * 5)
    2 * (5 + 6 * 3 * 7 + 4) + 8 + 7 + (4 + 5 * (3 * 8 + 4 + 5)) * 8
    9 + (8 + (9 * 6 * 5 + 8 + 3 + 8) + 2) + (2 + (3 + 8 + 7 * 4 * 9 * 5) + (8 + 7 * 8 + 3) * 8 * 7 + 5) * (2 + (9 * 2 + 5 + 5 + 6 + 9)) + 7
    6 * (7 * 8 + 6) * 3 + ((7 * 8 + 3 * 9) * 5 + 5 + (5 + 5 * 3 * 5 * 4 * 6) * 9)
    7 + (8 * 7 + (9 + 4 * 4 * 8 * 4)) * (3 + 5 + (3 * 4 * 3) + 3 + 7 * 8)
    7 + (4 + 9 * 5) * 9 * 9 * 4
    6 * (7 + 5 + (9 + 7 * 9 + 5))
    2 * 9
    7 * (4 + (9 + 6 * 4 * 7 * 6 + 3) * 3 * 2) + 6 * 2 + 6
    (3 + 2 * 6) * 6 * (7 * 7 + 7 * 4 * 7) + 3 * 6 + 7
    2 + 9 + 7 + 4 + (5 + 5 + 2 * (8 * 9 * 3 + 9 + 8) * 2)
    ((5 + 6 * 5 + 5 + 7 + 2) * (8 * 5 * 3 * 3 * 6) * 9 * 8) * 3 * 8 * (9 * 5 * 8 * 4 + 6)
    (8 * (9 + 2 + 2 * 6) * (9 * 9 + 4 + 8) + 7 * 9 + 6) + 7 + 2 + 6 * 7 + 5
    2 + 5 * ((2 + 9 + 6 * 7 * 6 + 8) * 9 * 8 + 9 + 9 * 8) * 4
    8 + ((3 * 2) + (4 * 3 + 4 + 7 * 4 * 9)) + 5 * 4 + 3 * 9
    5 * 8 + ((9 + 5) + 5 + 8) * 5 + ((3 + 2) + 8 * 3) + 5
    4 + 3 + ((9 * 4 * 7 * 2 + 9) + 7 * (6 + 6 + 4 * 7) * 2 * 6) * 9 * 3
    7 * 6 + 3 * (6 * (3 * 4 + 7 + 7) * 2 * (3 * 7 * 2) + (7 + 3 + 5 + 6 * 4)) + 8
    3 + ((7 * 7 + 7 + 9) * 5 * 3 + 6 * 9) * 2 + (6 * 6 + 2 * 7)
    3 * ((3 + 9 + 5 + 5 * 5) * 3 + 3) * 7 + 3 + 3 + 5
    8 + (4 + 7 + (7 * 2 + 3 + 6 * 6 + 7))
    2 * (8 + 2 * 4 * 6 * 3) + 4
    8 * (8 * 8 + (9 + 5))
    (5 * 3 + 6 * 5 * 7 + 4) * 4 + 9
    9 + ((5 * 4 + 9 * 6 + 5) * 4 + 7 + 2) * (4 + 5 * 8 * 6 + 3) + 7
    (4 * 9 + 4 + 6 * 4 + 7) + 8 + 8 + 2
    7 + (8 * 6 + 4 + 5 + 9) * 7 + 6 * 3 * 4
    (3 + 5) + 3 * 5 + 3
    8 + 2 * 4 + 7 * (8 + 8 * 9)
    7 * (2 * (6 + 9) * 8 + (5 * 5 + 8 + 6 + 6) + 6) * 4 * 4
    (3 + 6 * 8 + 5 * 2 * 9) + 3
    ((9 * 7 + 9 + 3 * 7) * 3 + 6 * 6) * (5 + 5 * 3 + (7 + 8 * 3 + 7 + 4 * 7)) + 7 + 8 + (4 + (2 * 6 * 2 * 6) * 8)
    6 * ((3 + 7 * 6 + 7 * 5) * 6 * 3 * 7 + 6 * 2) + 8 * 7
    7 + 3 + (8 + 9 * 8 + 9 + 3 * (6 * 7)) + 4 * (6 * 7 + 7 * (6 + 9) + 6 + 2)
    5 * 3 * (2 * 6) * (9 + (2 * 2) + 6)
    4 * 8 * 4 + 7 + 7
    3 + 8 * ((5 * 4 * 7 * 9) * 9 + (6 * 6 * 5 + 7)) * 9 * 4 * (4 + 6 * (4 * 7 + 6 + 2))
    (9 * 3 + 2 + 3 + 2 * 8) * 2 + 5 + 2 * 9
    3 + 7 + 7 + (9 * 7 * 3 * 8) + 3
    2 + 3 + (8 * 4) * 7 * 4
    (9 + 8) + 8 * 8 + 6 + 3
    (9 + 5) * (2 * 5 + 3 * 7)
    9 + (8 + 3 * 4) * 5 * ((7 * 6 * 4 * 6) * 2 * 4 + 3 * 5)
    (7 + 5 * 6 * 7 + 4 + 2) + 8 * (8 * 3) + (6 * (9 * 3 * 7 + 7)) * 7
    7 * 2 + (7 + (2 * 6 + 9 + 9 + 5 + 2) + (4 * 5 + 4 + 3 * 7) + 8) * 8
    (6 * 4 + 6 + (5 + 6 * 4) * 2 + 5) * (3 + 2) + (8 + (8 * 7 * 9 + 5) * 5 * 6) + 8 + 5 + 7
    5 + 4 * 4 + 3 + 8 * (2 * 4 + 5 * 3)
    4 * 3 + 6 + 6 * (4 + 9 * (4 * 9)) * 6
    7 + ((3 + 5 + 8) + 9 + 8 + 6 * 9 + (9 + 5 + 7))
    (6 + 7 + 7) * 9 + 6 + 7
    8 + (2 + 6 * (4 * 8 * 3 * 2 + 9 + 8) * 8 + (9 + 5)) * 5
    6 + 5 * 5 * (6 + 9 + 3) * (5 + 9 + 6)
    ((8 * 8 + 5) * 6) * 7
    8 + (4 + 6) + (4 + 6) + (8 * 4 * (6 + 6) * 8 * 6) * 6 + 2
    9 * (6 + 7)
    (6 + 3 + 6 * 8 + (4 + 8 + 3)) * 4
    6 + (6 + 4 + 7 * 9 + 4 * 6) * 3 * 3 * 8 * 6
    7 * (6 + 5) * 7 + 7 + ((3 * 3) + (9 * 8 + 6) + 4)
    6 + (3 + 2) * (5 * (2 * 7 * 6) * 2 * (2 * 8 + 7)) + 7 + (5 + (5 + 8 * 4 + 8) * 2 + 3 + 9 * 7)
    9 + 8 + 6 + (6 + 8 + (9 + 9 + 9 * 6 * 7 * 7)) * 7 * 5
    9 + 5 * (2 + 6) * (8 * 2 * 8)
    (3 * 3 + 2 + 6 + 5) + 4 * 3 * (9 + 9) * 7
    (6 * 8 + 9 + 2 + 7) + 5 * (9 + 4 * 9 * 9 + 8 * 2)
    4 + (5 * 4) * 5 * 5 + 4
    8 * ((2 + 2 * 2 + 8 + 6) * 7 + 5 * 6 * 8 + (7 * 6 + 7 + 4 * 8 + 4)) + 8 + 5
    8 + (2 + 8 * 3) * (5 + (3 * 6) * 3 * 3 * 7) + (7 * 4 + 7 + 9 * (7 * 6)) + 2 + 5
    ((7 * 7 * 4 * 4) + 5 + (2 + 5 * 3 * 7 + 6) + 4 + 5 + (5 * 4 + 5 * 4 + 6)) + 3 + 8 + 2 * 5
    2 * (2 + (8 * 3 * 9 * 6) * 7 + 9) + 8 * 3
    ((6 + 6 + 5 + 6 * 5) + (6 + 7) + 2) * 6 * 4 + 6 + 2
    3 + 9 + 6 + (3 * 7) + 8 * 2
    5 * (8 + 4) + (7 + 3 + 8) + 9 + 3 * ((8 * 7 * 4) * 4 * 5 + 8 * 7 * 2)
    2 * 9 + ((7 + 9) + 7 + (2 + 3) * 2 + 2 + 7) * (7 * 8 * 4 * 8) * 7
    (6 * (5 * 4) + 6 + 3 + 9) + ((4 + 9 * 5 + 3 + 7) + 5) + (6 * 2 * 9 + 2 + (6 + 2 + 2 + 2) + 7) + 7 * (7 * 4) + 2
    ((7 + 4 * 7 * 8) * 9 + 6) + ((9 + 7 + 6 + 2 * 9) * (4 * 9 * 6 * 3 + 8) * 6 + (9 * 6 * 5) + 7 * (6 * 7 * 8 * 5 * 7))
    8 + (8 * (9 + 9 * 6 * 9 * 3) * 2) + 2 * 4
    6 + (6 * 5 * 8 + 4 + (6 * 8 + 5)) + ((7 * 9 * 5 * 7) + 6) * 6 * 3 + 4
    9 * 4 * 4 + (8 + 2 + 2)
    (9 * 6) * 8
    8 + 5 + 9 * 3 + 4
    ((8 + 5 + 7 * 5) + 5 * (2 * 5 + 2 + 5) * 3 * 4) + 9 + 8
    (5 * 6 * 5 * 6 + 9) * 8 * 8 + 2 * 8
    4 * (2 + 6 + 4) + 6
    (9 + 9) * (2 + 2 * (8 + 3) + 9 * 6) + 4 * 4
    2 * (8 * (9 * 9 * 2 * 5) * (3 + 8 * 2 * 8) + 2 * 9) * 3
    (8 * 3 + (3 * 5 + 8 + 4) * 3) * 2 + 9 + 5
    3 * (5 * 4 * 4) + 2 + 8
    (8 + (7 * 4 * 9 * 6 * 2 * 7) + 6 * 7 * 2) * 7
    (7 * 4) + 3 * 7 * 7 * 7 + 3
    (3 + 3) * 5 + 7 * (2 * 8 * 6 * 9 * 9 + 8) * 6
    9 * 6 * (5 + (3 + 8 * 5) + (2 * 2)) + 6 * ((8 * 2 * 4 + 7) + 7)
    (8 + (8 + 2 + 3 + 9) + (8 + 8 * 9 + 4 * 8) * 9) * (3 + 3 + 9 * 6 + 4 * 2) + 4 * (6 + 7 + 9 * 3)
    7 * 6 * 6 * (7 * (4 * 4 * 8) + 9 + 8 + 4 + 7)
    (8 + 9 + 9) * 2 + 4
    (9 * 7 + 3 * 9 * 8 * 3) + 8 + 5 * 8 * 8 * 9
    8 + (6 * 2 * 8 + 9 * 2)
    7 * ((3 + 3 + 6 * 8) + (9 * 5 * 9 + 3) + 6 * (4 + 6 * 3 + 4 + 3 + 8) * (2 + 2 * 9 + 4) + 8)
    2 * 5 * 8 * 5 + 8 * (9 + 6 + (3 + 5 * 2) + (4 + 4 * 6 * 9 + 5))
    3 + ((3 + 5 + 4) + 9 + 9 + 4)
    ((2 * 4) * 2 * 9 + 9) * 9
    (7 + 3) * 2 * (6 + 9 * 4 * 6) * 5 * 3
    6 * ((3 * 6) + 5 + (2 * 8) * 8 + 3 * 6)
    4 * 4 * (7 * 9 + 4 + 9 * 6 + 7) * 9
    ((8 + 6 * 3 + 5) * 3 + 3 * 8 + (4 * 8 * 3 + 4 * 8)) * 8
    8 * (5 * 3 * 3 + 3 * 4) * (7 * 5 * 4) * 3 + 9
    (8 + 7 + 3 * 2 + 9 * (8 * 9 * 9 * 6 + 7)) + 2
    9 * (2 + 3 + 2 * 6 * (6 * 6 + 8) * 2) + 3 + 7 * 7 * 9
    (2 * 8 * 3 * 9 + 7) * 5
    4 + 5 + 9 + 5 + 5 + 9
    2 + (3 + 4) + 4 + 8 + 3 + (4 * (7 + 3 + 7 + 9 * 3))
    2 * (8 + 2) + 6 * 7 * 2 * (7 + 7 + 5)
    5 * 2 + (8 * 8 * 2 + 8 * 6 + 5) * 3 * 5
    6 + 9 + (6 * 6)
    7 + 6
    7 * (3 * 7 * 7 + (7 * 8 + 8 * 7 * 7) * 7) * 3
    3 * 8 + 5 + ((6 + 9 + 2 + 8 * 9 + 3) + (5 * 8) * 2 * 6 + 8 * (7 + 7 + 2 + 6 + 7)) + (3 * 7)
    (2 + 2 + (7 + 8 + 3 * 7 * 2) + 7 * 6 + (5 * 8 + 8)) + 9 + (9 + 7 + 6 + (3 + 8 + 7 + 5 + 9 * 5))
    ((9 * 6 * 9 * 5 + 3) + 8 * 5 + 7 * 9 * (3 * 4 * 7)) * 4 + 7 + 8 * 9 * (7 * 6 * 3)
    (3 * 9) * ((4 + 6) * 8 + 2 * (2 + 2 * 4) + (8 + 2 + 7 * 7 * 2 + 8))
    ((9 + 5 * 5 * 2) + 8 + 5 + 8 + (6 * 5 + 9 + 5)) * 7 * 6 + 4 + ((4 * 7 * 3 + 9 * 5 * 2) * 3 * 7 + 4 + 9 + 9)
    4 + 4 * 5 * (9 * 9 + (9 + 8 * 5 * 8 + 5) + 6) * 7
    6 * 8 * 4
    3 + 8 * ((6 + 5 + 8) * 9) * 9 * (6 + 8 * 9 + 7 + 8) * (5 * (6 * 2 + 9 + 6 * 6 * 7) * 6 * 2)
    9 + 4 + 6 + (2 * 9 * 8 + (7 + 3 + 6 + 3)) + 5
    5 + (8 * (2 * 6 * 9) + 8 * (4 * 6) + (7 + 2 * 3 + 2 * 6 * 4) * 3) + 9 + 3 * 2 + 3
    6 * 7 + 3 * (8 * 9 + 7 + 4 + 4 + (4 + 8 * 7 + 4 * 4)) + (2 + (3 + 9 * 2) * 6)
    4 * 2 * (3 + 4) * 7 + ((9 + 9 * 3) + 4 * 6 + 8 + 8)
    4 + 2 + ((7 * 7 + 5 * 2 * 3) * 9 * 5 * (9 + 5 * 5 * 8 * 6 + 3)) * (6 * 4 * 9 + 3) + 3 * 7
    5 + (7 * 5 * 4 + 3) * 9 + (7 * 6 * 9 + 6 + 6 * (5 * 4 * 7 * 5 * 2 + 3)) + 5
    (4 * 9) + 9 + 4
    ((2 + 4 + 5 * 4 * 3 * 5) + 6 * 2 + 7 + 7 + (4 * 9 + 2 * 7 * 7 + 2)) * 4 + 8 * 7
    6 * 6 + 4 * (2 * 8 * 9 * 2 + (9 * 2 + 5 + 2 * 9 * 6)) * (2 + 9 + 8 * 6 + (5 * 8 * 5) * 5) + 7
    7 * 8 * 8 + (5 * 9 * 3 * 2 * 9 * 6) * 4
    ((2 + 9 + 4 + 7 * 3 * 5) * 7) + 9 * 4 * 8 * 5 * 5
    (8 * 4 * 7 * 6) + 7 * 9 * (7 * (3 * 9 * 4 * 6 + 8)) * 2
    8 * 7 * 3 + (2 + 9 * 5 + 8 * 3 * 4)
    9 + 7 + 8 + 5 * (6 * 3 * 2 + (8 + 3 * 6 + 9) + 6)
    (8 + 2 * (3 * 4 * 2) + 7 * 7) + (6 * 5 * (4 + 8 * 5 + 7 + 8 * 3) * 6 + 8 * 9)
    2 * (4 + 8 + 3 * 2 * 7 * 4)
    9 + 7 * (9 + 8 * 5 + (2 * 5) * (5 * 6 + 3 * 5 * 7 + 3) * 7) * (4 * (3 + 6 * 5 + 8 * 4 * 9) * 8) * 4 + 2
    8 * 5 * 3 + 2 * (7 * 6 + (9 * 6 + 4) * 4 * 5) + 6
    2 * 3 * 6
    6 + (6 + 4 + 4 + 8) * (7 + 6 + 3 + 2) * 2
    7 * (3 * 3 * 5 * 8) * (3 + 8 * 4)
    ((7 + 8 + 9) * 7 + (4 * 3 * 8 * 2 * 5 + 8)) + 7
    8 * (2 * 4 + (5 + 5 * 9 + 9 + 7) + 5 * 5) + 4 * (8 * 2)
    3 + 2 * (5 + 7 * 2) * 5
    3 + 5 + 8 * 6 * 4 + ((6 * 8 * 9 + 4) + 9 * (5 * 9 + 6 * 4) + (2 + 3 + 8 * 7 * 7 * 8))
    (6 * 8 + 4 * 2 * (2 * 8)) * 3
    8 * 5 + 6 * 3 + ((8 * 6 + 6 * 3 * 3) + 3 * 6 + 4) + 4
    (9 * 5 * 7 + 8) + 7 * 9
    3 + 9 + ((5 * 7 + 9 * 5) + 8) + 6
    5 + 4 * 5 + 2 + (8 * 9 * 8 + 5) + (5 * (8 * 6 + 6 * 4 * 2 + 5))
    5 + 7 + 3 + (6 * 9 * 8 + (7 * 6 * 8 + 2 * 4)) * 8 * (5 * (7 + 7 + 4 + 6 * 3 * 6) * 4 + 5 + (6 + 9 + 3 * 7 * 4))
    (2 + 2 + (9 * 5 * 6) * 9 + 5 * 9) * 6 * 5
    7 + ((6 * 4 + 8 + 7 * 9 + 8) * 6 + 8) + 3 * 2 + 3
    4 * 5 + (5 + 9 * (7 * 9) * 4 + 8 + 2) * 3
    4 * 6 * (9 + 4 * 7 + 7) * ((2 + 6) * 6 * 8) + 7 + 8
    9 * 3 * 3 * 6
    5 + (2 * (7 * 9 * 2) + 6) + 7 * 4 + (6 * 4)
    2 + 2 + (3 * 5 + 5 * 9 + (9 * 2 + 9 + 5) + 7)
    8 * (8 + 2 * 2 * 8 * (9 + 5 + 5 + 9 * 4 * 2) * 4) + 2 + (5 + 7 * 6) + 3 * 8
    6 + ((3 + 9) * 6 * (6 + 5 + 6 * 5 + 6))
    (6 + 9 * 6 + (3 * 3 * 6 * 3) + (4 + 2 + 5 * 4 + 9 * 2) + 7) * 7 + 8
    8 * (5 + 4 + 2 * 5 * 4) * 7 + 6 * 7
    (6 * 3 + (9 + 4 * 7 * 2 + 7) * 5 + 3 * 8) + 5 * 7 * 8 + (5 + 5 + 4 + 8 + 3 + 4)
    7 * 9 + (7 + 9) * (9 * 6 + 5) * 5
    9 + (6 * 2 * 9 * 3) * ((7 + 8) * 8 + 3 + 9)
    ((8 * 2 + 2 + 5 * 9) * (4 * 9 + 2 * 8 * 2) + 6 + 4) * 8 + 9
    6 * 9 * (6 * 2 * (7 + 6) + 9 + (9 + 2 + 7 * 2) + 5) + 2
    (5 + 9 + 4 + 8 * 4) * ((8 * 6) * (2 + 9) + 4 * 7 + 9 + (6 * 2 + 5 + 3 * 3))
    ((4 + 6 + 7 * 5 * 3 * 2) * 9 + (8 + 5 + 7 + 9 * 3 * 4)) * 8 + (4 * (7 * 2 * 9 * 6) * 7 * 9 * (6 + 2) + 2) * 3 * 8
    4 + (7 + 7 * 4 + 3 + (8 * 5 + 6 * 4 * 8 + 5) + (5 + 8 + 4 + 3 + 2 * 4))
    2 * (5 * 3 * 7 * 4 + 8 * 9) + 6 + (7 * 3 * 9 + 5 + 2 + 2)
    ((8 * 2) + 5 + 9 + (3 * 8) + 5 * 8) * 2 * 9 * 2
    (9 * 7 + 4 * 9 * 7) + 5 * 3 + 7
    (5 * (5 * 9 + 2) * 5) * 3 * 8 * (3 + 8 + 4 + 7 * 4 * (2 + 2)) * 6 + 8
    7 * (3 + 7 * (3 + 9) + 5 * 3 + 9) + 3 + 5
    3 + 2 + 6 * (9 * 6 + (2 * 7 + 2 + 2 + 3 * 5) * 5) * 3
    9 * ((3 * 8 * 8 + 9) + 4 + 7 * 4)
    9 * (9 * (3 + 6 + 7 * 3) + 4) + 3
    7 + 6 * 6 * 7 * 4
    7 * 9 + 5 + (7 + 7 + 3 * (7 * 9 * 2 * 9 * 8 * 8))
    (6 + 5 * 5 + (6 * 5 + 7 + 5 * 4)) * 8 * (7 + 2 * (2 * 7 + 5) * 6 * 6) * 9 + 5
    (3 + (7 + 9 * 6 + 7 * 7 * 2) + (5 + 5 * 6 + 6 * 6) * (9 * 4 + 9 + 7)) + 8
    3 * (2 * (2 * 4 + 9) * 5 * 7) * 6 * 6 + 2 * 5
    5 * 7 + (8 + 3) + 3
    8 * 7 * 4 + 6 + (6 + 8 * 8) * 4
    3 + ((8 + 2 + 4 + 5 + 5) * 3 + (2 * 9) + 3 + 6) + 6 + 7 + (7 + 3)
    (3 * 4 * 8 + (4 + 5 * 2 * 9)) + 9 * 3 * 3 * (6 * 5 * 6) * 9
    8 + (8 * 6 * 7 * 7 * 8 * 8) + (3 + 2 + 5 * 2) + 7 * 6
    4 + (2 + 9 + 6 + (4 + 6 + 5 + 4 * 7)) + 2 + ((2 * 4 * 5 + 6 + 4) * 5 + 3 + 7)
    2 + (6 * 2 + 4)
    (8 + 3 * 3 + 9) + 3 + 9 + 8
    8 * 9 + 9 * 2 + 2 * (7 * 9 * 5 + 6 * (2 + 8 + 9 + 9 + 5))
    (8 + 7 + (5 + 3 + 2 * 2 + 2 * 7)) * 6 * 9 * 4 * 4
    3 + 7 + 4 * 3 + ((6 + 9 + 2 + 7 * 2) + (5 * 9 * 4 + 5) + 8 * (3 * 2 * 9) + 5 * 6) + 3
    6 + 2 + 3 * (2 + 9 + (6 * 4 * 8) * 2) + 4 + 2
    (7 + 6 + (3 + 6 + 3 * 8 * 5) * 9 * 8) + 7
    4 * (4 + 7 * 4) + (3 * 6) + (4 * 4 + 2 + 6) * 5
    3 * 4 + 7 + 7 * (3 + 5 + 9 + 4 * 9) + ((9 + 5 * 9 * 5 + 9) * (2 * 4) * 7)
    8 * 6 * 9 * (8 + 8 + 3 + 3 + 5) * 2 + 2
    7 * (4 + 8 * 7 * (9 + 2 + 9 * 2 + 5 * 3) + 8)
    6 * 2 + (2 * 8 * (3 + 2 + 6) + (2 * 4 + 7 * 7 * 6 * 8) * 7 * 4) * 6
    5 * 5 * (9 * 3 + 4) * (4 * 3 * 5 + 4 * (2 + 2 + 5 + 7 * 2))
    6 * 7 + 3 + (7 * 4 + 7 + 8 * 7) * (5 + 8 + 7 * 4 + 4) + (8 * 7 * (5 + 4 * 8))
    (6 + (4 * 2 + 4 + 3) * 3 * (2 * 2 + 5 * 4 * 6 * 7)) + 5 + 7 * 4
    2 + ((9 + 2) * 3 * 5 + 2) * 4 + 5 * 3
    ((7 * 2 + 6 + 6) + 2 + (6 + 6 * 5 * 2) + 5) * 5 + 6 * 2
    4 + 9 * (4 * (9 + 4) + 4 + 8 + 7 * 9) + 6 * 4 * 4
    3 + ((3 + 7) + 9 * 4 + 3 * 4 + 2) + 4
    (4 * 9 * 3 * (2 + 3 * 3 + 6 * 7 + 8)) + 5 * 2 + 8 + 4
    2 + (7 + (9 + 7 * 4) * 5 * 9)
    ((5 * 6 * 9 + 4) + 4) * 2 + 2 + 7 * 3 * 3
    4 * ((7 * 9 + 6 + 5 + 5) * 3 * 6 + 6 + 2 * 4) + 2
    (4 * (3 + 6 + 3 * 8) + (8 * 4 * 5 * 8 * 9 * 6) + 5 + (5 * 4 * 6) + 6) + 3 * 3 + (8 + 3) + 8 + 7
    5 + 7 + 2
    7 + 6 * (5 * 6 + (8 + 8 * 9 * 7 + 9 + 7))
    9 * ((2 * 2 + 2) + 5 * (8 + 6 * 7 + 7 + 9) + 2 * 5)
    (6 * (2 * 8 * 9)) + (8 * (9 * 5 + 5) + 9) * (6 + 7) * 7
    9 * (9 + 3 * 9 * 9 * 5 * 4) * 9 + 3 * (9 + 8 * 2)
    4 + 4 + (7 + 7 * 8 + 9 + (8 * 6) + 3) + 2 + 7
    7 + (7 + 7 * 4 + 5 + (5 + 5 + 9 + 6 * 5)) * 8 + (7 * 4 * 5 + 6 * 8) + 3
    7 * 4 * 3 + 6 + 4 + 5
    ((7 + 6 * 7 + 3) * (8 + 2 * 6 + 7 * 8) * 7 + (3 + 6 * 6 * 4)) + ((8 + 9 * 9 + 8) * (4 * 6 * 8 * 2) + 4 + 9 + 4 * 3) * 8
    9 + 2
    2 * (4 + 4 * 3 + 4 * 7 + 2) * 5 * 7 * 7
    8 * (6 * 6 + (9 * 6 + 6 + 3 + 5) + 5 + 3 + 7)
    (5 * 9 + 5 + (6 + 5 * 8 * 3 + 5 * 9) * (9 * 9 * 6 * 2 * 4 + 7)) * 7 * 5 * (8 * 5 + (3 * 7 + 4) * 5 + (4 + 3))
    (4 + (6 * 5) + 2) + 8 + 2
    4 + (8 * 6 + 7 + 7) + ((5 + 6) + 7 + (7 + 4 * 8 + 5 * 2 + 4)) + (5 + 4 + 7 + (9 + 9 + 5 + 6 + 7) + 4) + ((5 * 6 * 5 * 4) + (6 + 9 * 8 * 3 + 8) * 7 + 6 + (9 + 8)) * ((5 + 3 * 7 * 2) + 8 + 4 * 6)
    9 + 5 + 4
    (8 * 4 * (3 + 5 + 6 + 8 + 3)) * 9 + 3
    6 * 7 * 6 + 4 + (9 * (9 * 9 + 8 + 9 * 6 * 7) * 9 * 6 * 5 * 3) + 8
    4 + (3 * (2 * 6 + 2) * 9 + 2) + 6 + 5
    9 * 9 * (7 + (2 * 5 + 5 * 9 * 2 * 3) * 8 + (3 * 9 + 7 + 5) * 9 * 9) + 2
    4 + (9 * (8 * 3 + 3)) * 4 * 8
    2 + 3 + 9 * ((7 * 5) * 7 * 2 * 6) * 4
    (7 + (7 + 6 + 3 + 7 * 4 + 4) + 8) + 7 + 8 * 9 * 7 * 7
    (8 * 8 * 3 * 2) * (8 + 9 + 8 + 3 + 7) + 7 * 9 * 7 * 3
    ((2 * 2 + 4 + 3) * (9 * 3) * 5 * 5) * 2 * 5
    4 + 8 * 7 * 2 + ((3 * 2 + 4) + (4 * 5 * 4) * (6 + 3))
    9 + (6 + 8 + 6 + 9) * 9 * (8 + 9 + (6 + 5 + 8) * 6 * 2 + 7) + (9 + 8 * 9)
    2 + (8 + 3 * 6 + 4 * 3 * 4) * 4 * (6 * 3 + 8 + 9)
    2 * (6 + 9) * 7 + 9
    ((3 * 9) + 4 + 6 + 4) * 8 + 7 * (5 * 5 + 4 + (6 + 7 + 6 + 3 + 4 * 2) + (5 + 8 * 7 * 6 + 5) * 3) * 3 * 9
    7 + (5 + 8 * 4 * (6 + 6 * 6 * 8) + (3 * 6 * 9 * 9 * 5)) * 2 + 2 + 8 * 6
    3 * 4 + 7 * 7 + 6 * (8 + 6)
    9 * (3 + 3) * 5
    5 + 8 + 8 * 7 + 7 + (5 + (6 * 5 * 8 * 3 + 6 + 3) * 6 + 3 * 9 + 2)
    ((4 + 9) * 4 + 3 + 6 * 4 + (9 * 9 + 4)) * 4 * 7 * 9 + 8
    (3 + (7 + 4 * 9) * 9 + (2 * 7 + 2 * 8 * 3 + 7)) * 5 + ((5 + 7 * 8 * 5 * 4 * 5) * 3 * 3 + 4 * 6 + 2)
    2 * 6 * (8 * 3 + 6 + 3 + (2 + 5) + (2 * 3)) + 6 * 4
    (4 + (2 * 8) + 8 + 9) * ((8 * 6 + 5) * 8 + 6 + 9 * 8 * 8) + 6 * (6 + 8 + 7 * 6 * 3) * 3
    (7 + 2 * 5 * 6 * 9) * 6 + 9 + 3 + 5 + 8
    5 + 2 + (2 + (4 + 2) * (3 * 6 * 2 * 4 * 9 + 7) * 6) * 5 + 4
    9 * 9 + 3 + 2 * (8 + 7) + ((4 + 3 + 2) + 4 * (5 + 4 * 7 * 9) * (5 * 3) * 8 * 4)
    (4 * 7 * 4 + 6) * 3 * 9 * 9 * 2
    (4 + 2 + 6 + (9 + 8 + 5 + 8)) + 2 * 9 * 9
    3 * (6 * (4 + 4 * 8 * 3)) * ((7 + 9 * 2) * 6 * 5)
    3 * 4 + 9
    (4 + 3 + 3 * 6) + 2 + (3 * 7) * 2 * (5 + (2 * 6 + 6) + 7 + 4 * 9) + (3 + (6 + 6))
    8 + 4 + ((8 * 5 + 8 * 2 + 5) + 6 * 2) * 3
    6 + 4 * (5 + 9 + 3 * 8 + (8 * 9 * 4 + 4 + 7) * 8)
    6 + ((6 + 6 + 8 * 9 + 5) + 3 + (3 * 8 + 2 + 9 + 8) + 5 * 6 * 8)
    3 * (9 + (8 * 4 * 2 * 7 + 2) * (8 + 2 + 6 + 3) + 3 + 7) * 3 + 8 * 8
    6 * 2 * 6 * 9 + 5 * 6
    9 * 9 + 5 * 5 + (3 + 8) + 5
    (9 + 6 * 6 + 9) * 3 + (7 + 6 + 4) + 7 + 3
    9 * (3 + 3 + (2 + 9 * 2 + 3) * 8 * 2 + 8) * 9
    ((3 + 7 * 2 * 8 * 6) * 7) + (9 * 8 * (7 * 7 * 9 + 4 + 6 * 4) + 8 + (4 + 5 * 2 * 2 + 7) * 8) * 4 + 4
    (4 + 4 * 8 + 2 * (6 * 4 * 2 + 7) + 4) + 6 * 5 + 7
    ((9 * 2 + 7 + 8) + 3 * 7 + 2) + 3
    5 * (6 + 9 + 9 + 6 + 8 * 2) * (6 * (2 * 9 + 6 + 3) + 8 * 3 * 6)
    6 * 6
    2 + 9 + 2 * ((9 + 3 + 5 + 6 * 8) + 8 + 7 * 6 * 9) + 9
    9 + 4 * 9 * (7 + 7 + 8) + 6
    8 * 6 + (3 + 2 + 3 * 4) + 5 * 8
    3 + 4 * 6 * 9 + 4 * 5
    5 * 6 + 7 * ((8 + 5) + 4 * (6 * 7 * 5) * 7 * (3 + 9 * 4))
    9 + 2 * 5 + 7 * 4
    5 + 7 * (6 + 4 + 2) * ((3 + 2) + 7 + (7 * 7 * 3 + 7) + 7 + (9 + 9 + 9) * 8)
    8 + 9 * 7 + (2 + 8 + (8 * 4 + 6)) * 4
    3 * (5 + 7 + (5 + 7 * 6 + 8 * 4 * 7) + (6 + 4 + 5)) * 7 + 4 * (9 * 2 + (5 * 3 + 7) * 2 * 6 * 4) + (6 + 9 * 6 + 2)
    (2 * 8 * 7) + 9 + 2 * 3 + 8
    ((2 + 2 + 8 + 5 * 3) * 2 + 4 * 6 * 2 * 8) * (5 * 6 + (4 + 4) * 5 * 7 + 4) + (6 + (2 * 2 * 5 + 6 + 9) * 5 + 5 * (8 * 7 * 5 + 2 * 7))
    ((7 * 9 + 8 * 2 * 7) * 5) * 2 * 8 * 2 + ((9 + 8) + 7) * 7
    3 + 3 * ((4 + 8) + (3 * 3 + 4 + 9 + 6 * 9) * 2 * 5 * 5 + 4) * 4
    2 * 4 * 9 * 5 + (3 + 5) * (4 * (5 + 4 * 9 + 9 + 4 * 8) * 2 * (2 * 2 + 3 + 2 + 6) + (4 * 8) * 6)
    5 + (9 + (6 + 6 * 4 * 3 * 6 * 2) + 2) * 5 * 8
    7 * 7 + 7 * (4 + 5 * 9 * (9 * 2 * 4))
    ((4 * 3 * 6) * 5 * 4) * 6 + 3 + 2 * 6"
    assert 3885386961962 == inputstr |> Problem.load |> Problem.part1
    assert 123 == inputstr |> Problem.load |> Attempt2.part2

  end

end
