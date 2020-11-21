
defmodule Util do

end

defmodule Image do
  defstruct [:w, :h, :layers, :pixels]
  def new(ints, {w, h}) do
    layers = ints |> Enum.chunk_every(w*h)
    pixels = for i <- 0..(w*h-1) do
      layers |> Enum.map(fn layer -> Enum.at(layer, i) end)
    end
    %Image{
      w: w,
      h: h,
      layers: layers,
      pixels: pixels,
    }
  end

  def pixel(img, {x, y}) do
    # "pixel #{x} #{y} == #{img.w * x + y}" |> IO.puts
    img.pixels
    |> Enum.at(img.w * y + x)
    |> Enum.drop_while(fn c -> c == 2 end)
    |> Enum.at(0)
  end
end

defmodule Problem do
  def parse(s) do
    # String.split("") doesn't do what I thought.  This does.
    String.graphemes(s)
    |> Enum.map(&String.to_integer/1)
  end

  def part1(s, {w, h}) do
    img = s |> Problem.parse |> Image.new({w, h})
    min_zero_layer = img.layers
    |> Enum.sort_by(fn layer -> Enum.count(layer, &(&1 == 0)) end)
    |> Enum.at(0)
    # |> IO.inspect
    Enum.count(min_zero_layer, &(&1 == 1)) * Enum.count(min_zero_layer, &(&1 == 2))
  end

  def part2(s, {w, h}) do
    img = s |> Problem.parse |> Image.new({w, h})
    IO.puts ""
    for y <- 0..(h-1) do
      for x <- 0..(w-1) do
        case img |> Image.pixel({x, y}) do
          0 -> " "
          1 -> "X"
        end |> IO.write
      end
      IO.puts ""
    end
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
  
  test "part 2 test" do
    s = "0222112222120000"
    Problem.part2(s, {2, 2})
  end

  test "part 1 real talk" do
    s = "222222212222222021202220222222002222022222222222202222202222122220222210222222222222222222222202022022222220222221212012102222222212220221222122202222222222222222222020202222222222102222222222222222222222202222022222222212222222222222222222222202122122222222222222202222102222222212222222202022202222222222222222222122202220222222122222222222222222212222212222122222222200222222222222222222222202222022222221222221222102112222222222222220222022212222222222202222222120212220222222212222222220222122222222202222122221222211222222222222222222222202022122222222222221212012222222222202221222202222222222222222202222222020202220222222112222022220222222212222202222222222222201222222222222222222222212022022222221222222002022202222222222222220212022212222212222212222222122202220222222102222022220222022222222202222222222222221222222222222222222222212122022222221222221012012112222222202222222202222222222202222202222222021222222222222102222122220222122202222202222022222222202222222222222222222222202022222222221222221212202112222222212222222222122202222202222212222222121202220222222202222122222222022222222222222022220222210222222222222222222222202122222222122222220212112202222222222222220212122212222212222212222222220202222222222222222022220222222202222202222222221222202222222222222222222222212222122222221222220202022012222222202222221212022222222212222202222222020212221222222012222122221222122222222222222222222222211222222202222222222222212222122022120222220102002222222222212220221202022222222212222222222222022212221222222002222222222222222222222202220122220222220222222212222222222222222122122022121222221202002002222222212220221222222202222212202222222222020222222222222122222022222022222222222222222122221222221222222212222222222222212222022022021222222022022112222222212220222222122202222212222201222222020212220222222012222122222122222212222202221022220222211222222202222222222222212122122022120222222212202202222222222222222212122212222212202222222222022212220222222112222222222122222212222222220022221222211222222210222222222222222122222122220222221212202002222222222220221212222212222202202211222222221202220222222122222222221222022202222202220222221222200222222210222222222222202122122022121222221022022112222222222221222212122222222202222222222222121212222022222222222022221122022222222212221222220222221222222211222222222222222122122222121222222012022212122222212221220212222222222212212211222222221222220022222122222222222022022222222212222022221222202222222202222222222222212222122022021222220102012222222222222220222202022212222212202222222220121212221222222022222222221122022212222222222222221222202222222222222222222222222022022222020222220010002222122222222220220212122222222212212221222220220222221122222112222222221122022202222202221022220222201222222211222222222222202122122122221222221002212212122222202221220222022212222222202220222221122212220222222022222022221222022222222202221022220222210222222200222222222222222122222222020222222020012012222222212221220222022212222222212221222220120212220122222222222222221222022212222222221022222222202222222222222222222222222222022022220222221110022112122222222221221212122222222212212221222221222222221022222102222022221022022222222202220122221222221222222201222222222222222022122122121222222020222202222222222222220202122222222222202201222221122212220222222212222122220222122222222202220022221222202222222201222222222222202022222022122222222012212012022222222220222202022202222202212220222221221222220122222112222022220222222212222222220222221222210222222220222222222222212122022022121222222111112112122222222222221222222202222222202222222222222222221022222022222122220122122202221222222202221222221222222222222222222222222222222122122222222001112022222222202222221222122202222212222210222222122222220022222212222122222222022222221212221012220222210222222221222222222222201122222222222222221210202022022222222222222202222222222212212212222220022222221222222222222122222222122202222212221222220222221222222201222222222222210122222122122222220210022022122222212221220202022222222202222211222221121212222222222102222022222022222212222212220102222222211222222210222222222222210122022122222222221011102012022222222222221222022222222222212220222220122222221222222022222222220122022202220202220022222222212222222221222222222222220122022122222222221101202022122222202220221202022222222212212210222220120212222122222012222222220122022222220222220212221222202222222200222222222222221222222122022222220000122012122222212221221212122222222202202212222220121222221022222222222122221122222212220202222222221222212222222221222222222222211220122122222222220122112022122202212221221202122222222202212212222222122212221122222222222022220122022202221222220002222222211222222222222222222222202222222122020222220221202022221222222220222020222222222222202222222222221212220122222212222022202022222202221202220102222222001222222212222222222222201020022222221222220121002012202202202220222012222202222212202211222220122212221022222202222022212122222222222202222212222222002222222212222222222222211220022022220222222010212102211212021221221222122222222212212212222222122202220122222002222122200122122222221212222102220222010222222211222212222222202020222122021222221011022102100212011220221112122212222222212212222221021222221222222222222122222022022202220202220122222222020222222221202202222222202121122022221222221120022102000222202220222221122212222222202211222222122222222022222022222222222022222212221222220212221221100222222221212202222222212222022222120222221121110012011222000220222112222222222202222221222220020222222122222212222222220122022202220202221222221221101222222220202202222222201121022222122222221021122102220202122221220011022222222212212210222221120202220222222102222222210022222222222222221112220221201222222222222202222222211222222022221222220110020222112212000222221010022222222022202210222220222202220122222022222122202122122202220212220122221222211222222200202202222222200122022022022222220010010212012202022220220021122212222022222222222221020222221122222102222222201222022222220212220112221221222222222200202212222222210121122022220222222210201202110212221221222001222202222002202201222221022212222122222222222122220222022212220222220222222220021222222201222212222222220020122022220222222122222012102212002221222021122202220012222201222220020212221222222222222122202222122202222222220212221220111222222212212212222222210220122222121222222202210022100202222222220212022202122122222201222222221202222222222212222222211222122202221222220122222222202222212221212202222222201221122022222222220021101112112222200221222121222222022212212222222222222212221022222202222122221122222202221212221212221221111222202221212212222222210121122122121222220112001212121212000220221120122202121012202210222222222202220122222122222122201222222212221222220122221221020222222202222212222222220222022022121222220222121122022202201221221202022212021212202210222222220212222122222212222222221022222212222202222222220222021222222212202202222222220222022222022222222012110222220202021220220201222222120012222201202221122222221022222012222222222122022212221222222202222221212222202211222212222222201121012122022222220202110002011202202221220022122222221222202202212221021212220222222212222022200022222212222202222012220220101222212211202212222222221220212222121222220002102022110202110220220010122221120112212200222220122222222022222222222122222222222212220222222102220221101222212221222212222222202221102222221222221100210222200212121222220000022221021222222210202221122202221222222202222222010222122212222202220022222221112222212202202222222222220222112022022222221020100012002222021221220112022210122102222220222220020212222022222112222122201222222222222222222122222221110222202211212202222222201220122022221222222112212222110222022222220000122212221022222221202221121222221022222002222122100022222222222222220212220220202222222211212212222222202222212022120222221022010022210202220222222200222200120012212211212222020212222222212102222222011222122212222212222212221222002222212211202202222222212020002122122222221121110002020202122220222121022201221002212200202221021202221222212122222222101122022222220210222122222221111222212221212202222222211021202022220222222120210222112222002222220210222221021122222222202221020202221022202212222022120022022202221222220012222220022222202222222202222222200020222022002222222121022212102202001221222221122220220222202221202221021202220022212012222122211022022202220201220222220222210222212221222222222222211222122022101222220221101212022212211221222112222220022022212212222222022202222122202022222222111022222202221201221022222220022222202220210222222222211120022022110222222012002002001222010221222201022210220112222220202221222202221122212002222022210212022222221222202212220221121222222220222202222222222120012122001222220122200012020212220222220120222200222212222210202222021212210112222212222122121022122212221211222222220221021220202212201212222222211021212122000222220222022022210202112222220120022022220102202200202222220202202222212112222022022022120202221200210202221220012221222212202222222222221122110120220222221002000022020202202222222002022221022022212212212221022212202220202102222122210222022222220212202212220222221220212220221212222222221120101121222222221001210212022202202220220202122002022222202200222222122222220112202102222222121222121222220202210002222222211221202200220202222222222120011021201222220212000012022222000221221000222120222012222211202220022212220120222122222222121122221202220221222112221222012222222210220202222222222221220221122222220120101202210212021221222022122111120112222212202221120212220211002112222122101222220202222201210002221222200221202200212212222222202022010022121222220022201222211222012220222222222200022212202201202220222202200220102022222122201002122222222201221022220221102221212212221212222222222121121020222222220110210102210202000222220000222120222202212202212220001212212100022222222022222122220212222222210022221221021220222200222222222222221120200121010222220010221222221012022220222111222220121112202212222220212202220021212102122122100012221222221202221222222221211221202201212202222222210222110020201222220121201102020022121221221011222000220122222201222220122202212212122002122022100112022222220211212212200220111220202221212222222222202120000121221222221102210102122212012222222101122000120012202202201222111212212100100102222022202112120222221211200202200221002222212202201202222222222221202021101222220000001122201002021222220221122101022112212212212222211222210100000102002022101022222202221200222102221220002221212211211222222222210222011120000222220211222012002022201222220021022011022002222220212222222202210100122022122222020120222212220211211012211220211220212211211212222222221121112122122222221211211202010201001220221110120100221122222211202220200202201221201202202122122011221202221212220002212220111221202200221212222222222221012121000222220102011022202211010222222010020101221122202222201220200202210000120102202222000120122202220212211212210221202221202101202212222222200020021122221222220222002022101212010222220111022020020022222202220220020212222202110220212122021012020202221211200022200222010222212122221212222222210120012210112222222111211022001211020221222012122202021102212210212221111222201122022111102222220112021222220222200022221022202222212222221222022222211120211211012222220001201102000110222221220000022211220112001210222222010212200220112121212222110121120212220202202222202122012220212012222202022222201122020110212222220100012212021102112220220202222221120202102212211221000222200011102221202022102000021222221202220212221022202220202002220202022222220121211121010222221201102012002021201222222022120200221112100202221220211212201220101022022022020220020212221202222012202022122222212100202202122222210002002111212222221211210012120012211221220021122010022022212200002221111202221101001012222122022221222202222211222012221121110220212212200212122222221212020111122222021102101022210000021220221012221102120222011212102220000212211120221022002022012011020212220201211012200020022220222200122212022222200112220001012222121200220002212110212222221201122020121222011211210222200222222110021001212022020211020212221211212112212121011222202000221212122222220100112120111222120002221222201010222222220221011012122022100210001222120222211221011122202122002101020222221201200022210221022220212211101202220222201222201202111222222212211002122110022221221110112210120112001211010221201202212221111011222122100100122202220201202102012122200222202111121212020222210001222122201222121221022012022002001221220020200021121202220221112220002222200222222012102022010211221212220212212012210122021220222112211212021222202222112222102222121210002110011121221221220001011012222122110201001221201202210212110202112222111101020222220022212002200022100220201012120202121222222002001100002222122200120210221201221222221011201020222122020211010222211202200120010021001122110000200212221202201122212222110221211010212222021222210210101200210222022010002212021110000220221120200100022102002211202221001212202120011111021122221021010222221120201122020120100222200110001202022220210222201011221022221011000021011222121221220120211221020212002210102221000212222121112112112122000002100212222101210212211122022221220200122202221220210100111221002222021011212110200110222222221202100002220102212211112222222202202201012002202122220201201212221121210212021220201221211210111212122221211110022200001122021002021212100011101221221012020010122212002222101220211222210212000202221122011100011212222212210122220121120222211101111222222220212211102001012122121102102211101201222220222112012122222112222201210221101212221210221010001222102211120212220211220112222122211220220000011212120220222112111020102222121220001102021201121121220002121020120122000202022222010212220202220121212122012102201202220102210122212021022221221111101202222220212111211021220122021210121120221202121121222001011010021122000222021220200212210210221122021122022212212222222220202122112220201220221001211212121222212021102210022122121020221220010220221220212000200200121222002221211222101212210221212220110022002210012222222212202002212022220220200211120212121222220210110111110222121100010110011002210022221011211201100112011111212220211222221222102221010122200110202212221221211102102022111220212122001222122221210010221110211022021021120122100011111022212122201222211112121112201220112212212201122221222222112020122212220211210122010021022222221002121212222221212000222111011022022221022211222022102122200111222100121222101002210220112212212121000102201122022022221222221101102012222222111221222100221202122221210021212220112122222012000210011211210120222100002210021222000011101222222202220022121221212222221022012222200201022222121222111222221212221212022221220000011011202022221101020022021022020021012220001221102221000210222100200110120021022202112101020002010101020122202220021100022000111211012000100001112012120202000101201201010211010200200011120101011020022"
    assert 2440 = Problem.part1(s, {25, 6})
    Problem.part2(s, {25, 6})
  end

end

