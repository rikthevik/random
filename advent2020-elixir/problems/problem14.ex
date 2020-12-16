
use Bitwise

defmodule Util do
  
end

defmodule Problem do
  defstruct [:mask, :mem]

  def load_line(line) do
    if String.starts_with?(line, "mask") do
      ["mask", "=", mask] = String.split(line, " ")
      {:mask, mask}
    else
      [m, addrstr, valstr] = Regex.run(~r/^mem\[(\d+)\] = (\d+)$/, line)
      {:set, String.to_integer(addrstr), String.to_integer(valstr)}
    end
  end

  def load(inputstr) do
    inputstr
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&load_line/1)
  end

  def part1(rows) do
    p = %Problem{
      mask: nil,
      mem: Map.new  # indexed by memory addr
    }
    
    p = p 
    |> process_rows(rows)

    p.mem
    |> Enum.map(fn {_addr, val} -> val end)
    |> Enum.sum

  end
  
  def apply_mask(maskstr, val) do
    # those X values don't really do anything
    # we want a bitmask to set a bit, and a bitmask to unset a bit
    setmask = maskstr |> String.replace(~r/[^1]/, "0") |> String.to_integer(2)
    unsetmask = maskstr |> String.replace(~r/[^0]/, "1") |> String.to_integer(2)
    # "setmask=#{setmask} unsetmask=#{unsetmask}" |> IO.inspect
    (val ||| setmask) &&& unsetmask
  end

  def process_rows(p, []) do p end
  def process_rows(p, [{:mask, mask}|rows]) do 
    %{p| mask: mask}
    |> process_rows(rows)
  end
  def process_rows(p, [{:set, addr, val}|rows]) do
    %{p| mem: Map.put(p.mem, addr, apply_mask(p.mask, val))}
    |> process_rows(rows)
  end

  def part1(rows) do
    p = %Problem{
      mask: nil,
      mem: Map.new  # indexed by memory addr
    }
    
    p = p 
    |> process_rows(rows)
    |> IO.inspect

    p.mem
    |> Enum.map(fn {_addr, val} -> val end)
    |> Enum.sum

  end
  
  ##############################

  def part2(rows) do
    p = %Problem{
      mask: nil,
      mem: Map.new  # indexed by memory addr
    }
    
    p = p 
    |> process_rows2(rows)
    |> IO.inspect

    p.mem
    |> Enum.map(fn {_addr, val} -> val end)
    |> Enum.sum

  end
  
  def process_rows2(p, []) do p end
  def process_rows2(p, [{:mask, mask}|rows]) do 
    %{p| mask: mask}
    |> process_rows2(rows)
  end
  def process_rows2(p, [{:set, addr, val}|rows]) do
    newly_set = addrs_for(p.mask, addr)
    |> Enum.map(fn addr -> {addr, val} end)
    |> Map.new

    %{p| mem: p.mem |> Map.merge(newly_set)}
    |> process_rows2(rows)
  end

  def apply_mask_bit({"0", b}) do b end
  def apply_mask_bit({"1", _}) do "1" end
  def apply_mask_bit({"X", _}) do "X" end

  def float_tree(resultstr) do float_tree(resultstr, "") end
  def float_tree([], acc) do acc end
  def float_tree([c|rest], acc) 
    when c == "0" or c == "1" do 
    float_tree(rest, acc <> c)
  end
  def float_tree(["X"|rest], acc) do [
    [float_tree(rest, acc <> "0")],
    [float_tree(rest, acc <> "1")]
  ] end

  def addrs_for(maskstr, addr) do
    addrstr = addr |> Integer.to_string(2) |> String.pad_leading(String.length(maskstr), "0")
    resultstr = Enum.zip(String.graphemes(maskstr), String.graphemes(addrstr))
    |> Enum.map(&apply_mask_bit/1)

    floattree = resultstr
    |> float_tree
    |> List.flatten
    |> IO.inspect
    |> Enum.map(fn s -> String.to_integer(s, 2) end)
    |> IO.inspect
  end

end



defmodule Tests do 
  use ExUnit.Case

  test "functions" do
    mask = "00X1001X"
    assert [26, 27, 58, 59] = Problem.addrs_for(mask, 42)
  end

  test "example" do
    inputstr = "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
    mem[8] = 11
    mem[7] = 101
    mem[8] = 0"
    assert 165 == inputstr |> Problem.load |> Problem.part1
  end

  test "custom simple case" do
    inputstr = "mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX10X
    mem[0] = 0
    mem[1] = 1
    mem[2] = 2
    mem[3] = 3
    mem[4] = 4
    mem[5] = 5
    mem[6] = 6
    mem[7] = 7
    mem[8] = 8
    mem[9] = 9
    mem[10] = 10
    mem[11] = 11
    mem[12] = 12
    mem[13] = 13
    mem[14] = 14
    mem[15] = 15"
    assert 136 == inputstr |> Problem.load |> Problem.part1
  end

  @tag :example2
  test "example2" do
    inputstr = "mask = 000000000000000000000000000000X1001X
    mem[42] = 100
    mask = 00000000000000000000000000000000X0XX
    mem[26] = 1"
    assert 208 == inputstr |> Problem.load |> Problem.part2
  end

  test "go time" do
    inputstr = "mask = 0010011010X1000100X101011X10010X1010
    mem[57319] = 8001842
    mem[29943] = 1246
    mem[3087] = 1055661079
    mask = 0110010X0XXX001100111000X01XX101010X
    mem[52073] = 42874573
    mem[58090] = 125580
    mem[56527] = 55839
    mem[6576] = 6674834
    mask = 1X100010101110001X1111011X001100X010
    mem[688] = 288
    mem[6462] = 467
    mask = 1X100XX01011100X1X1110X11000111XX0X0
    mem[4544] = 38913
    mem[19739] = 27209989
    mem[62629] = 29599367
    mem[59303] = 56895590
    mem[33209] = 99475224
    mem[21064] = 2217881
    mask = 00100101101X0011X0X1001X000011110X11
    mem[59134] = 1621
    mem[9901] = 3962186
    mem[23399] = 15337615
    mask = 00100100X00000X01011X0X1101X0XXX1011
    mem[8460] = 62218793
    mem[8888] = 6132600
    mem[6738] = 81932640
    mem[15913] = 937
    mem[95] = 237
    mem[65076] = 1887
    mem[46066] = 267972
    mask = 0010010110X11X101X1101X11X1001000001
    mem[3111] = 757262
    mem[18053] = 14564
    mem[29590] = 84022571
    mask = 0X100101X01100X1001XXX0X010010011001
    mem[21123] = 50334
    mem[14185] = 1548248
    mem[19142] = 69122
    mem[64375] = 311754222
    mask = 00010100X001001011X00000011X001X11X0
    mem[37483] = 1031
    mem[9051] = 7137857
    mem[1514] = 2951
    mem[65519] = 3840
    mem[2437] = 1853463
    mem[1533] = 121088
    mem[16607] = 404683
    mask = 00X001X01001X0X110X1000000100X0111X1
    mem[43309] = 53816426
    mem[54492] = 8989842
    mem[6603] = 109918
    mask = 0010010X10X0000010110101011100XX0111
    mem[50262] = 518
    mem[19739] = 64862904
    mem[59938] = 1898392
    mem[10940] = 36316297
    mask = X010X10X101110011X1XX01XX01011110110
    mem[51493] = 94841150
    mem[23379] = 66315661
    mem[50538] = 6370026
    mem[20576] = 3105
    mem[524] = 704
    mem[9470] = 572991
    mask = 000001001011100000XXX1X1010000101100
    mem[7193] = 373916
    mem[8235] = 772308
    mem[12693] = 1931
    mask = 0010010110X1011XX01001X010X011110000
    mem[53866] = 29908037
    mem[10876] = 36809
    mem[23306] = 1494967
    mask = X100X1X1101101X010100X0X000111111010
    mem[2279] = 25754
    mem[9932] = 27669
    mem[47170] = 228719
    mem[6716] = 1055009534
    mask = 0000011010X1X000001X010011X0X0110111
    mem[17003] = 3981363
    mem[51032] = 3041968
    mem[6835] = 1135337
    mem[49175] = 34584
    mem[53149] = 390954848
    mem[46857] = 295459
    mem[7176] = 74749
    mask = X0100101101110XX1011X10111X000000101
    mem[20071] = 157
    mem[58690] = 23548755
    mem[6693] = 31361
    mem[29590] = 12352795
    mem[16195] = 167714437
    mask = 1010111000X1110111111X0000X1110X1110
    mem[52261] = 1766
    mem[4528] = 29538045
    mem[3516] = 434
    mem[38224] = 8600086
    mem[42025] = 979
    mask = 00X001X110110X1100X1XX0101100101X1X0
    mem[24095] = 558277
    mem[30451] = 823594660
    mem[32920] = 323822302
    mask = 01000101101X01001X1001X0X011111XX11X
    mem[36330] = 9326
    mem[34800] = 1457445
    mem[6373] = 17674577
    mem[3467] = 28430
    mem[3725] = 873
    mem[23356] = 4092
    mask = X010111X000110011X01101110X1000110X1
    mem[64745] = 861
    mem[62629] = 90934
    mem[47573] = 19952
    mask = 001001XX10110XXXX01X00011010X1011111
    mem[19591] = 82244
    mem[25842] = 62986578
    mem[8674] = 4524
    mem[6754] = 45567
    mem[12321] = 482
    mask = 00010000X0X1100X00100000000101X11101
    mem[22843] = 23521440
    mem[59262] = 89078
    mem[14388] = 13582
    mem[8783] = 803481646
    mem[14301] = 129344
    mem[5993] = 1676992
    mask = 011X0X0X0X11001100111XXX00101100011X
    mem[21656] = 1452
    mem[5972] = 7553794
    mem[14786] = 10451
    mask = 00X0X11X101X0001101001111X1000011X00
    mem[7791] = 1156045
    mem[49175] = 1797840
    mem[52303] = 1002008464
    mask = 00000X00X0X110X0000000000101X101X01X
    mem[54277] = 40348
    mem[41844] = 75483466
    mem[31687] = 209232793
    mem[59303] = 147780
    mask = 01100101X0X10XX100111X00001011011110
    mem[1674] = 212290004
    mem[26705] = 154696825
    mask = 00100X1010110X00001X0X111XX1X11XX101
    mem[55681] = 15384
    mem[8731] = 20029618
    mem[17196] = 1416285
    mem[8939] = 230194
    mem[41925] = 59500490
    mask = 001X01111X1XX0100001110010X001XX0011
    mem[4136] = 43037307
    mem[50432] = 47363915
    mask = X0100100101XX1X110X00111111001X11110
    mem[26775] = 15795
    mem[61416] = 336820014
    mem[24473] = 15435
    mem[7316] = 507
    mem[22980] = 69499
    mem[13539] = 46705434
    mask = 0010XX1110X101010010X00100X001111111
    mem[24797] = 48493
    mem[9976] = 191947
    mem[59649] = 182
    mem[6746] = 293718
    mem[13657] = 22047
    mem[18870] = 917196392
    mask = 0010011110X100101011001110X1X1X01111
    mem[42060] = 3151
    mem[10876] = 14534
    mem[15913] = 3956260
    mem[25587] = 159376
    mem[32389] = 1637604
    mask = 00X0010X1011001010X0000X0X1001010101
    mem[47397] = 1027668
    mem[1387] = 63624
    mem[29590] = 468836
    mem[30511] = 515
    mem[29943] = 160340
    mem[2723] = 3803815
    mask = 0010X100X0X1X10010100001011001011111
    mem[19103] = 37077352
    mem[61704] = 1585
    mem[41739] = 55291
    mem[32874] = 13348645
    mask = 00001X00100X001101111110XX1001X00100
    mem[46960] = 167728
    mem[21575] = 137775190
    mem[39462] = 138444
    mask = 101X01X01XX00X101011100100X000000100
    mem[13982] = 11278
    mem[46054] = 1566730
    mem[62449] = 3637
    mem[34329] = 715394
    mem[42404] = 16695924
    mask = 00100X111011001X000100000100X1000X00
    mem[2279] = 840
    mem[26696] = 296821
    mem[51587] = 564647
    mem[11937] = 1079
    mem[22100] = 1236
    mask = 1001X1111011010XX01XX0000010X1011010
    mem[57157] = 14498
    mem[23458] = 655
    mem[64273] = 23918
    mem[597] = 11056777
    mem[7236] = 223322653
    mem[548] = 21543
    mask = 10101100XX1110X1111X01101X01110100XX
    mem[29908] = 102485547
    mem[55145] = 39744
    mem[25388] = 86457344
    mem[29024] = 8019640
    mask = 0010010110100011101101X0X0XX100X0011
    mem[16691] = 11547863
    mem[18035] = 8789
    mem[17394] = 6550826
    mask = 000XX1001001001XXX1X1001011XX1100110
    mem[33597] = 40949
    mem[31065] = 115749466
    mem[43929] = 32103
    mem[62821] = 2824401
    mask = X01X0X0010111001101100111X0XXX101X0X
    mem[40077] = 250970300
    mem[8235] = 5176
    mem[35379] = 967230664
    mem[50827] = 1594
    mask = X0X0010X1011XX101010000100101011XX10
    mem[43601] = 13382723
    mem[6907] = 112589660
    mem[22980] = 3002394
    mem[59198] = 2452391
    mask = 00100110X01110011011110XX0001010XX00
    mem[21349] = 2720367
    mem[52060] = 251432
    mask = 1X10010110111X01XX1101111X0111X11110
    mem[15848] = 129775
    mem[26474] = 1601
    mem[62050] = 2929
    mask = 00X0X10010110X101X1011X0X010X1X1011X
    mem[12738] = 209893
    mem[39127] = 691
    mem[37474] = 6593
    mask = 0X000X001011100000X000XX00XXX0111100
    mem[96] = 771
    mem[22577] = 12395804
    mem[11733] = 14929
    mem[39189] = 16420782
    mem[38122] = 344179
    mem[24473] = 29413
    mem[62361] = 7509824
    mask = 0000110010X10X1011101111XX1001000011
    mem[57383] = 18264183
    mem[49173] = 1002256
    mem[40502] = 1730
    mask = 0000X110101100010110X100X000X01X1001
    mem[46811] = 623
    mem[17254] = 15990
    mem[22843] = 142075978
    mem[20042] = 1298592
    mask = 00X0X10010X100101X10X0X1000X01010110
    mem[28039] = 0
    mem[38987] = 5698
    mem[4667] = 456552228
    mem[59938] = 113841
    mem[1661] = 239194935
    mask = 0010X100101X100000X0000110XX00X00101
    mem[25449] = 879
    mem[11100] = 174
    mem[22577] = 2923861
    mem[31106] = 4012
    mask = 0010X110001X1X011X11X00X1001X110X0X0
    mem[18863] = 6313
    mem[14786] = 4007
    mem[21058] = 132219
    mask = X010010110011010X1110101001XX000010X
    mem[47349] = 40055
    mem[23379] = 549082
    mask = 00000100X110X001101X101X00101111XX10
    mem[41149] = 7477499
    mem[23458] = 14250047
    mem[13044] = 963453
    mem[37458] = 111364751
    mem[41705] = 367
    mem[13185] = 7794590
    mask = 0X00011110110001X01X01X111100100X11X
    mem[28287] = 3721531
    mem[35201] = 490106021
    mem[28672] = 727
    mask = X0000X01X011001100X1000101000001110X
    mem[36421] = 2447644
    mem[60160] = 3592
    mask = X010010X0011000100100X100000X1001100
    mem[6746] = 371201
    mem[34945] = 3182236
    mem[59562] = 15144669
    mask = 001X010X0000001010111X1110100X001011
    mem[4615] = 23061
    mem[2807] = 1040968
    mask = XX00010110110110101000011011101X10X0
    mem[6693] = 58755
    mem[38797] = 396674
    mem[23126] = 87120667
    mask = 00XX0X001011X00000100X01XX11011101XX
    mem[14398] = 7887686
    mem[4703] = 158831
    mem[43300] = 8079
    mem[10876] = 8090
    mem[36155] = 69377162
    mask = 00X001011011X0001X11000010100010X111
    mem[4691] = 889
    mem[24131] = 841
    mem[3111] = 573
    mem[59595] = 4190992
    mask = 10X01X0XX011XX01101X1010010111011100
    mem[50090] = 34393568
    mem[40454] = 1541981
    mask = 001001X010X1011XX01000XX001010011X11
    mem[45518] = 64768
    mem[7223] = 13641
    mem[6883] = 11
    mask = 00X001X01011000X0X10X1001X001X0X1011
    mem[57682] = 748
    mem[19452] = 225201389
    mem[22103] = 536459809
    mem[2723] = 2729176
    mask = X010X1X1X0110010101X00X1101001101100
    mem[8723] = 4618603
    mem[8105] = 55076921
    mem[56475] = 1208612
    mem[56860] = 2130
    mem[14848] = 121862566
    mem[51119] = 309
    mask = 00X001X01XXX100X1011101100100101101X
    mem[12321] = 26106
    mem[19863] = 252791315
    mem[4783] = 7125184
    mem[36097] = 4119189
    mem[16892] = 123426339
    mem[50749] = 3011
    mem[40525] = 311979314
    mask = 001001001011XX11101110X11X10000X1101
    mem[29971] = 1079180
    mem[3907] = 1658
    mem[58690] = 325
    mem[33904] = 26326
    mem[30812] = 3221
    mask = XX10011000X1X10X11110000X00XX1101X01
    mem[27562] = 5188003
    mem[53549] = 2289833
    mem[19329] = 40507
    mem[36937] = 10709922
    mem[37114] = 28119277
    mem[19704] = 152731162
    mask = 001X01001011X0XX1011XX01X01X00011111
    mem[13220] = 194
    mem[8444] = 750
    mem[34627] = 7676
    mask = X01001101011100011X101X1XX001X110X01
    mem[8518] = 500024
    mem[26339] = 167720610
    mem[35194] = 8020476
    mem[31306] = 650
    mem[36208] = 2498533
    mem[7829] = 2084
    mask = X1000100X01110000X10101X1X11X0X0010X
    mem[2969] = 47624
    mem[36421] = 271067027
    mem[33259] = 696258997
    mask = 00100100101100X0X011011000X1X0X1X101
    mem[52073] = 183
    mem[4886] = 2607677
    mem[29415] = 11034
    mem[34596] = 1435127
    mem[37722] = 439646
    mask = 0010X10010111000X01X101X001010110111
    mem[1533] = 20975777
    mem[41149] = 43835328
    mem[54648] = 8048387
    mem[46044] = 191520012
    mem[10958] = 153
    mask = X01001XXX0110X0X00100010100010X011X1
    mem[20181] = 271
    mem[32998] = 406408
    mem[14963] = 36347
    mask = 000X00001X0X10011011000100010111X001
    mem[8646] = 146616149
    mem[33187] = 3502
    mem[56643] = 2297683
    mem[5056] = 11233
    mem[53643] = 15785
    mask = 00000100101X0010X0100X0010100X010001
    mem[37722] = 36801767
    mem[24131] = 657
    mem[1661] = 33183928
    mem[39578] = 31365
    mem[2279] = 463157769
    mem[13178] = 653666
    mask = X0XX01000X000010101X0001X00X0010X001
    mem[53899] = 49721
    mem[11818] = 1726316
    mask = 11X0XX1X1X11100X101100X000010X101000
    mem[32088] = 373702
    mem[2157] = 280921
    mem[19218] = 181313
    mem[48557] = 81701
    mem[772] = 23956
    mem[6957] = 2202
    mask = 0010001010110000001100111X0X11000XX1
    mem[48029] = 2744455
    mem[51044] = 701
    mem[47708] = 882
    mem[14185] = 194301
    mem[5025] = 1139014
    mem[23787] = 1158165
    mem[53248] = 11539
    mask = 010011XX101101101X10X10X10X001111110
    mem[56312] = 18794001
    mem[23464] = 718595
    mem[24737] = 26239
    mem[62401] = 813
    mem[2788] = 1565
    mem[27597] = 837327137
    mask = 001000101XXX0000001101101000X0XX000X
    mem[7013] = 7376387
    mem[19348] = 216259
    mem[2335] = 5985
    mask = 1000X1000X0X001X10111101XX0X10X00011
    mem[25648] = 1586674
    mem[1794] = 107777
    mem[18172] = 1657
    mem[24832] = 6783821
    mem[57880] = 2318293
    mem[52366] = 256454
    mem[21027] = 762
    mask = 00X00101X011X01100X1010101000X010010
    mem[12321] = 406209
    mem[36784] = 28499376
    mem[23244] = 51197
    mem[18719] = 9764113
    mem[46197] = 727182769
    mem[7765] = 306
    mask = XX100XX0X011100X101X00001001X11010X0
    mem[11226] = 1659513
    mem[59446] = 2081606
    mem[39362] = 61923258
    mem[2279] = 30854
    mem[23647] = 37009
    mem[12290] = 15028301
    mem[51742] = 429002814
    mask = 0110X10X011100110011110X1001110X0100
    mem[7963] = 27124
    mem[26474] = 18578829
    mem[58864] = 7199
    mem[21049] = 3648981
    mem[7599] = 674
    mem[30944] = 3237758
    mem[9365] = 44125
    mask = 1110010XX01110X1101X0010100101101000
    mem[4554] = 32428139
    mem[23227] = 445223
    mem[13006] = 536348
    mem[21735] = 32459971
    mem[18561] = 415004
    mem[41639] = 1210
    mask = XX0X011110110100101X0000X00X01101010
    mem[40990] = 378560
    mem[40502] = 4261
    mem[3070] = 20179
    mem[54648] = 1461025
    mask = 10100X001X1100101X10XX0X001XX1101010
    mem[50898] = 27841850
    mem[38435] = 14871
    mem[2096] = 13218483
    mem[8731] = 46498503
    mask = X01X0100100101110X100X0X111010X1101X
    mem[8881] = 84348735
    mem[27157] = 1435663
    mem[20913] = 895
    mem[47226] = 87319
    mem[9496] = 4563
    mem[53248] = 817412
    mask = X010010010XXX0101011100101100X0010X1
    mem[55812] = 43
    mem[48238] = 462
    mem[29997] = 864862
    mem[41149] = 3867
    mem[95] = 65388249
    mem[47138] = 335
    mask = 00000XXXX001100110X1XXX00010011110X1
    mem[11109] = 332359
    mem[1794] = 455
    mem[21655] = 84763
    mem[53696] = 277
    mem[35194] = 7281
    mem[12347] = 148564745
    mask = X0XXX1XX0001100X100X00100001X1111001
    mem[21885] = 327749
    mem[19892] = 50
    mem[7001] = 863762540
    mem[64928] = 1325
    mem[4136] = 102854
    mem[26467] = 1817
    mask = 10X0X1X0101X1111X01001101100X10X0110
    mem[13982] = 797986
    mem[95] = 519755
    mem[56061] = 5524
    mem[36193] = 9365811
    mask = X010X1100001110X111100XX11X0011110XX
    mem[25557] = 43206
    mem[7223] = 425993
    mem[16504] = 69611
    mem[23638] = 3067
    mem[42437] = 19122365
    mask = 0010X1011011X00X10X111100000X1X00100
    mem[39578] = 1682305
    mem[28610] = 57814005
    mem[15619] = 37566
    mem[4919] = 9168
    mem[36937] = 870
    mem[56743] = 22379353
    mask = X0100X10101X1000111110011000X1XX1X1X
    mem[33492] = 6823
    mem[482] = 4554
    mem[35054] = 10840739
    mem[19863] = 796
    mem[31177] = 3100127
    mem[6355] = 9672179
    mem[53388] = 10479412
    mask = 00XX0111XX1X001100XX00110100110X1101
    mem[21049] = 3494057
    mem[13566] = 32179
    mem[47170] = 16081
    mask = 00001100X00X00101010000100000X0X1X10
    mem[2335] = 113671
    mem[64370] = 1163
    mem[19142] = 30303
    mem[8044] = 318278042
    mem[30347] = 13864150
    mask = 0XX0XXX0001011011011001X100010X0X000
    mem[12616] = 1894086
    mem[62427] = 29002
    mask = X010011010110000001XX001000XX0000101
    mem[43617] = 84114
    mem[37229] = 58103"
    assert 4886706177792 == inputstr |> Problem.load |> Problem.part1
    assert 3348493585827 == inputstr |> Problem.load |> Problem.part2    
  end
  


end