#!/usr/bin/env ruby

$LOAD_PATH << '.'
require 'assert'

=begin

By listing the first six prime numbers: 2, 3, 5, 7, 11, and 13, we can see that the 6th prime is 13.

What is the 10 001st prime number?

=end

Primes = [ 2 ]

def _is_prime(n)
  upper_bound = Math.sqrt(n).to_i
  for i in Primes
    if i == n
      return true
    elsif n % i == 0
      # puts "isn't prime based on primes"
      return false
    end
  end
  for i in Primes[-1]..upper_bound
    if n % i == 0
      # puts "isn't prime based on new count"
      return false
    end
  end
  # puts "is prime - created new prime #{n}"
  Primes.push(n)
  return true
end

def is_prime(n)
  retval = _is_prime(n)
  # puts "is_prime(#{n}) => #{retval}"
  return retval
end

i = 2
while Primes.size < 10001
  is_prime i
  i += 1
end

puts "#{Primes[-1]}"


