
defmodule Machine do
  # Having a feeling we'll be building off a machine like this
  # Let's build this in a way that it'll keep its own state
  use GenServer
  defstruct register: 0, mul_enabled: true

  # "Business" logic
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

  # Server interface
  def init(_) do
    {:ok, %Machine{}}
  end
  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: MachineRef)
  end
  def handle_cast({:instruction, inst}, m) do
    {:noreply, eval(inst, m)}
  end
  def handle_call({:get}, _from, m) do
    {:reply, m, m}
  end

  # Client interface
  def process_instruction(inst) do
    GenServer.cast(MachineRef, {:instruction, inst})
  end

  def get() do
    GenServer.call(MachineRef, {:get})
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
    Parse.parse_instructions(s)
    |> Enum.map(&Machine.process_instruction/1)

    m = Machine.get()
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

  setup do
    _pid = start_supervised!(Machine)
    :ok
  end

  test "genserver-works" do
    Machine.process_instruction({"mul", 3, 7})
    m = Machine.get()
    assert 21 == m.register
  end

  test "genserver-works2" do
    Machine.process_instruction({"mul", 3, 71})
    m = Machine.get()
    assert 213 == m.register
  end


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
