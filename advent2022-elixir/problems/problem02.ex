
defmodule Common do
  def shape_for_input("A") do :rock end
  def shape_for_input("B") do :paper end
  def shape_for_input("C") do :scissors end

  def shape_for_response("X") do :rock end
  def shape_for_response("Y") do :paper end
  def shape_for_response("Z") do :scissors end

  def outcome_for_desired("X") do :lose end
  def outcome_for_desired("Y") do :draw end
  def outcome_for_desired("Z") do :win end

  def score_for_response(:rock) do 1 end
  def score_for_response(:paper) do 2 end
  def score_for_response(:scissors) do 3 end

  def score_for_outcome(:win) do 6 end
  def score_for_outcome(:lose) do 0 end
  def score_for_outcome(:draw) do 3 end

  def outcome_for_round(x, x) do :draw end
  def outcome_for_round(:rock, :paper) do :win end
  def outcome_for_round(:rock, :scissors) do :lose end
  def outcome_for_round(:paper, :scissors) do :win end
  def outcome_for_round(:paper, :rock) do :lose end
  def outcome_for_round(:scissors, :rock) do :win end
  def outcome_for_round(:scissors, :paper) do :lose end

  def response_for_round(x, :draw) do x end
  def response_for_round(:rock, :win) do :paper end
  def response_for_round(:rock, :lose) do :scissors end
  def response_for_round(:paper, :win) do :scissors end
  def response_for_round(:paper, :lose) do :rock end
  def response_for_round(:scissors, :win) do :rock end
  def response_for_round(:scissors, :lose) do :paper end
end

defmodule Part1 do
  def parse_symbols([a, b]) do
    [Common.shape_for_input(a), Common.shape_for_response(b)]
  end

  def run(rows) do
    rows
    |> Enum.map(&parse_symbols/1)
    |> Enum.map(&score_for_round/1)
    |> Enum.sum()
  end

  def score_for_round([input, response]) do
    Common.score_for_outcome(Common.outcome_for_round(input, response)) + Common.score_for_response(response)
  end
end

defmodule Part2 do
  def parse_symbols([a, b]) do
    [Common.shape_for_input(a), Common.outcome_for_desired(b)]
  end

  def run(rows) do
    rows
    |> Enum.map(&parse_symbols/1)
    |> Enum.map(&score_for_round/1)
    |> Enum.sum()
  end

  def score_for_round([input, desired]) do
    Common.score_for_outcome(desired) + Common.score_for_response(Common.response_for_round(input, desired))
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    s
    |> String.split(~r/ +/)
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
      input = "A Y
      B X
      C Z"
      assert 15 == input |> prepare |> Part1.run
      assert 12 == input |> prepare |> Part2.run
      # assert 5 == input |> prepare |> Part2.run
  end

  test "go time" do
    assert 13221 == ProblemInputs.problem02 |> prepare |> Part1.run
    assert 13131 == ProblemInputs.problem02 |> prepare |> Part2.run
  end
end
