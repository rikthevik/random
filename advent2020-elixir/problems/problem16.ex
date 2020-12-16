
use Bitwise

defmodule Util do
  
end

defmodule Problem do
  defstruct [:fields, :mine, :tickets]

  def load_ticket(r) do
    r
    |> String.split(",")
    |> Enum.map(&String.to_integer/1)
  end
  def load_field(r) do
    [match, class] ++ groups =  ~r/^([a-z ]+): (\d+)-(\d+) or (\d+)-(\d+)$/
    |> Regex.run(r)
    
    [class] ++ (groups |> Enum.map(&String.to_integer/1))
    |> List.to_tuple
  end

  def load(inputstr) do
    lines = inputstr 
    |> String.trim
    |> String.split("\n")
    |> Enum.map(&String.trim/1)

    {field_rows, rest} = lines 
    |> Enum.split_while(fn l -> l != "" end)
    |> IO.inspect

    # well that pattern matching sure is effective
    ["", "your ticket:", minestr, "", "nearby tickets:"] ++ ticket_rows = rest

    %Problem{
      fields: Enum.map(field_rows, &load_field/1),
      mine: load_ticket(minestr),
      tickets: Enum.map(ticket_rows, &load_ticket/1),
    }

  end

end



defmodule Tests do 
  use ExUnit.Case

  test "examples" do
    inputstr = "class: 1-3 or 5-7
    row: 6-11 or 33-44
    seat: 13-40 or 45-50
    
    your ticket:
    7,1,14
    
    nearby tickets:
    7,3,47
    40,4,50
    55,2,20
    38,6,12"
    assert 71 == inputstr |> Problem.load |> Problem.part1
  end

  test "part1" do
    
  end

end
