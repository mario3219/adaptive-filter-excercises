k1 = 0.8
k2 = 0.1111
k3 = 0.125

def rec(p,k):
    return p*(1-k**2)

p0 = 1
p1 = rec(p0,k1)
p2 = rec(p1,k2)
p3 = rec(p2,k3)

print(p0,p1,p2,p3)

print(0.5*0.9**2)