
tot = "9 19-5-5-13 20-15 8-1-22-5 12-15-19-20 13-25 6-12-1-19-8-4-18-9-22-5"

out = ""
for s in tot.replace("-", " ").split(" "):
    out += chr(int(s) + ord('a') - 1)
print(out)


