
defmodule Util do
  
end


defmodule ErikList do
  # A link list with a Map structure underneath it.
  # Traversals aren't gonna be fast, but insertions should be.
  
  def new(elems) do
    elems
    |> Enum.zip(Enum.slice(elems, 1..-1))
    |> Enum.concat([{Enum.at(elems, -1), Enum.at(elems, 0)}])
    |> Map.new
    # |> IO.inspect
  end

  def next(el, src) do
    Map.fetch!(el, src)
  end
  def pop_next(el, src) do
    removed = Map.fetch!(el, src)
    dest = Map.fetch!(el, removed)
    el2 = el
    |> Map.delete(removed)
    |> Map.put(src, dest)
    {el2, removed}
  end
  def pop_next_list(el, src, num_items) do 
    pop_next_list(el, src, num_items, [])  
  end
  def pop_next_list(el, _src, 0, acc) do {el, Enum.reverse(acc)} end
  def pop_next_list(el, src, num_items, acc) do
    {el2, remitem} = pop_next(el, src)
    pop_next_list(el2, src, num_items-1, [remitem|acc])
  end

  def insert_at_element(el, src, newitem) do
    dest = Map.fetch!(el, src)
    el
    |> Map.put(src, newitem)
    |> Map.put(newitem, dest)
  end
  def extend_at_element(el, src, []) do el end
  def extend_at_element(el, src, [newitem|newitems]) do
    el
    |> insert_at_element(src, newitem)
    |> extend_at_element(newitem, newitems)
  end

  def to_list(el, head) do
    to_list(el, head, head, [])
  end
  def to_list(el, curr, stop_at, acc) do
    dest = Map.fetch!(el, curr)
    if dest == stop_at do
      Enum.reverse([curr|acc])
    else
      to_list(el, dest, stop_at, [curr|acc])
    end
  end
  


end


defmodule Problem do

  def load(inputstr) do
    inputstr 
    |> String.trim
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
    |> IO.inspect
  end

  def part1(cups, times) do
    "CUPS = #{inspect cups}" |> IO.puts
    head = Enum.at(cups, 0)
    "HEAD = #{head}" |> IO.puts
    max_val = Enum.max(cups)
    cups = ErikList.new(cups)
    "max_val=#{max_val}" |> IO.puts
    result = play1(cups, times, head, max_val)
    |> IO.inspect
    [1|rest] = result
    rest
    |> Enum.join("")
  end
  
  def play1(cups, times=0, _head, _max_val) do 
    cups |> ErikList.to_list(1) 
  end
  def play1(cups, times, head, max_val) do
    
    # "times=#{times} head=#{head} max_val=#{max_val}" |> IO.puts
    # cups |> ErikList.to_list(head) |> IO.inspect
    
    {cups_without_pickup, pickup} = cups |> ErikList.pop_next_list(head, 3)
    # cups_without_pickup |> ErikList.to_list(head) |> IO.inspect


    if Integer.mod(times, 25000) == 0 do
      "times: #{times}" |> IO.puts
    end
    
    # "pick up: #{inspect pickup}" |> IO.puts
    dest = prefind_dest(head-1, pickup, max_val)
    # "destination: #{dest}" |> IO.puts
    
    newcups = cups_without_pickup 
    |> ErikList.extend_at_element(dest, pickup)
    # newcups |> ErikList.to_list(head) |> IO.inspect

    newhead = ErikList.next(newcups, head)
    # "newhead=#{newhead}" |> IO.puts
    # "newcups = #{inspect newcups}\n" |> IO.puts
    play1(newcups, times-1, newhead, max_val)
  end

  def prefind_dest(c, pickup, max_val) do
    # "prefind_dest c=#{c} pickup=#{inspect pickup}" |> IO.puts
    find_dest(c, pickup, max_val)
  end
  def find_dest(0, pickup, max_val) do
    # "2 find_dest" |> IO.puts
    prefind_dest(max_val, pickup, max_val)
  end
  def find_dest(c, pickup, max_val) do
    if Enum.member?(pickup, c) do
      # "1 find_dest" |> IO.puts
      prefind_dest(c-1, pickup, max_val)
    else
      c
    end
  end

  def p2_list(cups) do
    max_val = cups |> Enum.max
    cups ++ Enum.to_list((max_val+1)..1_000_000)
  end

  def part2(cups, times) do
    max_val = cups |> Enum.max
    head = Enum.at(cups, 0)
    total_list = p2_list(cups)
    cups = ErikList.new(total_list)
    play1(cups, times, head, max_val)
    
  end

end



defmodule Tests do 
  use ExUnit.Case

  @tag :example
  test "example1" do
    inputstr = "389125467"
    assert "92658374" == inputstr |> Problem.load |> Problem.part1(10)
    assert "67384529" == inputstr |> Problem.load |> Problem.part1(100)
  end

  @tag :functions
  test "functions" do
    el = ["a", "b", "c"] |> ErikList.new
    assert ["a", "b", "c"] == el |> ErikList.to_list("a")
    assert ["b", "c", "a"] == el |> ErikList.to_list("b")
    assert "b" == el |> ErikList.next("a")
    assert "c" == el |> ErikList.next("b")
    assert "a" == el |> ErikList.next("c")
    assert ["a", "b", "B", "c"] == el |> ErikList.insert_at_element("b", "B") |> ErikList.to_list("a")
    assert ["a", "b", "c", "C"] == el |> ErikList.insert_at_element("c", "C") |> ErikList.to_list("a")
    assert ["a", "b", "B", "BB", "c"] == el |> ErikList.extend_at_element("b", ["B", "BB"]) |> ErikList.to_list("a")
    assert ["a", "b", "c", "B", "BB"] == el |> ErikList.extend_at_element("c", ["B", "BB"]) |> ErikList.to_list("a")
    
    {el2, rem} = el |> ErikList.pop_next("a")
    assert rem == "b"
    assert ["a", "c"] == el2 |> ErikList.to_list("a")
    
    {el2, remlist} = el |> ErikList.pop_next_list("a", 2)
    assert remlist == ["b", "c"]
    assert ["a"] == el2 |> ErikList.to_list("a")

    assert Enum.to_list(1..1_000_000) |> Enum.sort == "368195742" |> Problem.load |> Problem.p2_list |> Enum.sort
  end

  test "go time" do
    
    assert "95648732" == "368195742" |> Problem.load |> Problem.part1(100)
    
    # assert 149245887792 == inputstr |> Problem.load |> Problem.part2(10_000_000)

    # result = "389125467" |> Problem.load |> Problem.part2(10_000_000)
    # assert Enum.to_list(1..1_000_000) |> Enum.sort == result |> Enum.sort
    # [1, a, b|_] = result
    # "a=#{a}, b=#{b}, val=#{a*b}" |> IO.puts
    # last_ten = result |> Enum.slice(-10..-1)
    # "LAST #{inspect last_ten}" |> IO.puts
    # assert 149245887792 == a * b
  end

 end
