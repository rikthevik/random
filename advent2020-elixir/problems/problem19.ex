

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
    
  
  def is_literal({:literal, _}) do true end
  def is_literal(_) do false end
  def all_literals(chunks) do
    chunks
    |> List.flatten
    |> Enum.all?(&is_literal/1)
  end

  def replace_chunk(chunk, literal_rule) do 
    # this function can produce a list of new chunks
    # acc is the replaced list of chunks
    "REPLACE_CHUNK #{inspect chunk} with #{inspect literal_rule}" |> IO.puts
    replace_chunk(chunk, literal_rule, [])
    |> List.flatten
    |> Enum.map(&Tuple.to_list/1)
    |> IO.inspect
    # "^^" |> IO.puts
  end
  def replace_chunk([{:rule, num}|chunk], {num, rule_chunks}, acc) do
    for rule_chunk <- rule_chunks do
      replace_chunk(chunk, {num, rule_chunks}, [rule_chunk] ++ acc)
    end
  end
  def replace_chunk([], {num, rule_chunks}, acc) do acc |> List.to_tuple end
  def replace_chunk([subchunk|chunk], {num, rule_chunks}, acc) do
    [replace_chunk(chunk, {num, rule_chunks}, [subchunk] ++ acc)]
  end
  

  def expand(rulemap) do
    literal_rule = rulemap
    |> Enum.find(fn {_, chunks} -> all_literals(chunks) end)

    "replacing #{inspect literal_rule}" |> IO.puts

    if literal_rule do
      {literal_num, _} = literal_rule

      newrulemap = for {num, chunks} <- rulemap, into: %{} do
        new_chunks = for chunk <- chunks do
          replaced = replace_chunk(chunk, literal_rule)
          "num=#{num} chunk=#{inspect chunk} replaced=#{inspect replaced}" |> IO.puts
          replaced
        end
        |> Enum.concat
        |> IO.inspect
        "@num=#{num} new_chunks=#{inspect new_chunks} \n" |> IO.puts
        {num, new_chunks}
      end

      if 1 == Enum.count(newrulemap) do
        newrulemap
      else
        newrulemap
        |> Map.delete(literal_num)
        |> IO.inspect
        |> expand
      end
    else
      rulemap
    end

  end

  def eval_literal_list(literal_list) do
    literal_list
    |> List.flatten
    |> Enum.map(fn {:literal, c} -> c end)
    |> Enum.join("")
  end

  def part1({rulemap, received_messages}) do
    [{0, literal_lists}] = expand(rulemap) |> Map.to_list
    "###" |> IO.inspect
    valid_messages = literal_lists
    |> Enum.map(&eval_literal_list/1)  # not sure if this should need a flatten...
    |> IO.inspect
    |> MapSet.new

    received_messages
    |> MapSet.new
    |> MapSet.difference(valid_messages)
    |> Enum.count
  end



end



defmodule Tests do 
  use ExUnit.Case

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
    assert 2 == inputstr |> Problem.load |> Problem.part1

  end

  
end
