#!/usr/bin/env python3

print("Welcome! Please wait for the secret ...")
print()

from Crypto.Util.number import getStrongPrime
from random import randint
from hashlib import sha256

FLAG = 'REDACTED'

g = 3
p = getStrongPrime(1024)
secret = randint(2**1023, 2**1024)

print(f'g = 3')
print(f'p = {p}')
print(f'secret = {secret}')
print()

try:
    user_secret = input('Enter your secret: ')
    print()

    user_secret = int(user_secret)

    if user_secret == secret:
        print("I gave you my secret and you still couldn't get it!")
        exit()

    user_shared = pow(g, user_secret, p)
    shared = pow(g, secret, p)

    if sha256(str(user_shared).encode()).digest() == sha256(str(shared).encode()).digest():
        print(f'Well done, you are the first! Here is your flag: {FLAG}')
    else:
        print(f'No flag for you!')

except Exception as e:
    print("No flag for you!")
