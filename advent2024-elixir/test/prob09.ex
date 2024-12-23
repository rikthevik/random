

defmodule Prob do
  def drop_zero_len(l) do
    l
    |> Enum.filter(fn {_, len, _} -> len > 0 end)
  end


  def run1(rows) do
    rows
    |> drop_zero_len()
    |> traverse()

  end

  def traverse([s={_, _, {:file, _}}|rest]) do
    [s|traverse(rest)]
  end
  def traverse([s|rest]) do

  end


  # def run2(rows) do

  # end
end

defmodule Parse do
  defstruct [:row_num, :idx, :file_id]

  def rows(s) do
    p = %Parse{row_num: 0, idx: 0, file_id: 0}

    {segments, _} = s
    |> String.trim()
    |> String.graphemes()
    |> Enum.map(&String.to_integer/1)
    |> Enum.map_reduce(p, &make_segment/2)

    segments
  end

  def make_segment(len, p) when rem(p.row_num, 2) == 0 do
    # file
    segment = {p.idx, len, {:file, p.file_id}}
    p = %Parse{p|
      row_num: p.row_num+1,
      idx: p.idx + len,
      file_id: p.file_id + 1,
    }
    {segment, p}
  end
  def make_segment(len, p) do
    # free space
    segment = {p.idx, len, :free}
    p = %Parse{p|
      row_num: p.row_num+1,
      idx: p.idx + len,
    }
    {segment, p}
  end



end



defmodule Tests do
  use ExUnit.Case


  test "example0" do
    input = """
12345
"""
    expected = [
      {0, 1, {:file, 0}},
      {1, 2, :free},
      {3, 3, {:file, 1}},
      {6, 4, :free},
      {10, 5, {:file, 2}},
    ]
    assert expected == input
    |> Parse.rows()
  end


  test "example1" do
    input = """
2333133121414131402
"""
    assert 1928 == input
    |> Parse.rows()
    |> Prob.run1()

    # # assert 31 == input
    # |> Parse.rows()
    # |> Prob.run2()
  end

  # test "part1" do
  #   assert 1722302 == File.read!("test/input09.txt")
  #   |> Parse.rows()
  #   |> Prob.run1()
  # end

  # test "part2" do
  #   assert 20373490 == File.read!("test/input09.txt")
  #   |> Parse.rows()
  #   |> Prob.run2()
  # end

end
