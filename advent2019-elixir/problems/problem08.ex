
defmodule Util do

end

defmodule Image do
  defstruct [:layers]
  def new(s, {w, h}) do
    %Image{
      layers: s |> Enum.chunk_every(w*h)
    }
  end
end

defmodule Problem do
  def parse(s) do
    s 
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end

  def part1(s, {w, h}) do
    img = s |> Problem.parse |> Image.new({w, h})
    min_zero_layer = img.layers
    |> Enum.sort_by(fn layer -> Enum.count(layer, &(&1 == 0)) end)
    |> Enum.at(0)
    |> IO.inspect
    Enum.count(min_zero_layer, &(&1 == 1)) * Enum.count(min_zero_layer, &(&1 == 2))
  end
end

defmodule Tests do 
  use ExUnit.Case

  test "parsing" do
    assert [1, 2, 3, 4] == "1234" |> Problem.parse
  end

  test "getting layers" do
    img = "123456789012" |> Problem.parse |> Image.new({3, 2})
    assert [[1, 2, 3, 4, 5, 6], [7, 8, 9, 0, 1, 2]] == img.layers
  end
  
  test "part 1 test" do
    s = "123456789012"
    assert 1 == Problem.part1(s, {3, 2})
  end

end

