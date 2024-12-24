

defmodule State do
  # Repeatable way to store state in between things
  use GenServer

  # Server interface
  def init(_) do
    {:ok, initial_state()}
  end
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: StateRef)
  end
  def handle_cast(arg, state) do
    {:noreply, logic_cast(arg, state)}
  end
  def handle_call(arg, _from, state) do
    {retval, newstate} = logic_call(arg, state)
    {:reply, retval, newstate}
  end

  # "Business" logic
  def initial_state() do
    %{}
  end
  def logic_cast({:set, k, v}, map) do
    Map.put(k, v)
  end
  def logic_call({:get, k}, map) do
    {Map.get(map, k), map}
  end

  # Client interface
end



defmodule Prob do
  def split_int_str(s) do
    mid = String.length(s) |> div(2)
    {l, r} = String.split_at(s, mid)
    [String.to_integer(l), String.to_integer(r)]
  end

  def rule(0) do [1] end
  def rule(i) do
    s = Integer.to_string(i)
    if rem(String.length(s), 2) == 0 do
      split_int_str(s)
    else
      [i * 2024]
    end
  end

  def p1_go(max_iters, max_iters, num, acc) do
    acc + 1
  end
  def p1_go(iter, max_iters, num, acc) do
    remaining = max_iters - iter
    # "iter=#{iter} rem=#{remaining}" |> IO.inspect(label: "p1_go")
    result = rule(num)
    |> Enum.map(fn val -> p1_go(iter+1, max_iters, val, acc) end)
    |> Enum.sum()

    "cache(num=#{num}, rem=#{remaining}) = #{result}" |> IO.inspect(label: "cache_set")
    result

  end


  def run1(nums, iterations) do
    nums
    |> IO.inspect(label: "start")

    num_stones = nums
    |> Enum.map(fn num -> p1_go(0, iterations, num, 0) end)
    |> IO.inspect
    |> Enum.sum()

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

    # assert 55312 == input
    # |> Parse.rows()
    # |> Prob.run1(25)

    # assert 31 == input
    # |> Parse.rows()
    # |> Prob.run2()
  end

  # test "part1" do
  #   assert 193269 == File.read!("test/input11.txt")
  #   |> Parse.rows()
  #   |> Prob.run1(25)
  # end

  # test "part2" do
  #   assert 20373490 == File.read!("test/input11.txt")
  #   |> Parse.rows()
  #   |> Prob.run1(75)
  # end


end
