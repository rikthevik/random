#!/usr/bin/env ruby

$LOAD_PATH << '.'
require 'assert'

=begin

A palindromic number reads the same both ways. The largest palindrome made from the product of two 2-digit numbers is 9009 = 91 × 99.

Find the largest palindrome made from the product of two 3-digit numbers.

=end

def find_palindromes(num_digits)
  max_num = 10**num_digits - 1
  all_palindromes = []
  for i in (1..max_num)
    for j in (1..max_num)
      val = i * j
      if is_palindrome(val)
        all_palindromes.push(val)      
      end
    end
  end
  max_val = all_palindromes.max
  puts "max val for #{num_digits} : #{max_val}"
  return max_val 
end

def is_palindrome(num)
  s = num.to_s
  case s.length
  when 0 then true
  when 1 then true
  else
    left = s[0, s.length/2]
    right = s[s.length/2 + (s.length % 2 == 0 ? 0 : 1)..s.length]
    return left == right.reverse
  end
end

assert { is_palindrome 1 }
assert { is_palindrome 11 }
assert { is_palindrome 121 }
assert { is_palindrome 1221 }
assert { is_palindrome 12321 }

find_palindromes(2)
find_palindromes(3)



