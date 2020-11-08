#!/usr/bin/env ruby

=begin

The prime factors of 13195 are 5, 7, 13 and 29.

What is the largest prime factor of the number 600851475143 ?

=end

# Let's do a bunch of work over again!
#  - next we memoize
$stored_primes = {}
def is_prime(n)
  if $stored_primes.has_key?(n)
    return $stored_primes[n]
  end
  for i in 2..(n/2+1)
    if n % i == 0
      $stored_primes[n] = false
      return false
    end
  end
  $stored_primes[n] = true
  return true
end

def bad_solution(num)
  prime_factors = []
  while num != 1
    puts "num=#{num}"
    for i in (2..num)
      if is_prime i
        if num % i == 0
          puts "adding factor #{i}"
          prime_factors.push(i)
          num = num / i
          break
        end
      end
    end
  end
  puts prime_factors.inspect
  max_prime_factor = prime_factors.max
  puts "max prime factor is #{max_prime_factor}"
end

bad_solution(13195)
bad_solution(600851475143)



