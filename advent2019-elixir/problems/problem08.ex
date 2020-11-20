
defmodule Util do

end

defmodule Image do
  defstruct [:layers]
  def new(s, {x, y}) do
    %Image{
      layers: s |> Enum.chunk_every(x*y)
    }
  end
end

defmodule Problem do
  def parse(s) do
    s 
    |> String.graphemes
    |> Enum.map(&String.to_integer/1)
  end
end

defmodule Tests do 
  use ExUnit.Case

  test "parsing" do
    assert [1, 2, 3, 4] == "1234" |> Problem.parse
  end

  test "something" do
    img = "123456789012" |> Problem.parse |> Image.new({3, 2})
    assert [[1, 2, 3, 4, 5, 6], [7, 8, 9, 0, 1, 2]] == img.layers
  end
  
end

