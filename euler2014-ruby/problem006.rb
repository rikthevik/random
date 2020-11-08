#!/usr/bin/env ruby

$LOAD_PATH << '.'
require 'assert'

=begin

The sum of the squares of the first ten natural numbers is,

12 + 22 + ... + 102 = 385
The square of the sum of the first ten natural numbers is,

  (1 + 2 + ... + 10)2 = 552 = 3025
  Hence the difference between the sum of the squares of the first ten natural numbers and the square of the sum is 3025 − 385 = 2640.

  Find the difference between the sum of the squares of the first one hundred natural numbers and the square of the sum.

=end

def sum_squares(num)
  (1..num)
    .map { |a| a*a }
    .inject(0) { |a,b| a+b }
end

def square_sum(num)
  tot = (1..num).inject(0) { |a,b| a+b }
  tot * tot
end

def run(num)
  square_sum(num) - sum_squares(num)
end

assert { sum_squares(10) == 385 } 
assert { square_sum(10) == 3025 }
assert { run(10) == 2640 }
assert { run(100) == 25164150 }


