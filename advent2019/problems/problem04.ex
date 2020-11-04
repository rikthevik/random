
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

  def has_only_2_same_digits_adjacent?(chars) do
    groups(chars)
    |> Enum.any?(fn a -> Enum.count(a) == 2 end)
  end

  # blech
  def groups(chars) do
    # IO.puts("")
    [c|rest] = chars
    abc(c, rest, [c], [])
  end

  # well this took me awhile to get right
  # not sure how "right" this feels
  # look at a char and build up the current string and append into the accumulator list
  # i'm gonna sleep on this one
  def abc(c, [c|rest], curr, acc) do
    # "1abc(#{c}, c=#{c}|#{inspect rest} curr=#{inspect curr} acc=#{inspect acc}" |> IO.puts
    abc(c, rest, [c] ++ curr, acc)  # append to curr when you get the same char
  end
  def abc(_c, [d|rest], curr, acc) do
    # "2abc(#{c}, d=#{d}|#{inspect rest} curr=#{inspect curr} acc=#{inspect acc}" |> IO.puts
    abc(d, rest, [d], acc ++ [curr])  # append curr to acc when you hit a different character
  end
  def abc(_c, [], curr, acc) do
    # "3abc(#{c}, [] curr=#{inspect curr} acc=#{inspect acc}" |> IO.puts
    acc ++ [curr]   # append curr to acc when you hit the end of the list
  end
  
  def is_password?(i) do
    chars = i |> Integer.to_charlist
    is_ascending?(chars) and has_repeat?(chars)
  end

  def is_password_part2?(i) do
    chars = i |> Integer.to_charlist
    is_ascending?(chars) and has_repeat?(chars) and has_only_2_same_digits_adjacent?(chars)
  end

  def part1(range) do
    range 
    |> Enum.count(&is_password?/1)
  end

  def part2(range) do
    range 
    |> Enum.count(&is_password_part2?/1)
  end

end

defmodule Tests do 
  use ExUnit.Case

  test "part1 tests" do
    # could write more comprehensive tests here
    assert 111111 |> Integer.to_charlist == [49, 49, 49, 49, 49, 49]
    assert 111111 |> Problem.is_password? == true
    assert 122111 |> Problem.is_password? == false
    assert 122334 |> Problem.is_password? == true
    assert 223450 |> Problem.is_password? == false
    assert 123789 |> Problem.is_password? == false
  end

  test "part 1" do
    out = 347312..805915 |> Problem.part1
    "part1=#{out}" |> IO.puts
  end

  test "part2 tests" do 
    assert '1' |> Problem.groups == ['1']
    assert '11' |> Problem.groups == ['11']
    assert '12' |> Problem.groups == ['1', '2']
    assert '111223' |> Problem.groups == ['111', '22', '3']
    assert 111122 |> Problem.is_password_part2? == true
    assert 111223 |> Problem.is_password_part2? == true
    assert 111222 |> Problem.is_password_part2? == false
  end

  test "part 2" do
    out = 347312..805915 |> Problem.part2
    "part2=#{out}" |> IO.puts
  end
end


