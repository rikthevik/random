#!/usr/bin/env ruby

$LOAD_PATH << '.'
require 'assert'

=begin

2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder.

What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?

=end

def run(num)
  factors = (1..num).to_a
  for i in (2..num)
    for j in (i+1..num)
      if j % i == 0
        puts "removing #{i}"
        factors.delete(i) 
      end
    end
  end
  puts factors.inspect
  puts factors.inject(1) { |a,b| a*b }
  num = 1
  while 1
    if factors.all? { |factor| num % factor == 0 }
      puts "returning #{num}"
      return num
    end
    num += 1
  end
end

assert { run(10) == 2520 }
assert { run(20) == 232792560 }

