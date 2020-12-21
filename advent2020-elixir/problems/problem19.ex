

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

  test "go time" do
    inputstr = """
    62: 110 112 | 92 68
    85: 38 92 | 102 110
    63: 92 6 | 110 23
    82: 110 | 92
    99: 110 122 | 92 54
    33: 110 61 | 92 103
    24: 110 92 | 110 110
    76: 3 92
    109: 26 92 | 81 110
    94: 92 78 | 110 28
    17: 110 115
    61: 92 110 | 110 82
    25: 9 110 | 61 92
    114: 47 110 | 63 92
    21: 30 82
    103: 82 82
    69: 5 110 | 43 92
    73: 110 116 | 92 69
    52: 92 81 | 110 103
    22: 119 92 | 50 110
    108: 37 92 | 35 110
    2: 71 92 | 20 110
    119: 103 110 | 88 92
    102: 101 92 | 49 110
    92: "b"
    91: 92 54 | 110 3
    64: 92 115 | 110 24
    68: 92 30 | 110 81
    89: 115 110 | 26 92
    80: 61 110 | 81 92
    19: 110 73 | 92 1
    16: 115 92 | 103 110
    15: 123 110 | 58 92
    115: 110 110 | 92 110
    70: 92 30 | 110 9
    40: 110 96 | 92 99
    50: 88 110 | 115 92
    18: 26 92 | 48 110
    81: 92 110
    107: 110 30 | 92 115
    38: 84 110 | 12 92
    44: 40 92 | 66 110
    27: 125 92 | 2 110
    41: 92 128 | 110 118
    56: 81 92 | 30 110
    88: 110 92
    13: 75 92
    55: 75 110 | 26 92
    12: 13 92 | 52 110
    28: 122 92
    121: 75 92 | 24 110
    113: 92 81 | 110 54
    98: 103 110 | 3 92
    6: 92 62 | 110 126
    96: 75 92 | 9 110
    9: 82 92 | 92 110
    0: 8 11
    32: 104 92 | 91 110
    116: 110 32 | 92 67
    104: 92 81 | 110 30
    5: 110 109 | 92 105
    117: 110 22 | 92 59
    128: 92 24 | 110 9
    66: 92 98 | 110 21
    46: 76 92 | 89 110
    36: 92 90 | 110 127
    20: 110 115 | 92 3
    4: 48 110 | 30 92
    26: 92 82 | 110 110
    39: 30 110 | 115 92
    127: 61 110 | 9 92
    84: 110 104 | 92 78
    100: 97 92 | 68 110
    106: 110 7 | 92 18
    123: 110 64 | 92 68
    111: 110 74 | 92 46
    42: 114 110 | 19 92
    58: 28 92 | 16 110
    47: 110 15 | 92 124
    54: 92 92 | 110 92
    51: 110 117 | 92 111
    130: 92 41 | 110 106
    30: 92 92 | 110 110
    72: 17 110 | 109 92
    129: 130 92 | 108 110
    14: 85 110 | 51 92
    53: 87 92 | 44 110
    112: 92 30 | 110 122
    45: 61 82
    105: 75 92 | 61 110
    90: 110 122 | 92 9
    122: 110 92 | 92 110
    83: 110 33 | 92 56
    118: 110 61 | 92 75
    74: 120 92 | 78 110
    29: 110 65 | 92 60
    31: 14 92 | 10 110
    110: "a"
    87: 36 110 | 94 92
    57: 92 48 | 110 81
    78: 92 115 | 110 54
    97: 92 48 | 110 122
    1: 110 27 | 92 34
    95: 92 107 | 110 86
    79: 110 55 | 92 77
    37: 92 109 | 110 25
    126: 4 110 | 39 92
    101: 45 92 | 80 110
    59: 110 70 | 92 105
    7: 61 92 | 48 110
    48: 92 92
    35: 104 92 | 57 110
    120: 48 92 | 48 110
    34: 29 110 | 79 92
    93: 54 92 | 26 110
    71: 115 110 | 61 92
    125: 121 110 | 45 92
    60: 122 92 | 54 110
    86: 54 110 | 9 92
    49: 97 110 | 91 92
    3: 110 110
    23: 110 95 | 92 72
    65: 92 103 | 110 115
    10: 129 110 | 53 92
    8: 42
    11: 42 31
    77: 103 92 | 81 110
    67: 93 92 | 112 110
    75: 92 110 | 92 92
    124: 83 110 | 100 92
    43: 92 113 | 110 56

    abbabbbbaaabbbbabbbababaaabaabaabbaabbba
    babaaaabbaaabbbbbbbbbaba
    bbbbaaaabaaabbabaababbbabaaaaaababaabaaaaabbabbb
    baabbbbbbbaababaababbbabbababbbbaaaabbbbbabaabbabaaababb
    aabbaabbbbbaabbbbaaabaab
    bbaaabbaaaabababbbbaabaa
    abbbbbababbaabaabaaaabbbaaaabaab
    abaabbbbabaaabaabbbbaabbabaabaaabbaaabbbabbaabbbaabbbabb
    baabbbbbaabbaaabbabbabaa
    babbabbbabaabaaaaabbababaaaabaaaabbababbabababbaaababaaa
    aaababaabababbbbabaaaaab
    bbabaabaabbaabaabbbbbbab
    bbbbaaaabaaabbabbbbbbaababaabbaabaabbaab
    aaabbabbbabababbaabbabba
    abbbbbbabbababbbbabbabbabbabaabbaaabbaab
    bbbbabaaabbaabbabaaabbbababababbabaabbaabbabbbaa
    aabaaaaabaabaaabaaabbaababbbaaababbbbbbabbbbabababbbabbaabaaabaa
    baaaababbaaaaaabaabbbabbaaabaaab
    abbabbbaaabaaabbaaaaabbb
    ababaaaababaaaaaaababbaa
    babbabbabbababababbaaabb
    bbabbaabaaabbabbababaaababababaaaaababaabbaababb
    bbababbbbbabaaabaaabaaaa
    abbaaabaaaabaabbbbbaaaba
    aaaabababbbbabaabaabaaabbabbabbabaaababaaabaabbaabaaabbabbaaaabababbbaab
    aabaababaaaaaabbaabaaabbbabbbaaabaabaaaaabbaaaba
    bababaaaabbaabbbaaaabbab
    abababaabbbbbaababbaaaabbabaabbbabbbbaaaabaaabbbabbbbaba
    ababababababbbaaababbbba
    ababbabbabaabbbaabaaaabbaaaaaaaaaaabaaaabbbababb
    aaabbabbbaaabaaaabaabaaa
    abbbbabbabbbbaaabbbbabbbbabaaaababbbabaababbaabbabaaabba
    bbbababaaaaabaaabaabaaabbaababba
    aaaabbbbbbabababbbaaabab
    aabaababbbbbaabaabaaabaaabababbbbababbabbbbabbaa
    babbabbaabababaaabbbabaa
    baaaaaaabbabababbbaabaaa
    aaababaaaaabaaaaabaaabbaabaaaaab
    abaaabaabaaabaabaaabaaaabbaabaaabbbbbbab
    aaabbbabaababbbbbaabaaba
    bababbbaabababaabababaab
    bababbbaaaabaaaabbbaaabbabbaaabb
    ababaaabbababaaabbabbbbabaabaabaabaababb
    bbabbaabbabaabbbabbabbbaaabbaabaaaaaaaababbbbaaaabbaabab
    aaababababaaaabbaaaaabba
    babaababbbbabababaabaaaaababbabaabaaabba
    aaaabaaaabababaaaaabbaaa
    aabaaaaababbbaaaabbbabababbabbaa
    bbbbaababaabbbabbbbabbaa
    baaaaaabaabaaaaaabbaabbaabbabbbbbbbabbabbbbbabbbabaabbab
    ababababbaaaaaabaabaabbb
    abbbababababbbaababbaabb
    aabbaaabaabbaabbaaaaaabbbbaaabbaabbbaaaa
    bbabbbbaaababaababbbbbbaabbbbbabbabbabbb
    babbbabaabaabbbabaabbaab
    bbabbbabababbbabaababbbaaabaaaababbbbaba
    babbaaaabbbabbbbabbaaaba
    bbbbababbbababbbbbabbbabbbaabbbbaaabbaaa
    ababbbaababbbabaaaaaaabaabaaaaaabbabaabbaaaaaabababaaabaaaaaababbbbabbbbaababbaabbbbaaab
    aabbbabbaabbaabbbaaabababaaabaabbbabbaba
    bbbabaabbbabbaabbaabaaaababbababababbbba
    abaabbbabaaaaabbabaaabbb
    bababbabaabaabaaaabbbbaabbababba
    aabbaaabaabbbabbaababaaa
    baababbbbbabaabaaaaabbab
    bbbbabbaabbbbbbbabbbaaaaaaabaabababaaaaaabababbbbaababab
    baaaabbabbaaaaaababaaaaaabaabbbbababbbbb
    baababbbabbbbaaabbaabaaa
    bbbabbabbbbbabbbbaaaaaaaaaabbabaabaababb
    bbbbbbaabaabbbaaabbbaaba
    bbbababaaabbbbbbbbbbababaabaabaababbbbba
    abbaabbaabbaaaababaaaaababaabaaaaabbbaabaabaaaabaabbabbbbabaabba
    baaaabbbaaabbaabaabbbabababbaaab
    abaaabaaabababaababbbbbb
    bbbbaaaabbabaabaabaaabaabaabbaaa
    bbaaabbbbaaaaaaabaabbbbbbbbaabbbaaaaabbb
    abbaabbabaaabbabaaabbbbabbababba
    baabaaaaaabbabaaaabaabbbbaabbaab
    babbbababaaababaabaabbaa
    aabbbbaaababbbaaabaaaaab
    bbaaabbbaabaaabaabbbabba
    babbbaaabababaaababbbaab
    aaaaaaaaabbbababaaabbaab
    bbaabaabbabbbaaababbbaaabbbbbaabbbababba
    ababababbaaabbabbababbbbbbbbabba
    abbaabbababbbabaabbabbbabbaaaaababbbabababaabbaa
    aabbbabaaaabbbbbababbbbbbabbaaabbabaababaabbabab
    babbbaaababaabbbbbbabbaa
    ababaabaaabbaaababaabbbb
    aabaabaaaabbbbaaaabbabaa
    baaaabbbbbbababbaabaababaabbabaaababbbbabaaabbbbbbbaaabbabbbbbbaaaaaaabaaaaaabbbbbbaaaba
    baaabbabbabbbabaaaabaaba
    baaaabbbbbbbbaababbbbbbb
    baaaabbaaabbbbbbaababaaa
    aabaababbaaaababaabbabba
    aabbbbaaaabbaaaabaababba
    bbaaabaaaaaabbbabbabaabababbabbaaababbababaabbab
    abbabbbaaabaaabbabbabbaa
    aaaaabbbbbbbbbbbabaababbababbbbabbbabbbaabaababb
    bbbbababbbabaabababbbabaaabaabababaaaabbabaabbabbbaabbab
    babbbabbbababbbbabbaabbbabaaaabbbbabbaabaabbabaaabbbbaab
    baabaabbaaababbaaababbbbbbaaabbbabaaaaabbbbbaaabbbbaaaaa
    abaaababaaaabababbaabbab
    abababaaaaaabaaababbabba
    abbbaaabbaabbbbbbaaababb
    baabbbbbbbbbabbbbbaabbba
    abaaabaaabbbbbabbbbabbba
    babbbabbaabaabaaabaaaaaa
    aaabbabbabaaababbbbabbabbabaaaabaabbababbbbbabba
    aabaaaaaababaaaabababaaaabbbbbbababbaabaabbbaaaa
    abaaaabbbbbabaaaaabbbbababaabaaa
    aaabbbabaaaabaaaabbabbab
    bbbbaabbbabbbabbbaaabbbabaabaabbbabbabbbabaaabbaabbababb
    babaabbbbbbbababbbaabaababbaaabb
    abbbbabbbbbbbbbababbaabb
    abaaaabbaabbbbaabaabbbbbbabbabbababbbbbbabbabbaabababaab
    aaabbabbaaaabbbaabbbabaa
    babbbabaabababaaababbaba
    abbaabbababaaaaaaababaaa
    aabbbabbabababbbabbbbbaa
    aababbbbbaaaaabbbaabbaab
    aabbaabaaabaabaaaabbbaab
    abaabbbabababaaaaabababb
    abbbbbbaabaaabaababbabbb
    baabaaaaaaabbabaaabbaabbaabbaaab
    baababbaababbaabbbbabbaa
    ababababbabaaaabbaaabaab
    abbabbbbabbbababaabababb
    bbabbabbbbabaaabaabbbbba
    aaaaaabbbaaaaabbabbababb
    baaabaaababbbabaaababbbbbbaabbab
    bbbbbbbababaababaababbaa
    baaaaaaaabaabbbaababbabbbaaaaaabbaabaaaaababbbbaaabaabaa
    aaabbbabbaaaabbbbabbbabababaaabababaabba
    bbbabbabababbabbbabaaabb
    bbaaabaaaaaaaaaababaaabb
    aabaabbaaabbbaabbaaabaaaababbaab
    abbbbaaabbabbbbbbbbbbbaabbabbabbbabbbbab
    aaababaabaababaabbbaabab
    baabaabbbbabbbabababbaaa
    abbbaaabaabaababbbbbababababbaabbabaaaaaabbbbbaa
    aabbbbbbbbbabbbbabaabaab
    bababaaabbbabbbbababbaba
    bbabaabbbababaaabaaaaabb
    bbbbbbaababaababababbbbb
    bababbbbabbbbbabbaabaaba
    aabaababbbbbbbbabaabbbabbbabbbabbbabbaabaabaaabbababbaba
    ababbbabbaaabbabababbbbbababaabaaabaabaabbbaaaaaaaaabbaabbbababbaaabbabbbbaabbaa
    bbabbbabaaabbabaabaabaaa
    bbabbaabbbaaaaabababbbbb
    bbbbbbaaababbabbaababbaa
    bbbbbbaabbabababaaaabaab
    abbaaabbabbababbabababbaaabbbbababbaabbbabbbbbab
    bbbbababbabbbabbbbaabaaa
    bbaabaabbababbaaaabbaaaabaaaaaba
    abbaabaaababbabbabbbabaaaaaabaab
    baaaababbbabbabbbbbbaabbabbaaaaabaabbbaaaaabbaaaabaaaaab
    bbbbbbbabaabaaabbbabbbbaaabbbbababbaaabb
    bbaaabaaabbaaaaaaaabbaaa
    babaabbbabbabbbbbaaabbbbababaabb
    bbbbabbbbababbbabbabbbaa
    baaaaaababbaaaabbbbaabba
    abbbaaabbbbbababaabbbbbb
    aabbaaaaaababaabbabaabbbbabbaabaaaaaaaaaaababbab
    aaabbabbbbbabababbbbbbab
    babaabaabbbabaaaaaabbababaababba
    abaabbbaabbbbbababaaaaab
    aaabbabbaabababbaabbbbba
    aabaaabaaaaabbbaabbbaabaababbbbbbbbbaabbbbbbaabbbaabbaaa
    abbaabbbbaaaabbbabbbaabb
    bbaaabbaaaababaabbbabaababaaaabaaabbbaabbbaababbbaababba
    babaababbabaaaaaaaaaabaabbbbbaababbabbaa
    bbaaabbabbabbbabaaaaabbb
    aaaabababbababbbaabbbbababbaaaaabaaaaaba
    bbabaabbbbbbbbbaabaaaaab
    bbabaaababaaababbaaaabaa
    aabbaaabaabbbabaabbbabaa
    bababaaabbbbbbbabababaaaabaaaaab
    abaaaabbaaaaababaaaaaaba
    baaaabbaaaababababaabaabbaaaaabbbaababba
    bbababbbbbaaaaabaabababb
    bbbabbbbbbbbaababbbbaabaabbbbbaa
    bbbabbbbabaabaaaababbbbaababaabb
    bbbbababbabbbabbbabbabaa
    baaabababaabbbaabbabaabababbabbaabbaabab
    aaababbabaaaaaaabbbaaaba
    baaaaaabaabaaabaaabaabba
    babbaabababababbaaabbaaa
    bbbababaaaaaaaabbbbaaaab
    bababbaabbbabaabbaaaaaba
    abababbbbbbbabababbabbaa
    aaabbbabbaaabbabaabababa
    aaaabbbababaabbbabbaaaaaabaababbbabbabab
    bbaaaaababaaabaababaaaabbabaabbbaaaabbaa
    abbabaabaabbaaabbababbbabaaabaab
    abbbababaaabbabbaaabbaab
    abbabbbbabaaababaaabbbaa
    aababaababbaabbbaababbaa
    babaabaaaaabaaabbbbbaaab
    aababbbbbaababbbbaabbabb
    bbbbaaaaabaaaaabbbbaabaabbababbabaaabbaabbbaabab
    ababababbaaaabbbbbbaabbbabbbbbaa
    bbabbbbbbbababbbbabbabab
    bbbbbbbbbbabbaabbabbbaaaaabbbabaaabbbbba
    bbabbbabaabbaaabbbbabbba
    aabaabbbbbaababbaabababa
    bbaabaabbbbbababbbbbbaaa
    bababbaaaaaaaabbabbbbaaabbbabaababbbbababbabbbaaabbbaabb
    aabbbbbbbbbbabaabbbbbaaa
    ababbbaabbbaabbbbaaaaaabababaaababbbababbbabababbbaabbbb
    aabbbbbbbaabbbabbbabbaaa
    bababbababaaaabbabaabbab
    aababbbbababababaaabbaaa
    bbbbababbbabbbabbaababaa
    abbbbaaabbaaabbbbaaaaabbaaaaabba
    abbaabbabbaabaabbabbaabb
    baaaabbbaaabbbbabaaabaab
    baaabaaabbaababaaaabbaab
    baabbbabbbbbbaabbabaabbbbaababab
    bbabababaaabbbababaababa
    aabaabaabbabbbbababbaaababbbabbbaabbabaabbbbabbabbbbbbbb
    abaaaababbbbababaabababb
    abbabbbbaaaabbbbabbabbbbababaabb
    aababaabaaaaabaababaaaba
    abbbbaaabbaaaaabaaabbaaa
    aabaaabaaabbaaaaaaaabaab
    bbaaabbbbbbababaaabababa
    bbbabbabbaaaababbabaabbbaabbbbbbabbaaaaabbababba
    bbbbababbaaaaabbabbbbbabbaabbabb
    bbabaabbbbbbaabbbaabbbabaabaaaaabaabbaaa
    abbaaaabbbbbabbbabaabaaa
    aaabbbbaaaababbabaaaaaba
    bababbaabaaaabbaaaabbaaa
    ababababaaaabaaaababbaab
    aabaaababbabaabaabaabbbb
    abbaabbbbbbbabbbbbbbbaabbbababbbaaabbaaabbababaa
    abbabbbbaaaabaaababbbabaabbbabaaaabbabaa
    aababbbbbaabaabbbbbabaabaababbbbbbbbaaabbbabbaaa
    babaaaabbbabbaabbaababba
    bbabbbabbbbbabaabaaaabaa
    aaaaaabbaabbbababaaabaab
    abaaaababbbbbbaaabaabaab
    abaabbbabaaaaabaaaaabbaaaaaababbabbbaabb
    bbbbaaaaabbaabbabbbbabbbbbabaabaaaabaaab
    bbabaaabaababbbabbababbbababbaaa
    bbbbbbbbbbabaaabbaabbabb
    bbbabbbbabbaabbbbaababbbabbababb
    bbaaabbabaabbbaabaababab
    bbabaabaabbbababbaaabbabbbbbaaab
    abbbbaaaababababbabaabbbabbbbbbb
    babaaaaaaabaaabababaababbabbaabbbbaabaaa
    baaaabbabbaababaabbababb
    aaaaaaabbaaaabbbbbbaaaaa
    aabaaaaabbbabaabbaababaa
    abbabaabbbabbbbbbaabaaaaaaaabbaaaaabbaab
    baaaabababbbbaaabaababaa
    babaaaaabaaabbbbaaabaaaa
    aaabbababaaaaaaaabbbabaa
    bbabaaabbaaaababaaabaaaa
    bbaaabbbbabbbbbaaabbbbbaaabbbbbabbabaabababbbbbaabbabbaabbbabbbaaaaaaaababbbbababaabaabb
    aabaaaaaaabababababbabaaaaabbaaa
    bbbabaaabbaaaaaabbbaaaab
    abaaaaaabbabaaaabbbaabbabbababaa
    bbaaabbaaabbbabaababbbbb
    bbabaaabbababbbababaaaabbabaaaba
    abbabbbabaaabbbaaabaaaab
    baaabbbbbabbbaaabbbaaabb
    bbaaabbaababbbababaaabba
    aaaaabaaaabbbbabaabbbbaaaababbbbbabaabbbbbabbbaa
    bbaaaaaaabababbbbabbbbaa
    ababbabbaabaaaaaaaababbb
    babbabbabaabaaabbabaababbbbaabbbbbababababaababb
    abbaaaaabababbbbaaaabababbaaaaabaabaabbb
    bbaaabbbbaaaabbbaaabbaaa
    bbabaaabbaaaaaaabbabbaba
    bbabaabaaabaaabbbaaabababaaaabaa
    bbbbababbbbabaaababbbaaaababababbaabbbaaabaabbaaaaabbbbb
    bbaaaaabbbaaabaabaababab
    aaaabaaabaaabbbaaababbab
    aabbaababbabbbbbabbababa
    baaaaaaaaabbaabaaabbbbabbaaaaaababaababb
    aabbaaabababababaaaaabbb
    aabaaaaabbbbaabaaaaabaab
    bbaaaaabbbbabaaaabbbabba
    babaaaababbabbbbbbbaaaaa
    bbbbaabaaaabbbbababbaabaabbbababaabaaaabbaababba
    bababbbbbabbbaaabbabbaba
    abbaaaabbabbbaaabaabbabb
    aabbbababaaaababbabbbbab
    abaaabaabbbbabababbbaaababbabaaababaabba
    bbbabbabaaabbabbabbabbbabaaababbaaaababababbbbabbabbabaaabaaabaaaaaabaaababbaabb
    abbbaaabbabaaaaabababbbabababbbbabaabbaa
    aabaaaaabaababbbbaaaaaba
    aaaaaaabbabaaaababbbbaab
    aabaaababbaaabbabaaabaaaaabbaaaababaababbbbbbbbbabaaaaab
    bbbbbbbbbbaabababbbbbbbbaabbabbb
    abbbbbbaaabbbbbbaaaaabaabbbbababbabbabab
    baaababaabbbaaabababbbbb
    bababbbabbabaaabbbabababbbbbabbaabbbabbb
    baaabbbabaabbabbbbabbaba
    ababbbbabbaaaabbbaababbbaaabbbbbbbabbbabaabaabaabbaabbaabbbaabbaaabaabba
    bababbbaababbabbaabaabaabbbbaaab
    aaabaabaaabaabbabbaabbaaabbbaaab
    abaaababbbbbbaabbaabbaab
    aaabbabbaaaaaabbaaabaabb
    bbbabbabbbbabaabbbabbbabbabbaabbabbaaabb
    bbaababaabbaabaaaabbbbba
    ababaaaabaabbbaaaaaababb
    babaabababaaabaabbbabbbbbbbbbbbbbabaabbbabbbbbaaabbaababbaaabaababbbbaba
    ababbabbbaababababbababbbbabaabaababbabbaabbbbaa
    baaaabababbaababaaabaaaaaaabbbaabbababbabaaaaaabbaaabbaaaabaaaaababbbbababbabaab
    aaabbbbaabbabbbbbababaaabababbbbabaabaabaabbbaaaabbbbaab
    aabbbbbbabbaaaabaaabaabb
    bbbaabbbaaaaaaabbbaabaabbababbbaabababbaabbaaabb
    bbbbaaaababbbabababaaabb
    bbaaabbbbababbbababbbaab
    bbabbabbaabbbbabaaaabababaababaa
    abaaabaaabaaababbaababaa
    aabaaabbbaabaaaabbbbbbab
    baabaaabbabaabababbbabaa
    ababbabbbaabbbbbbabbabaa
    abbbbaaabbbabbbbbababaaa
    bbbbbbaabababaaaabaababa
    aabbaabaabaaaabbbaabbaba
    bbbbbbaaaabbaaaaaabbaabaaaaaabbb
    aaaabbbbaaaaabaabaaaaaabaaabaabb
    abaaababbaaaababaaaaaaaaabaabbabababbaab
    babababbabbabaabaabaabbb
    babaaaabbbabbabbbaababab
    aaabbababbbbbbbaabbbbabbbbbbaabbaaabbabbaaaabababaaabbaaababbaab
    abaabbbabaaaabbbabbbababbaaaabbbbabbabaa
    aabbbbaababbaababbbaabaa
    bbaabababbaababaaaabbbaa
    babaababbbbbabaaaabaaabaabbabbbbaaaaaabbbbaababbabaabaaaaabbbaaababbbbbb
    baababbbbaaaaaaabbabbaab
    aaaabbbaababababbbbbbabb
    bbaaaaaaababbbaaaabbabbabbabaaababbbbbbabbbaaaaabbaababbbaababaa
    aaaaaaabbbaaabaabbbabaabbbabaababbaaabaabbaababb
    babaaaabaabbbbaabaaaaaabbaaaaaba
    aabbbaabababbbabbabaaabababbbbbabaababbaaabbaabaaabbaaaabaabbbbbbaaaababbbaabaab
    babaaaaaababbbabaabababb
    babbabbbabbaababbabbbaab
    baabbbabbabbbabbabbbbaaaaaaaaaaaaabaabbaaaababbbabbbaabb
    bbbaabbbbababbabbbbaaabb
    babaabbbbaabaaabaaabababbbaabbbbbbbabbba
    bababbabbaaabbbabbbbbabb
    bbabbbabbbabbbbbbbbaaaab
    baabaaaaabbaaaabababaaaaaaabbaaa
    ababbbaabbabbabbbaabbbba
    abbaabbbaaaabbbbaaaaabba
    bbaababbbbababaaabbaababbabbabaababbbbab
    bbbabbbbaaaaaabbbbaabaaababaaabbaaaababb
    baaaaaabbbbbbabbbbaabbaaababbbbb
    abbbbbbbababbaaaababaabababbabbaabaaabaababaaaaaabababab
    ababababbbaaaaaabababbbbabaaabbb
    baaabbabbbabbbbbbbaaaaabaabababa
    baaababaabbaaaaaabababaababbaababaaaabbbbbbbbaaaabaabbaa
    abbbbbbaababbaabbababaaaaabbbbbaaababbbbaaabbbbb
    aaababaaabaaabaaabaaabbb
    baabaaaabbbbbbaabbaabbba
    ababbbabbbbbabbababbabab
    bbbababaababbbaaaaaaaaaaaaaabababaababab
    aababbbbbabababbbbaaaabb
    bbaaaaaabbabaabaababbbba
    bbabaabaabbabaabbaabbabb
    abbbabaabbbbbbabaaaaabaababaabab
    baabbbaabbbababaaaaabbab
    babaabababbaabbbabaabbbb
    aabaaaaaababbabbabaabbbb
    """
    {rulemap, messages} = inputstr |> Problem.load
    assert 190 == inputstr |> Problem.load |> Problem.part1
  end
  
end
