import random
import math
def f1(x,y):
    result = random.uniform(-100,100) * x**2  - math.sin(y**2) + abs(y-x)
    return result
def f2(x, y):
    result = random.uniform(-1,1) * y**3 - math.cos(x**2) + 2*x
    return result