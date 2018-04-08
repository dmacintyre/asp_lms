"""
lms_floating_point.py

Description: 

Donald MacIntyre - djm4912
"""

import math
import random

def conv(x,h):
    n = len(x) + len(h) - 1
    y = [0]*n
    for i in range(len(x)):
        for j in range(len(h)):
            y[i+j] += x[i]*h[j]
    return y

def dot_prod(x,h):
    y = 0
    if len(x) != len(h):
        print('Length does not match')
    for i in range(len(x)):
        y += x[i]*h[i]
    return y

def shift(x,val):
    res = [0]*len(x)
    n = len(x)-1
    while (n > 0):
        res[n] = x[n-1]
        n -= 1
    res[0] = val
    return res

def main() :

    N = 100000
    n = []
    x = []    
    channel = [10, 3.5, 1]
    weights = [0]*3
    param = 0.25

    for i in range(N):
        n.append(i)
        r = 2*(random.random()-0.5)
        x.append(r)

    d = conv(x,channel)

    shift_reg = [0]*len(weights)

    # LMS Algorithim
    for i in range(N):

        shift_reg = shift(shift_reg,x[i])
        
        lms_res = dot_prod(shift_reg, weights)
        error = d[i] - lms_res
        for w in range(len(weights)):
            weights[w] += 2*param*shift_reg[w]*error

    print(weights)
    
if __name__ == "__main__":
    main()
