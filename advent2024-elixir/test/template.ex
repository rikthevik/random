
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
    {:reply, m, m}
  end

  # "Business" logic
  def initial_state() do
    []
  end
  def logic_cast() do
    newstate = []
    newstate
  end
  def logic_call() do
    retval = 123
    newstate = []
    {retval, newstate}
  end

  # Client interface
end


defmodule Prob do
  def run1(rows) do

  end

  def run2(rows) do

  end
end

defmodule Parse do
  def rows(s) do

  end

  def make_row(s) do

  end

end



defmodule Tests do
  use ExUnit.Case

  setup do
    _pid = start_supervised!(State)
    :ok
  end

  test "example1" do
    input = """
 """
    assert 11 == input
    |> Parse.rows()
    |> Prob.run1()

    assert 31 == input
    |> Parse.rows()
    |> Prob.run2()
  end

  test "part1" do
    assert 1722302 == File.read!("test/input00.txt")
    |> Parse.rows()
    |> Prob.run1()
  end

  test "part2" do
    assert 20373490 == File.read!("test/input00.txt")
    |> Parse.rows()
    |> Prob.run2()
  end


end
