
defmodule Util do

end


defmodule Problem01 do

end

defmodule Tests do 
  use ExUnit.Case

  def prepare(input) do
    regex = ~r/^(?<lo>\d+)-(?<hi>\d+) (?<c>.): (?<s>\w+)$/
    input
    |> String.trim
    |> String.split("\n")
    |> Enum.map(fn s -> Regex.named_captures(regex, s) end)
  end

  test "input" do
    input = "1-3 a: abcde
1-3 b: cdefg
2-9 c: ccccccccc"
    input |> prepare() |> IO.inspect
  end
end
