

defmodule Util do
  
end

defmodule IsValid do
  defexception message: "good jorb"
end

defmodule Problem do

  def load_chunk(s) do
    case Regex.run(~r/"([a-zA-Z])"/, s) do
      [_, c] -> [{:literal, c}]
      nil -> s 
        |> String.split(" ")
        |> Enum.map(fn r ->
          {:rule, String.to_integer(r)}
        end)
      end
  end

  def load_rule(s) do
    [num, rest] = String.split(s, ": ", parts: 2)
    |> IO.inspect
    chunks = rest
    |> String.split(" | ")
    |> Enum.map(&load_chunk/1)
    {String.to_integer(num), chunks}
  end

  def load(inputstr) do
    [rules, messages] = inputstr
    |> String.trim
    |> String.split(~r/\n *\n/)
    
    rulemap = rules
    |> String.split(~r/ *\n */)
    |> Enum.map(&load_rule/1)
    |> Map.new
    |> IO.inspect

    messages = messages
    |> String.split(~r/ *\n */)

    {rulemap, messages}
  end

  def is_valid?(rulemap, s) do
    try do
      for rule_chunk <- Map.get(rulemap, 0) do
        is_chunk_valid?(rulemap, String.graphemes(s), rule_chunk)
      end
      false
    rescue 
      e in IsValid -> e
      true
    end
  end
  # def is_rule_valid?(rulemap, message, rule_chunks) do 
  #   "is_rule_valid? #{message} #{inspect rule_chunks}" |> IO.puts
  #   for chunk <- rule_chunks do
  #     pre_is_chunk_valid?(rulemap, message, chunk)
  #   end
  # end

  # def pre_is_chunk_valid?(rulemap, message, chunk) do
  #   "is_chunk_valid? message=#{inspect message} chunk=#{inspect chunk}" |> IO.puts
  #   is_chunk_valid?(rulemap, message, chunk)
  # end

  def is_chunk_valid?(_rulemap, [], []) do
    # "1.1- [] chunk=#{inspect chunk} RAN OUT OF INPUT" |> IO.puts
    # we ran out of input
    raise IsValid
  end
  def is_chunk_valid?(_rulemap, [], _nonempty_chunk) do
    # "1.1- [] chunk=#{inspect chunk} RAN OUT OF INPUT" |> IO.puts
    # we ran out of input
    false
  end
  def is_chunk_valid?(_rulemap, message, []) do
    "1.2 ran out of rules - [] returning message=#{message}" |> IO.puts
    # we ran out of rules, return whatever we consumed
    false
  end
  def is_chunk_valid?(rulemap, [c|message], [{:literal, c}|subchunk]) do
    "2:matching literal c=#{c} message=#{message} subchunk=#{inspect subchunk}" |> IO.puts
    is_chunk_valid?(rulemap, message, subchunk)
  end
  def is_chunk_valid?(rulemap, [c|message], [{:literal, not_c}|subchunk]) do 
    "3:mismatchliteral c=#{c} != #{not_c} message=#{message} #{inspect subchunk}" |> IO.puts
    # we didn't match a literal here, we're done.
    false
  end
  def is_chunk_valid?(rulemap, message, [{:rule, id}|subchunk]) do
    "4:processingrule message=#{message} rule=#{id} subchunk=#{inspect subchunk}" |> IO.puts
    for rule_chunk <- Map.get(rulemap, id) do
      is_chunk_valid?(rulemap, message, rule_chunk ++ subchunk)
    end
  end
  
  def part1({rulemap, received_messages}) do
    received_messages
    |> Enum.count(fn m -> is_valid?(rulemap, m) end)
  end
end


defmodule Tests do 
  use ExUnit.Case

  @tag :functions
  test "functions" do
    inputstr = """
    0: 1 1
    1: "a"

    a
    """
    {rulemap, messages} = inputstr |> Problem.load
    "----------------------" |> IO.puts
    assert true == rulemap |> Problem.is_valid?("aa")
    "----------------------" |> IO.puts
    assert false == rulemap |> Problem.is_valid?("a")
    "----------------------" |> IO.puts
    assert false == rulemap |> Problem.is_valid?("aaa")
  end

  test "example1" do
    inputstr = """
    0: 4 1 5
    1: 2 3 | 3 2
    2: 4 4 | 5 5
    3: 4 5 | 5 4
    4: "a"
    5: "b"
    
    ababbb
    bababa
    abbbab
    aaabbb
    aaaabbb
    """
    {rulemap, messages} = inputstr |> Problem.load
    assert 2 == inputstr |> Problem.load |> Problem.part1

  end

  
end
