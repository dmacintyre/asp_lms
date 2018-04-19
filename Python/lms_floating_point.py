"""
lms_floating_point.py

Description: 

Donald MacIntyre - djm4912
"""

import math
import random

# Convolve arrays x,h to produce result y
def conv(x,h):
    n = len(x) + len(h) - 1
    y = [0]*n
    for i in range(len(x)):
        for j in range(len(h)):
            y[i+j] += x[i]*h[j]
    return y

# Take the dot product of arrays x,h producing result y
def dot_prod(x,h):
    y = 0
    if len(x) != len(h):
        print('Length does not match')
    for i in range(len(x)):
        y += x[i]*h[i]
    return y

# Take an array x and shift it down
# Returned result becomes res = x(n-1 downto 1) & val
def shift(x,val):
    res = [0]*len(x)
    n = len(x)-1
    while (n > 0):
        res[n] = x[n-1]
        n -= 1
    res[0] = val
    return res

def main() :

    # Length of input data
    N = 100000
    # Sample index
    n = []
    # Input samples
    x = []    
    # This is the "unknown" channel that we will attempt to identify
    channel = [10, 3.5, 1]
    # These are the weights that we will incrementally refine as we run the LMS algorithm
    weights = [0]*3
    # This is the LMS convergence parameter
    param = 0.25
    
    # Loop over the desired length of the input data and create our input data
    for i in range(N):
        n.append(i)     # Populate the sample index array
        r = 2*(random.random()-0.5)     # Generate input data which is uniformly distributed between -1 and 1
        x.append(r) # Push input data into input array

    # Convolve the input with the channel creating the channel output
    d = conv(x,channel)
    
    # Used for LMS algorithm to hold the last number of input samples which need to be correlated with the weights
    shift_reg = [0]*len(weights)

    # LMS Algorithm
    for i in range(N):
        
        # Shift in the next input sample
        shift_reg = shift(shift_reg,x[i])
        
        # Dot product between input samples and weights, generates the output of the LMS
        lms_res = dot_prod(shift_reg, weights)
        # Error signal, channel output - LMS result
        error = d[i] - lms_res
        # Update the weights 
        for w in range(len(weights)):
            weights[w] += 2*param*shift_reg[w]*error
    # Output the final weights
    print(weights)
    
if __name__ == "__main__":
    main()
