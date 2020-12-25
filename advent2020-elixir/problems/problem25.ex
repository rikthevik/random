

defmodule Util do
  
end

defmodule Problem do

  # this is gonna be hella slow
  # there's some number theory we can apply here
  # I am so messed up after that nap I can't think
  def find_loop(num, match) do
    inner_find_loop(num, match, 1, 0)
  end
  def inner_find_loop(_num, match, match, loopiter) do loopiter end
  def inner_find_loop(num, match, acc, loopiter) do 
    # "loopiter=#{loopiter} num=#{num} match=#{match} acc=#{acc}" |> IO.puts
    inner_find_loop(num, match, Integer.mod(acc * num, 20201227), loopiter+1)
  end

  def transform(num, loop) do
    transform(num, loop, 1)
  end
  def transform(_num, 0, acc) do acc end
  def transform(num, loop, acc) do
    # fyi 20201227 is prime
    transform(num, loop-1, Integer.mod(num*acc, 20201227))
  end
  
  def part1(cardpub, doorpub) do
    cardloop = find_loop(7, cardpub)
    doorloop = find_loop(7, doorpub)
    "cardloop=#{cardloop} doorloop=#{doorloop}" |> IO.puts
    {key, key} = {transform(cardpub, doorloop), transform(doorpub, cardloop)}
    key
  end

end



defmodule Tests do 
  use ExUnit.Case

  @tag :example
  test "example1" do
    assert 8 == Problem.find_loop(7, 5764801)
    assert 11 == Problem.find_loop(7, 17807724)
    assert 14897079 == Problem.part1(5764801, 17807724)
  end

  test "part1" do
    assert 9714832 == Problem.part1(9033205, 9281649)
  end

 end
