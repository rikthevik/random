
defmodule Util do
  
end


defmodule ErikList do
  # A circularly linked list with a Map structure underneath it.
  # This only works because each element in the list is unique.
  # Traversals won't be fast, but insertions/deletions should be.
  
  # Note that there is no head pointer.  All of the functions
  # are relative to whatever element you want.  Because it's
  # O(1) lookups, we sorta don't care where you start from.

  # Store a map of src->dest edges.
  def new(elems) do
    elems
    |> Enum.zip(Enum.slice(elems, 1..-1))
    |> Enum.concat([{Enum.at(elems, -1), Enum.at(elems, 0)}])
    |> Map.new
    # |> IO.inspect
  end

  # Go to the next element in the list.
  def next(el, src) do
    Map.fetch!(el, src)
  end

  # Pops the value after this element.
  # Return the new list and the item it popped.
  def pop_next(el, src) do
    removed = Map.fetch!(el, src)
    dest = Map.fetch!(el, removed)
    el2 = el
    |> Map.delete(removed)
    |> Map.put(src, dest)
    {el2, removed}
  end

  # Pops N items off after the specified element.
  # Return the new list and the list of items it popped.
  def pop_next_list(el, src, num_items) do 
    pop_next_list(el, src, num_items, [])  
  end
  def pop_next_list(el, _src, 0, acc) do {el, Enum.reverse(acc)} end
  def pop_next_list(el, src, num_items, acc) do
    {el2, remitem} = pop_next(el, src)
    pop_next_list(el2, src, num_items-1, [remitem|acc])
  end

  # Inserts an element after the specified element.
  def insert_at_element(el, src, newitem) do
    dest = ErikList.next(el, src)
    el
    |> Map.put(src, newitem)
    |> Map.put(newitem, dest)
  end

  # Inserts N elements after the specified elements.
  #  (I thought this one was pretty snappy :)
  def extend_at_element(el, src, []) do el end
  def extend_at_element(el, src, [newitem|newitems]) do
    el
    |> insert_at_element(src, newitem)
    |> extend_at_element(newitem, newitems)
  end

  # This is the closest we get to traversing the list.
  # It's O(n) but these map lookups are gonna be slow.
  def to_list(el, head) do
    # Tail recursive, build up the result in acc.
    to_list(el, head, head, [])
  end
  def to_list(el, curr, stop_at, acc) do
    dest = ErikList.next(el, curr)
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
    head = Enum.at(cups, 0)
    max_val = Enum.max(cups)
    cups = ErikList.new(cups)
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
    [1, a, b|_] = play1(cups, times, head, 1_000_000)
    a * b
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

  @tag :p2example
  test "p2 example" do
    assert 149245887792 == "389125467" |> Problem.load |> Problem.part2(10_000_000)
  end

  @tag :gotime
  test "go time" do
    assert "95648732" == "368195742" |> Problem.load |> Problem.part1(100)
    assert 192515314252 == "368195742" |> Problem.load |> Problem.part2(10_000_000)
  end

 end
