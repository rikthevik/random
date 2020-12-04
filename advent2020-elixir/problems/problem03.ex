
defmodule Util do

end

defmodule Hill do
  defstruct [:w, :h, :trees]
  def new(input) do
    lines = input
    |> String.trim
    |> String.split("\n")

    height = lines |> Enum.count
    width = lines |> Enum.at(0) |> String.length
    trees = for {l, y} <- Enum.with_index(lines), {c, x} <- Enum.with_index(String.graphemes(l)), c == "#" do
      {x, y}
    end |> MapSet.new

    %Hill{
      h: height,
      w: width,
      trees: trees
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
    assert h.trees |> Enum.count == 37
  end


end
