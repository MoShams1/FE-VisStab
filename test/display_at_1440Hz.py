"""
        Mo Shams <MShamsCBR@gmail.com>
        Initiated on: Feb 11, 2023

To test a blink of a probe at 0.5 Hz via PROPixx working at 480 Hz

"""
import numpy as np
from pypixxlib import _libdpx as dp
from psychopy import visual, monitors


def reformatForQUAD4x(imageStim, window, quadrant):
    """
    Rescales the imagestim to 960 x 540, adds position offset based on
    quadrant arg
    """
    if not (window.size[0] == 1920) or not (window.size[1] == 1080):
        print('Warning! Window is not 1920 x 1080.')
        return

    # Rescale to half size to account for resolution drop
    for i in range(0, len(imageStim.size)):
        imageStim.size[i] = imageStim.size[i] / 2

    # Position offsets
    x = window.size[0] / 4
    y = window.size[1] / 4
    offsets = [[-x, y],
               [x, y],
               [-x, -y],
               [x, -y]]

    # apply position offsets
    newPos = [0, 0]
    newPos[0] = imageStim.pos[0] + offsets[quadrant - 1][0]
    newPos[1] = imageStim.pos[1] + offsets[quadrant - 1][1]
    imageStim.setPos(newPos)

    return imageStim


# ----------------------------------------------------------------------------

# /// GENERAL SETTINGS ///

NTRIALS = 10
refresh_rate = 360
full_screen = True

# ----------------------------------------------------------------------------
# Test: start by opening the PROPixx connection and enabling the sequencer
dp.DPxOpen()
isReady = dp.DPxIsReady()
if isReady:
    dp.DPxSetPPxDlpSeqPgrm('GREY Quad 1440Hz')
    dp.DPxWriteRegCache()
else:
    print('Warning! DPx call failed, check connection to hardware')
# ----------------------------------------------------------------------------

# /// CONFIGURE MONITOR ///

monitor = monitors.Monitor('prim_mon', width=60.45, distance=57)
monitor.setSizePix([1920, 1080])

if full_screen:
    win = visual.Window(monitor=monitor, screen=0, units='pix',
                        pos=[0, 0], fullscr=full_screen, color='black',
                        size=(1920, 1080), blendMode='add')
else:
    win = visual.Window(monitor=monitor, units='deg',
                        size=[800, 800], pos=[0, 0],
                        color='black', blendMode='add')

actual_fr = win.getActualFrameRate(nIdentical=10, nMaxFrames=100,
                                   nWarmUpFrames=10, threshold=1)
# ----------------------------------------------------------------------------

# /// CONFIGURE CONDITIONS ///

colors = [[1, 0, 0], [0, 1, 0], [0, 0, 1]]
col_quads = np.tile([0, 1, 2, 3], 3)
col_colors = np.repeat([0, 1, 2], 4)
cnd_mat = np.vstack((col_quads, col_colors)).transpose()
nseqs = 12
# ----------------------------------------------------------------------------

# /// START TRIAL ///

for itrial in range(NTRIALS):

    # -------------------------------
    for frame in range(refresh_rate):

        iseq = (frame + 1) % nseqs
        if iseq == 0:
            iseq = nseqs

        stim = visual.Rect(win=win, size=50,
                           fillColor=colors[cnd_mat[iseq - 1, 1]], pos=(0, 0))
        stim = reformatForQUAD4x(stim, win, cnd_mat[iseq - 1, 0])
        stim.draw()

        if iseq == nseqs:
            win.flip()
    # -------------------------------
    for frame in range(refresh_rate):

        iseq = (frame + 1) % nseqs
        if iseq == 0:
            iseq = nseqs

        stim = visual.Rect(win=win, size=50,
                           fillColor=colors[cnd_mat[iseq - 1, 1]], pos=(0, 50))
        stim = reformatForQUAD4x(stim, win, cnd_mat[iseq - 1, 0])
        stim.draw()

        if iseq == nseqs:
            win.flip()
    # -------------------------------

print(f"Measured Frame Rate: {actual_fr} Hz")
win.close()
# dp.DPxSetPPxDlpSeqPgrm('RGB')
dp.DPxWriteRegCache()
dp.DPxClose()
