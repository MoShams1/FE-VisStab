"""
This demo code shows how to format a series of PsychoPy ImageStims for 480 Hz sequencer (QUAD4x)

Images must be flipped to the projector as a single 1920 x 1080, 120Hz RGB image. 
The sequencer takes the image components from quadrants 1-4 and presents them as 
4 individual 960 x 540 frames, one after the other.
_______________________________
|             |                |           
|     Q1      |       Q2       | 
|             |                | 
|_____________|________________|   
|             |                |         
|     Q3      |       Q4       |          
|             |                |          
|_____________|________________|          

Quadrants are shown FULL SCREEN in the order Q1-Q2-Q3-Q4. 

To create stimuli, we create our targets as if they were full resolution,
full screen. The helper script 'reformatForQUAD4x' reassigns and rescales
the target positon to a specified quadrant.  If you are running a console monitor, 
you will see the four quadrants updating simultaneously at 120 Hz. 

Remember that each quadrant gets blown up to full screen on the PROPixx, so your resolution will be halved
vertically and horizontally.

Happy sequencing!

Aug 20, 2021   lef   created 
"""

from psychopy import visual
from pypixxlib import _libdpx as dp
import numpy as np


def reformatForQUAD4x(imageStim, win, quadrant):
    """ 
    Rescales the imagestim to 960 x 540, adds position offset based on quadrant arg
    """
    if not (win.size[0] == 1920) or not (win.size[1] == 1080):
        print('Warning! Window is not 1920 x 1080, window size must be 1920 x 1080 for sequencer to work correctly.')
        return

    # Rescale to half size to account for resolution drop
    for i in range(0, len(imageStim.size)):
        imageStim.size[i] = imageStim.size[i] / 2

    # Position offsets
    x = win.size[0] / 4
    y = win.size[1] / 4
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


##
# Test: start by opening the PROPixx connection and enabling the sequencer
dp.DPxOpen()
isReady = dp.DPxIsReady()
if isReady:
    dp.DPxSetPPxDlpSeqPgrm('RGB Quad 480Hz')
    dp.DPxWriteRegCache()
else:
    print('Warning! DPx call failed, check connection to hardware')

# Create a 1920 x 1080 window
win = visual.Window(
    screen=0,  # change here to 1 to display on second screen!
    monitor=None,
    size=[1920, 1080],
    fullscr=True,
    pos=[0, 0],
    color='black',
    units="pix",
    colorSpace='rgb255',
    blendMode='avg'
)

# Draw stimuli, which is an imageTexture with an oscillating grey mask overtop
# Quadrant assignment determines frame order in 4-frame sequence

# We'll use a public domain image
imageTexture = 'Renoir_img.png'
maskTexture = 'Mask_img.png'

# Mask characteristics
framerate = 480
duration = 1  # seconds
t = np.tile(np.linspace(0, 1, (framerate)), duration)

f = 8  # frames/cycle, for a 60 Hz oscillating mask
a = 1
maskOpacity = (a * np.sin(2 * np.pi * f * t) + 0.5)

# We'll also make a repeating list of quadrant assignments to kee everything ordered
quadrants = np.tile((1, 2, 3, 4), int(len(maskOpacity) / 4))

# start drawing as if full screen
for i in range(0, len(maskOpacity)):

    # draw stimuli
    stimulus = visual.ImageStim(win=win,
                                image=imageTexture,
                                units='pix',
                                pos=[0, 0],
                                size=[400, 400],
                                mask='gauss')

    # resize and reposition stimuli for 480Hz
    stimulus = reformatForQUAD4x(stimulus, win, quadrants[i])
    stimulus.draw()

    # mask uses the updated size and position, no need to rescale
    mask = visual.ImageStim(win=win,
                            image=maskTexture,
                            units='pix',
                            pos=stimulus.pos,
                            size=stimulus.size,
                            opacity=maskOpacity[i])
    mask.draw()

    # flip window once fourth quadrant is drawn
    if quadrants[i] == 4:
        win.flip()

win.close()
dp.DPxSetPPxDlpSeqPgrm('RGB')
dp.DPxWriteRegCache()
dp.DPxClose()
