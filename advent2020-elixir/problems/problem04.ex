
defmodule Util do

end


defmodule Problem do

  def load(inputstr) do

  end

  def part1(h) do
  end

  def part2(h) do
   
  end

end

defmodule Tests do 
  use ExUnit.Case
  
  test "example" do
  inputstr = "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
   byr:1937 iyr:2017 cid:147 hgt:183cm
   
   iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
   hcl:#cfa07d byr:1929
   
   hcl:#ae17e1 iyr:2013
   eyr:2024
   ecl:brn pid:760753108 byr:1931
   hgt:179cm
   
   hcl:#cfa07d eyr:2025 pid:166559648
   iyr:2011 ecl:brn hgt:59in" 
  assert inputstr |> Problem.load |> Problem.part1 == 2

  end

  test "go time" do
    
  end


end
