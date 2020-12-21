

defmodule Util do
  
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
    is_rule_valid?(rulemap, String.graphemes(s), Map.get(rulemap, 0))
  end
  def is_rule_valid?(rulemap, [], []) do true end
  def is_rule_valid?(rulemap, message, rule_chunks) do 
    "is_rule_valid? #{message} #{inspect rule_chunks}" |> IO.puts
    rule_chunks
    |> Stream.map(fn chunk -> is_chunk_valid?(rulemap, message, chunk) end)
    |> Enum.any?
  end

  def is_chunk_valid?(rulemap, [], []) do
    true
  end
  def is_chunk_valid?(rulemap, [c|message], [{:literal, c}|subchunk]) do
    is_chunk_valid?(rulemap, message, subchunk)
  end
  def is_chunk_valid?(rulemap, [c|message], [{:literal, not_c}|subchunk]) do 
    false
  end
  def is_subchunk_valid?(rulemap, [c|message], [{:rule, id}|subchunk]) do
    is_rule_valid?(rulemap, [c|message], Map.get(rulemap, id)) or is_chunk_valid?(rulemap, message, subchunk)
  end

  # def is_valid?([m|msg], chunks) do
  #   chunks = 
  #   "is_valid #{c}|#{msg} #{ruleidx} #{inspect rule}" |> IO.puts
  #   for chunk in chunks do
  #     case chunk do
  #       [{:literal, rulec}|chunks] -> 
  #         if c == rulec do
  #           chunks
  #           |> Stream.map(fn {:rule, rid} -> is_valid?(msg, rid, rulemap) end)
  #           |> Enum.all?
  #         else
  #           false
  #         end
  #       # rest when is_list(rest) ->
  #       #   # we have a rule, so let's keep the full message and follow it
  #       #   rest
  #       #   |> Stream.map(fn {rule: rid} -> is_valid?([c|msg], rid, rulemap) end)
  #       #   |> Enum.all?
  #     end
  #   end
  #   |> Enum.any?
  # end
  
  
  def part1({rulemap, received_messages}) do
    received_messages
    |> Enum.slice(1..1)
    |> Enum.map(fn m -> is_valid?(rulemap, m) end)
  end



end



defmodule Tests do 
  use ExUnit.Case

  @tag :functions
  test "functions" do
    inputstr = """
    0: "a"
    
    a
    """
    {rulemap, messages} = inputstr |> Problem.load
    assert true == rulemap |> Problem.is_valid?("a")
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
    assert true == Problem.is_valid?("a")
    # assert 2 == inputstr |> Problem.load |> Problem.part1

  end

  
end
