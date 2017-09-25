import numpy as np
np.seterr(all='raise')

def tail(arr, depth):
    return arr[-depth:]

def normalize(a, b, x):
    return (b - a) * (x - np.min(x)) / (np.max(x) - np.min(x)) + a
