import numpy as np


def linear(pos1, pos2, dur):
    pathx = np.linspace(pos1[0], pos2[0], dur)
    pathy = np.linspace(pos1[1], pos2[1], dur)
    return pathx, pathy


def two_ways(pathlen, dur, cnd):
    halfpath = int((pathlen - 1) / 2)
    halfdur = int(dur / 2)
    pathx_pre = np.linspace(-halfpath, 0, halfdur)
    pathx_pst = np.linspace(0, halfpath, halfdur)
    pathx_pst = np.delete(pathx_pst, [0])
    if cnd[1] == -1:
        pathx_pst = -pathx_pst
    pathx = np.concatenate((pathx_pre, pathx_pst))
    if cnd[0] == -1:
        pathx = -pathx
    pathy = np.repeat([5], pathx.size)
    return pathx, pathy
