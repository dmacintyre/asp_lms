"""
lms_fixed_point.py

Description: 

Donald MacIntyre - djm4912
"""

import math
import random
import awgn

# Q15 fixed point format
NUM_BITS = 16
MAX_VAL = (2**(NUM_BITS-1))-1
MIN_VAL = -(2**NUM_BITS)
RESOLUTION = 1 / MAX_VAL

# Convolve arrays x,h to produce result y
def conv(x,h):
    n = len(x) + len(h) - 1
    y = [0]*n
    for i in range(len(x)):
        for j in range(len(h)):
            y[i+j] += fixed_point_multiply(x[i], h[j])
    return y

# Take the dot product of arrays x,h producing result y
def dot_prod(x,h):
    y = 0
    if len(x) != len(h):
        print('Length does not match')
    for i in range(len(x)):
        y += fixed_point_multiply(x[i], h[i])
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

# Convert from floating point to fixed point
# For this application fixed point is signed Q15
def floating_point_to_fixed_point(n):
    return round(n / RESOLUTION)

# Convert from fixed point to floating point
# For this application fixed point is signed Q15
def fixed_point_to_floating_point(n):
    return n * RESOLUTION

# Multiply to Q15 numbers and return a Q15 number
def fixed_point_multiply(x1, x2):
    #Q15 * Q15 produces a Q30 number
    temp = x1*x2
    #r is now a Q30 number. Convert back to a Q15 by shifting right by 15
    # i.e. divide by 32768
    temp //= 32768
    if temp > ((2**15)-1):
        print('OVERFLOW', temp)
    elif temp < (-(2**15)):
        print('UNDERFLOW', temp)
    return temp

def main() :

    # Length of input data
    N = 10000
    # Sample index
    n = []
    # Input samples
    x = []
    # Input samples (floating point) which we will add noise to
    x_floating_point = []
    # This is the "unknown" channel that we will attempt to identify
    channel = [0.05, 0.01, 0, 0.03]
    # This is the channel converted to fixed point
    channel_fixed = []
    
    for i in channel:
        channel_fixed.append(floating_point_to_fixed_point(i))
    # These are the weights that we will incrementally refine as we run the LMS algorithm
    weights = [0]*4

    # Loop over the desired length of the input data and create our input data    
    for i in range(N):
        n.append(i) # Populate the sample index array
        r = 2*(random.random()-0.5) # Generate input data which is uniformly distributed between -1 and 1
        x.append(floating_point_to_fixed_point(r))  # This is the input data without noise, we will add noise later 
        x_floating_point.append(r)


    # Produce the channel output by convolving the input samples with the "unknown" channel 
    d = conv(x,channel_fixed)
    
    # Add calibrated noise to the input signal
    signal_pwr = awgn.sigPwr(x_floating_point)  # Measure the signal power
    desired_snr_db = 10     # This is the desired signal to noise ratio in dB
    desired_snr = 10**(desired_snr_db/10)   # This is the linear snr
    noise_pwr = signal_pwr / desired_snr    # Based on desired SNR and signal power determine noise power level
    noise = awgn.awgn(0,noise_pwr,N)        # Create he awgn with calibrated to the correct SNR

    # Convert this input signal which now has the noise on it to fixed point
    for i in range(N):
        x[i] = floating_point_to_fixed_point(x_floating_point[i] + noise[i])

    
    # Write an output file that can be used by VHDL simulation containing LMS input data
    # File format is: expected_channel_input actual_channel_output
    of = open('input_data.txt', 'w')

    # This writes the input and expected data signals to be used by the VHDL simulation
    for i in range(N):
        of.write(str(x[i]))
        of.write(' ')
        of.write(str(d[i]))
        of.write('\n')
    
    of.close()
    
    # Used for LMS algorithm to hold the last number of input samples which need to be correlated with the weights
    shift_reg = [0]*len(weights)
    # This is the LMS convergence paramater
    # Every shift is equivalent to one divide by 2 but in the fixed point notation
    mu = 3

    # LMS Algorithim
    for i in range(N):

        # Shift in the next input sample
        shift_reg = shift(shift_reg,x[i])
        
        # Dot product between input samples and weights, generates the output of the LMS
        lms_res = dot_prod(shift_reg, weights)
        # Error signal, channel output - LMS result
        error = d[i] - lms_res
        # Update the weights 
        for w in range(len(weights)):
            weights[w] += fixed_point_multiply(shift_reg[w],error) >> mu
    # Output the final weights
    print(weights)
    float_weights = []
    # Also output the final calculated weights in Floating Point
    for i in weights:
        float_weights.append(fixed_point_to_floating_point(i))
    print(float_weights)

if __name__ == "__main__":
    main()
