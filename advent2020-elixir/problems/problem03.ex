
defmodule Util do

end

defmodule Hill do
  defstruct [:w, :h, :map]
  def new(input) do
    lines = input
    |> String.trim
    |> String.split("\n")

    %Hill{
      h: lines |> Enum.count,
      w: lines |> Enum.at(0) |> String.length,
      map: []
    }
  end
end


defmodule Problem01 do

end

defmodule Tests do 
  use ExUnit.Case

  
  test "load" do
    h = Hill.new("..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#")  
    assert h.w == 11
    assert h.h == 11
  end


end
