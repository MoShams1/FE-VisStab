import numpy as np


def mainsequence(amp):
    slope = 2.7
    intercept = 23
    c = 1.64
    vmax = (c * amp) / ((slope * amp) + intercept) * 1000
    return vmax
