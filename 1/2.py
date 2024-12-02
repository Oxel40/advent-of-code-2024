from collections import defaultdict

l1 = []
l2 = []

while True:
    i = input()
    if i == "":
        break
    m = map(int, i.split())
    l1.append(next(m))
    l2.append(next(m))

m = defaultdict(int)

for c in l2:
    m[c] += 1

s = 0
for c in l1:
    s += int(c) * m[c]

print(s)
