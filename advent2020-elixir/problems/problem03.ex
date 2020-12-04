
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
    trees = for {y, l} <- Enum.enumerate(lines), x <- 0..(width-1) do

    end |> IO.puts

    %Hill{
      h: height,
      w: widfth,
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
  end


end
