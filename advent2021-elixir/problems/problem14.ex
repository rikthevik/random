

defmodule Util do

end

defmodule Part1 do

  def run(rules, instr, steps_to_run) do
    rmap = rules
    |> Enum.map(fn {mid, left, right} -> {{left, right}, mid} end)
    |> Map.new

    outstr = perform_step(rmap, String.graphemes(instr), steps_to_run)
    {{_, min_freq}, {_, max_freq}} = outstr
    |> Enum.frequencies
    |> Enum.min_max_by(fn {_, freq} -> freq end)

    max_freq - min_freq
  end

  def perform_step(rmap, instr, 0) do instr end
  def perform_step(rmap, instr, steps_remaining) do
    after_step = apply_rules(rmap, instr)
    # after_step |> Enum.join("") |> IO.inspect
    perform_step(rmap, after_step, steps_remaining-1)
  end

  def apply_rules(rmap, instr) do apply_rules(rmap, instr, []) end
  def apply_rules(rmap, [a], acc) do Enum.reverse([a|acc]) end
  def apply_rules(rmap, [a, b|rest], acc) do
      newacc = case Map.get(rmap, {a, b}) do
        nil -> [a|acc]
        mid -> [mid, a|acc]  # don't forget about list reverse at the end
      end
      apply_rules(rmap, [b|rest], newacc)
  end

end

defmodule Part2 do
  def run(rows) do
  end

end

defmodule Tests do
  use ExUnit.Case

  def prepare_row(s) do
    [_, out1, out2, input] = Regex.run(~r/(\w)(\w) -> (\w)/, s)
    {input, out1, out2}
  end

  def prepare(input) do
    input
    |> String.trim
    |> String.split(~r/ *\n */)
    |> Enum.map(&Tests.prepare_row/1)
  end

  test "example" do
    input = "CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C"
    assert 1588 == input |> prepare |> Part1.run("NNCB", 10)

  end

  test "go time" do
    input = "FO -> K
    FF -> H
    SN -> C
    CC -> S
    BB -> V
    FK -> H
    PC -> P
    PH -> N
    OB -> O
    PV -> C
    BH -> B
    HO -> C
    VF -> H
    HB -> O
    VO -> N
    HK -> N
    OF -> V
    PF -> C
    KS -> H
    KV -> F
    PO -> B
    BF -> P
    OO -> B
    PS -> S
    KC -> P
    BV -> K
    OC -> B
    SH -> C
    SF -> P
    NH -> C
    BS -> C
    VH -> F
    CH -> S
    BC -> B
    ON -> K
    FH -> O
    HN -> O
    HS -> C
    KK -> V
    OK -> K
    VC -> H
    HV -> F
    FS -> H
    OV -> P
    HF -> F
    FB -> O
    CK -> O
    HP -> C
    NN -> V
    PP -> F
    FC -> O
    SK -> N
    FN -> K
    HH -> F
    BP -> O
    CP -> K
    VV -> S
    BO -> N
    KN -> S
    SB -> B
    SC -> H
    OS -> S
    CF -> K
    OP -> P
    CO -> C
    VK -> C
    NB -> K
    PB -> S
    FV -> B
    CS -> C
    HC -> P
    PK -> V
    BK -> P
    KF -> V
    NS -> P
    SO -> C
    CV -> P
    NP -> V
    VB -> F
    KO -> C
    KP -> F
    KH -> N
    VN -> S
    NO -> P
    NF -> K
    CB -> H
    VS -> V
    NK -> N
    KB -> C
    SV -> F
    NC -> H
    VP -> K
    PN -> H
    OH -> K
    CN -> N
    BN -> F
    NV -> K
    SP -> S
    SS -> K
    FP -> S"
    assert 3143 == input |> prepare |> Part1.run("FSHBKOOPCFSFKONFNFBB", 10)
  end
end
