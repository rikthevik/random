
defmodule Problem do
  def fuel_required(mass) do
      req = Float.floor(mass / 3.0) - 2
      "fuel_required(#{mass}) => #{req}" |> IO.puts
      req
  end

  # memoize?
  # tail recursion?
  def fuel_required2(mass) do
    "fuel_required(#{mass})" |> IO.puts
    req = inner_fuel_required2(mass)
    "fuel_required(#{mass}) => #{req}\n" |> IO.puts
    req
  end

  def inner_fuel_required2(mass) do
    req = Float.floor(mass / 3.0) - 2
    " inner_fuel_required(#{mass}) => #{req}" |> IO.puts
    if req <= 0 do
      0
    else
      req + inner_fuel_required2(req)
    end
  end

  def run(inputs) do
    inputs |> IO.inspect
    "PART 1" |> IO.puts
    Enum.sum(for i <- inputs, do: Problem.fuel_required(i)) |> IO.puts

    IO.puts("")
    "PART 2" |> IO.puts
    Enum.sum(for i <- inputs, do: Problem.fuel_required2(i)) |> IO.puts
  end
end

[
  12,
  14,
  1969,
  100756,
] |> Problem.run()

"""
140005
95473
139497
62962
61114
66330
54137
77360
108752
142999
92160
65690
139896
135072
141864
145599
140998
134694
126576
141438
112238
77339
116736
64294
77811
83634
102059
146691
104534
61196
105119
125791
124352
125501
68498
96795
82878
126702
74334
126798
131179
109231
101065
115470
54542
148706
101296
63312
85799
98328
105926
101047
85470
78531
52510
98761
123019
79495
74902
103869
57090
138222
121620
109994
64769
148785
132349
80485
95575
66123
56283
101019
142671
147116
148490
114580
107192
115741
107455
62769
139998
146798
90032
72028
144485
91251
51054
148665
113542
148607
141060
88025
109776
62421
64482
130387
120481
135012
55101
67926
""" \
  |> String.trim() |> String.split() |> Enum.map(&String.to_integer/1) |> Problem.run()
