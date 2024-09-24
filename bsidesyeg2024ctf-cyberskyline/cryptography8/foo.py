
N = 1909  # n = p * q, the modulus
E = 31
clist = [ int(s) for s in "1079 1189 1155 137 500 572 1659 128 137 404 42 462 42".split(" ") ]

PRIMES = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199, 211, 223, 227, 229, 233, 239, 241, 251, 257, 263, 269, 271, 277, 281, 283, 293]

print("N=", N)
print("E=", E)
print("clist=", clist)


for i in PRIMES:
    for j in PRIMES:
        if i * j == 1909:
            P = i
            Q = j

print("P=", P)
print("Q=", Q)
PHI = (P-1)*(Q-1)
D = pow(E, -1, PHI)

def encrypt(message):
    return pow(message, E, N)

def decrypt(ciphertext):
    return pow(ciphertext, D, N)

print("".join([ chr(decrypt(c)) for c in clist ]))

