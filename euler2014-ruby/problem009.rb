#!/usr/bin/env ruby

$LOAD_PATH << '.'
require 'assert'

=begin

A Pythagorean triplet is a set of three natural numbers, a < b < c, for which,

a2 + b2 = c2
For example, 32 + 42 = 9 + 16 = 25 = 52.

  There exists exactly one Pythagorean triplet for which a + b + c = 1000.
  Find the product abc.

=end

def run(total)
  for a in 1..total
    for b in a..total
      for c in b..total
        if a + b + c == 1000
          if a*a + b*b == c*c
            puts "a=#{a} b=#{b} c=#{c}"
            return a*b*c
          end
        elsif a + b + c > 1000
           break 
        end
      end
    end
  end
end

assert { run(1000) == 31875000 }
puts "done!"

