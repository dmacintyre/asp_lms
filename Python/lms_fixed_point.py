"""
lms_fixed_point.py

Description: 

Donald MacIntyre - djm4912
"""

import math
import random

# Q15 fixed point format
NUM_BITS = 16
MAX_VAL = (2**(NUM_BITS-1))-1
MIN_VAL = -(2**NUM_BITS)
RESOLUTION = 1 / MAX_VAL

def conv(x,h):
    n = len(x) + len(h) - 1
    y = [0]*n
    for i in range(len(x)):
        for j in range(len(h)):
            y[i+j] += floating_point_multiply(x[i], h[j])
    return y

def dot_prod(x,h):
    y = 0
    if len(x) != len(h):
        print('Length does not match')
    for i in range(len(x)):
        y += floating_point_multiply(x[i], h[i])
    return y

def shift(x,val):
    res = [0]*len(x)
    n = len(x)-1
    while (n > 0):
        res[n] = x[n-1]
        n -= 1
    res[0] = val
    return res

def floating_point_to_fixed_point(n):
    return round(n / RESOLUTION)

def fixed_point_to_floating_point(n):
    return n * RESOLUTION

# Multiply to Q15 numbers and return a Q15 number
def floating_point_multiply(x1, x2):
    #Q15 * Q15 produces a Q30 number
    temp = x1*x2
    #r is now a Q30 number. Convert back to a Q15 by shifting right by 15
    # i.e. divide by 32768
    temp //= 32768
    if temp > ((2**15)-1):
        print('OVERFLOW', temp)
    elif temp < (-(2**15)):
        print('UNDERFLOW')
    return temp

def main() :

    N = 10000
    n = []
    x = []    
    channel = [0.5, 0.0, 0.1]
    channel_fixed = []
    for i in channel:
        channel_fixed.append(floating_point_to_fixed_point(i))
    weights = [0]*4
    param = 1

    for i in range(N):
        n.append(i)
        r = 2*(random.random()-0.5)
        x.append(floating_point_to_fixed_point(r))

    d = conv(x,channel_fixed)

    shift_reg = [0]*len(weights)

    # LMS Algorithim
    for i in range(N):
        
        shift_reg = shift(shift_reg,x[i])
        
        lms_res = dot_prod(shift_reg, weights)
        error = d[i] - lms_res
        for w in range(len(weights)):
            weights[w] += floating_point_multiply(shift_reg[w],error)

    print(weights)
    float_weights = []
    for i in weights:
        float_weights.append(fixed_point_to_floating_point(i))
    print(float_weights)

if __name__ == "__main__":
    main()
