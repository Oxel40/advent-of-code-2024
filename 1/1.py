l1 = []
l2 = []

while True:
    i = input()
    if i == "":
        break
    m = map(int, i.split())
    l1.append(next(m))
    l2.append(next(m))

l1.sort()
l2.sort()

s = 0
for a, b in zip(l1, l2):
    s += abs(a - b)

print(s)
