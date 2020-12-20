

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

  def replace_chunk(chunk, literal_rule) do replace_chunk(chunk, literal_rule, []) end
  def replace_chunk([], _literal_rule, acc) do 
    "RETURNING #{inspect acc}" |> IO.puts
    acc
  end
  def replace_chunk([{:rule, num}|chunk], {num, rule_chunks}, acc) do
    "1 replace_chunk rule=#{num} chunk=#{inspect chunk} acc=#{inspect acc}" |> IO.puts
    for rule_chunk <- rule_chunks do
      rule_chunk ++ replace_chunk(chunk, {num, rule_chunks}, [])
    end
    |> IO.inspect
    
    
    
    
  end
  def replace_chunk([subchunk|chunk], {num, rule_chunks}, acc) do
    "2 replace_chunk #{inspect subchunk}|#{inspect chunk} acc=#{inspect acc}" |> IO.puts
    acc ++ replace_chunk(chunk, {num, rule_chunks}, [subchunk])
  end
  

  def expand(rulemap) do
    literal_rule = rulemap
    |> Enum.find(fn {_, chunks} -> all_literals(chunks) end)

    "replacing #{inspect literal_rule}" |> IO.puts

    if literal_rule do
      {literal_num, _} = literal_rule

      for {num, chunks} <- rulemap, into: %{} do
        new_chunks = for chunk <- chunks do
          replaced = replace_chunk(chunk, literal_rule)
          "num=#{num} chunk=#{inspect chunk} replaced=#{inspect replaced}" |> IO.puts
          replaced
        end
        |> IO.inspect
        "@num=#{num} new_chunks=#{inspect new_chunks} \n" |> IO.puts
        {num, new_chunks}
      end
      |> Map.delete(literal_num)
      |> IO.inspect
      # |> expand

    else
      rulemap
    end

  end


  def part1({rulemap, messages}) do
    expand(rulemap)
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
    # assert 2 == inputstr |> Problem.load |> Problem.part1

  end

  
end
