#!/usr/bin/env ruby

$LOAD_PATH << '.'
require 'assert'

=begin

The sum of the primes below 10 is 2 + 3 + 5 + 7 = 17.

Find the sum of all the primes below two million.

=end

# It's the sieve of Erasthones!

Max = 2_000_000
Nums = Array.new(Max, true) # 0..Max-1

# We know that 2 is prime.
Nums[2] = true
currPrime = 2
Primes = [2]

while currPrime < Max
#  puts "currPrime = #{currPrime}"
  currPrime.step(Max, currPrime) { |i| Nums[i] = false }
  prospectiveNewPrime = currPrime+1
  while Nums[prospectiveNewPrime] == false
    prospectiveNewPrime += 1
  end
  if prospectiveNewPrime >= Max
    break
  else
    currPrime = prospectiveNewPrime
    puts "adding new prime #{currPrime}"
    Primes.push(currPrime)
  end
#   currPrime = Nums[currPrime, Nums.length]
#     .map.with_index { |is_prime, num|  puts "#{is_prime} : #{num}" ; is_prime && num } 
#     .detect { |val| val }
end

puts "printing."
puts Primes.inject(0) { |a,b| a+b }

