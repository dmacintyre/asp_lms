"""
awgn.py

Description: Module to generate AWGN of a specified power level.

Donald MacIntyre - djm4912
"""

import random

# Given an input signal x, determine the signal power
# power = 1/N*summation(x[n]^2)
def sigPwr(x):
    n = len(x)
    x_pwr = 0
    for i in range(n):
        x_pwr += x[i]**2
    return x_pwr / n

# Generate AWGN with:
# mean specified by mean
# variance specified by sqrt(power)
# n number of samples of awgn
def awgn(mean, pwr, n):
    # Determine variance of desired distribution based on noise power
    var = pwr**0.5
    res = []
    for i in range(n):
        res.append(random.gauss(mean, var))
    return res 

def main() :
    pass

if __name__ == "__main__":
    main()
