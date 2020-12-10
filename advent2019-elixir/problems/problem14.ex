

defmodule Util do
  
  def topological_sort(edges) do
    topological_sort(edges, [])
  end
  def topological_sort([], acc) do acc end
  def topological_sort(edges, acc) do 
    # Find all the nodes with no incoming edges.
    all_dsts = edges |> Enum.map(fn {_src, dst} -> dst end) |> MapSet.new
    nodes_no_incoming = edges
    |> Enum.filter(fn {src, _dst} -> not MapSet.member?(all_dsts, src) end)
    |> Enum.map(fn {src, _dst} -> src end)
    |> MapSet.new
    # These are part of our topological sort
    new_acc = acc ++ Enum.sort(nodes_no_incoming)

    # Remove all the nodes with no incoming edges.
    new_edges = edges
    |> Enum.filter(fn {src, _dst} -> not MapSet.member?(nodes_no_incoming, src) end)

    # Keep going
    topological_sort(new_edges, new_acc)
  end
end

defmodule Problem do

  def load_chunk(s) do
    [amt, chem] = s |> String.split(" ")
    {String.to_integer(amt), chem}
  end
  def load_recipe(l) do
    [ingreds, product] = l |> String.split(" => ")
    {ingreds |> String.split(", ") |> Enum.map(&load_chunk/1), load_chunk(product)}
  end
  def load(inputstr) do
    inputstr
    |> String.split("\n")
    |> Enum.map(&String.trim/1)
    |> Enum.map(&load_recipe/1)
  end
  def recipe_to_edges({ingreds, {_req_amt, req_chem}}) do
    ingreds |>
    Enum.map(fn {_prod_amt, prod_chem} -> {req_chem, prod_chem} end)
  end
  def recipes_to_edges(recipes) do
    recipes 
    |> Enum.flat_map(&recipe_to_edges/1)
  end

  def get_requirements(recipes, {req_amt, req_chem}) do
    # "get_requirements {#{req_amt}, #{req_chem}}" |> IO.puts
    matching_recipes = recipes
    |> Enum.filter(fn {_ingreds, {_a, c}} -> c == req_chem end)
    # |> IO.inspect

    # # let's start with 1 match for now, maybe we have to pick the minimum recipe
    [{produced, {recipe_amt, _req_chem}}] = matching_recipes

    # There's a remainder here...
    recipe_iterations = Kernel.ceil(req_amt / recipe_amt)

    for {prod_amt, prod_chem} <- produced, into: %{} do
      {prod_chem, prod_amt * recipe_iterations}
    end
  end

  def ore_required(recipes, nodes, fuel_required) do 
    p1_traverse(recipes, nodes, %{"FUEL" => fuel_required})
    |> Map.get("ORE")
  end

  def p1_traverse(_recipes, [], reqs) do reqs end
  def p1_traverse(recipes, [node|nodes], reqs) do
    # "NODE #{node} REQS #{inspect reqs}" |> IO.puts
    new_reqs = get_requirements(recipes, {Map.get(reqs, node), node})
    all_reqs = reqs |> Map.merge(new_reqs, fn _key, a, b -> a + b end)  # sum up any that exist in both!
    # |> IO.inspect
    p1_traverse(recipes, nodes, all_reqs)
  end

  def part1(recipes) do
    
    nodes = recipes
    |> recipes_to_edges
    |> Util.topological_sort
  
    ore_required(recipes, nodes, 1)
  
  end

  def part2(recipes) do
    one_trillion = 1_000_000_000_000
    
    nodes = recipes
    |> recipes_to_edges
    |> Util.topological_sort
  
    # There are going to be remainders every time
    # Let's try something dumb.  Take the amount of ore for one fuel, 
    #  then start counting up from there until we break one trillion
    #  then let's start counting down until we're below one trillion
    # Wow am I tired...
    ore_count = ore_required(recipes, nodes, 1)

    # Count up in 10000s
    fuel_count = Kernel.floor(one_trillion / ore_count)
    {fc_after, ore} = 1..one_trillion  # a big number at any rate
    |> Stream.map(fn i -> {fuel_count+i*10000, ore_required(recipes, nodes, fuel_count+i*10000)} end)
    |> Stream.drop_while(fn {fc, ore} -> ore <= one_trillion end)
    |> Enum.at(0)

    # Count down in 1s
    {fc, ore} = 1..10000  # a big number at any rate
    |> Stream.map(fn i -> {fc_after-i, ore_required(recipes, nodes, fc_after-i)} end)
    |> Stream.drop_while(fn {fc, ore} -> ore > one_trillion end)
    |> Enum.at(0)
    
    # And there we go
    fc
  end


end

defmodule Tests do 
  use ExUnit.Case

  test "example 1" do
    rows = "10 ORE => 10 A
    1 ORE => 1 B
    7 A, 1 B => 1 C
    7 A, 1 C => 1 D
    7 A, 1 D => 1 E
    7 A, 1 E => 1 FUEL"
    |> Problem.load
    assert 31 == rows |> Problem.part1
  end

  test "example 2" do
    rows = "9 ORE => 2 A
    8 ORE => 3 B
    7 ORE => 5 C
    3 A, 4 B => 1 AB
    5 B, 7 C => 1 BC
    4 C, 1 A => 1 CA
    2 AB, 3 BC, 4 CA => 1 FUEL"
    |> Problem.load
    assert 165 == rows |> Problem.part1
  end

  test "example 3" do
    rows = "157 ORE => 5 NZVS
    165 ORE => 6 DCFZ
    44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
    12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
    179 ORE => 7 PSHF
    177 ORE => 5 HKGWZ
    7 DCFZ, 7 PSHF => 2 XJWVT
    165 ORE => 2 GPVTF
    3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"
    |> Problem.load
    assert 13312 == rows |> Problem.part1
    assert 82892753 == Problem.part2(rows)
  end

  test "example 4" do
    rows = "2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG
    17 NVRVD, 3 JNWZP => 8 VPVL
    53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL
    22 VJHF, 37 MNCFX => 5 FWMGM
    139 ORE => 4 NVRVD
    144 ORE => 7 JNWZP
    5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC
    5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV
    145 ORE => 6 MNCFX
    1 NVRVD => 8 CXFTF
    1 VJHF, 6 MNCFX => 4 RFSQX
    176 ORE => 6 VJHF"
    |> Problem.load
    assert 180697 == rows |> Problem.part1
    assert 5586022 == Problem.part2(rows)
  end

  test "example 5" do
    rows = "171 ORE => 8 CNZTR
    7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL
    114 ORE => 4 BHXH
    14 VRPVC => 6 BMBT
    6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL
    6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT
    15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW
    13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW
    5 BMBT => 4 WPTQ
    189 ORE => 9 KTJDG
    1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP
    12 VRPVC, 27 CNZTR => 2 XDBXC
    15 KTJDG, 12 BHXH => 5 XCVML
    3 BHXH, 2 VRPVC => 7 MZWV
    121 ORE => 7 VRPVC
    7 XCVML => 6 RJRHP
    5 BHXH, 4 VRPVC => 5 LTCX"
    |> Problem.load
    assert 2210736 == rows |> Problem.part1
    assert 460664 == Problem.part2(rows)
  end

  test "go time" do
    rows = "13 WDSR, 16 FXQB => 6 BSTCB
    185 ORE => 9 BWSCM
    1 WDSR => 9 RLFSK
    5 LCGL, 7 BWSCM => 9 BSVW
    6 NLSL => 3 MJSQ
    1 JFGM, 7 BSVW, 7 XRLN => 6 WDSR
    3 WZLFV => 3 BZDPT
    5 DTHZH, 12 QNTH, 20 BSTCB => 4 BMXF
    18 JSJWJ, 6 JLMD, 6 TMTF, 3 XSNL, 3 BWSCM, 83 LQTJ, 29 KDGNL => 1 FUEL
    1 LWPD, 28 RTML, 16 FDPM, 8 JSJWJ, 2 TNMTC, 20 DTHZH => 9 JLMD
    1 SDVXW => 6 BPTV
    180 ORE => 7 JFGM
    13 RLFSK, 15 HRKD, 1 RFQWL => 5 QNTH
    1 RFQWL, 3 NZHFV, 18 XRLN => 9 HRKD
    2 NLSL, 2 JXVZ => 5 GTSJ
    19 SDVXW, 2 BSVW, 19 XRLN => 6 QMFV
    1 CSKP => 8 LQTJ
    4 ZSZBN => 5 RBRZT
    8 WZLFV, 3 QNWRZ, 1 DTHZH => 4 RTRN
    1 CGXBG, 1 PGXFJ => 3 TNMTC
    4 CGCSL => 7 RNFW
    9 CGCSL, 1 HGTL, 3 BHJXV => 8 RSVR
    5 NGJW => 8 HTDM
    21 FPBTN, 1 TNMTC, 2 RBRZT, 8 BDHJ, 28 WXQX, 9 RNFW, 6 RSVR => 1 XSNL
    2 WZLFV => 5 BHJXV
    10 BSTCB, 4 NLSL => 4 HQLHN
    1 JFGM => 7 SDVXW
    6 CSKP => 8 FXQB
    6 TNMTC, 4 BZDPT, 1 BPTV, 18 JSJWJ, 2 DTHZH, 1 LWPD, 8 RTML => 8 KDGNL
    6 XFGWZ => 7 CGCSL
    3 GTSJ => 4 LWPD
    1 WDSR, 1 QNWRZ => 5 XFGWZ
    11 CSKP, 10 SDVXW => 4 QNWRZ
    7 BSVW, 4 QMFV => 1 RFQWL
    12 QNTH, 10 HTDM, 3 WXQX => 3 FDPM
    2 HGTL => 7 PGXFJ
    14 SDVXW => 6 CSKP
    11 HQLHN, 1 GTSJ, 1 QNTH => 5 TMTF
    173 ORE => 9 LCGL
    4 WXQX => 9 BDHJ
    5 BZDPT => 7 NGJW
    1 GTSJ, 23 QNWRZ, 6 LQTJ => 7 JSJWJ
    23 NZHFV, 3 HQLHN => 6 DTHZH
    2 JFGM => 4 XRLN
    20 CGCSL => 9 WXQX
    2 BSTCB, 3 HRKD => 9 NLSL
    1 MJSQ, 1 BPTV => 8 CGXBG
    1 RTRN, 1 RSVR => 3 ZSZBN
    2 NZHFV, 1 BSTCB, 20 HRKD => 1 JXVZ
    2 BZDPT => 5 HGTL
    1 ZSZBN, 14 FDPM => 9 RTML
    3 BMXF => 8 FPBTN
    1 SDVXW, 8 XRLN => 9 NZHFV
    18 QNWRZ, 7 RLFSK => 1 WZLFV"
    |> Problem.load
    assert 387001 == rows |> Problem.part1
    assert 3412429 == Problem.part2(rows)
  end

end
