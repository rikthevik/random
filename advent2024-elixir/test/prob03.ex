
defmodule Machine do
  # Having a feeling we'll be building off a machine like this
  defstruct register: 0, mul_enabled: true

  def eval({"mul", l, r}, m) do
    if m.mul_enabled do
      %Machine{m|
        register: m.register + l * r,
      }
    else
      m
    end
  end
  def eval({"do"}, m) do
    %Machine{m|
      mul_enabled: true
    }
  end
  def eval({"don't"}, m) do
    %Machine{m|
      mul_enabled: false
    }
  end
end

defmodule Prob do
  def evaluate([_, "mul", l, r]) do
    String.to_integer(l) * String.to_integer(r)
  end

  def run1(s) do
    ~r/(mul)\((\d+),(\d+)\)/
    |> Regex.scan(s)
    |> Enum.map(&evaluate/1)
    |> Enum.sum()
  end


  def run2(s) do
    m = Parse.parse_instructions(s)
    |> Enum.reduce(%Machine{}, &Machine.eval/2)

    m.register
  end
end

defmodule Parse do
  def rows(s) do
    s
  end

  def parse_match([_, _, "mul", l, r]) do
    {"mul", String.to_integer(l), String.to_integer(r)}
  end
  def parse_match(["do()"|_]) do
    {"do"}
  end
  def parse_match(["don't()"|_]) do
    {"don't"}
  end

  def parse_instructions(s) do
    ~r/((mul)\((\d+),(\d+)\)|(do|don't)\(\))/
    |> Regex.scan(s)
    |> Enum.map(&parse_match/1)
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

    input = """
    xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
    """
    assert 48 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 189600467 == File.read!("test/input03.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 107069718 == File.read!("test/input03.txt")
    |> Parse.rows()
    |> Prob.run2()
  end

end
