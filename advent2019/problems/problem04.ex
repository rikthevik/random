
# Let's start simple.  Generate all of the values and filter out the valid passwords.

defmodule Problem do

  
  def is_ascending?(chars) do
    # lots of ways a person could write this
    Enum.zip(chars, chars |> Enum.slice(1, 5))
    |> Enum.all?(fn {a, b} -> a <= b end)
  end

  def has_repeat?(chars) do
    Enum.zip(chars, chars |> Enum.slice(1, 5))
    |> Enum.any?(fn {a, b} -> a == b end)
  end

  def is_password?(i) do
    chars = i |> Integer.to_char_list
    is_ascending?(chars) and has_repeat?(chars)
  end

  def run(range) do
    range 
    |> Enum.count(&is_password?/1)
  end
end

defmodule Tests do 
  use ExUnit.Case

  test "filters" do
    # could write more comprehensive tests here
    assert 111111 |> Integer.to_charlist == [49, 49, 49, 49, 49, 49]
    assert 111111 |> Problem.is_password? == true
    assert 122111 |> Problem.is_password? == false
    assert 122334 |> Problem.is_password? == true
    assert 223450 |> Problem.is_password? == false
    assert 123789 |> Problem.is_password? == false
  end

  test "part 1" do
    out = 347312..805915 |> Problem.run
    "part1=#{out}" |> IO.puts
  end


end


