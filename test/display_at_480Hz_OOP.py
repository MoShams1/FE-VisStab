"""
        Mohammad Shams <MShamsCBR@gmail.com>
        Initiated on: Feb 19, 2023

To test a blink of a probe at 0.5 Hz via PROPixx working at 480 Hz

"""
from pypixxlib.propixx import PROPixx
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

NTRIALS = 1
refresh_rate = 480
full_screen = True

# ----------------------------------------------------------------------------
my_device = PROPixx()
my_device.setDlpSequencerProgram('QUAD4X')
my_device.updateRegisterCache()
# ----------------------------------------------------------------------------

# /// CONFIGURE MONITOR ///

monitor = monitors.Monitor('prim_mon', width=60.45, distance=57)
monitor.setSizePix([1920, 1080])

if full_screen:
    win = visual.Window(monitor=monitor, screen=0, units='pix',
                        pos=[0, 0], fullscr=full_screen, color='black',
                        size=(1920, 1080))
else:
    win = visual.Window(monitor=monitor, units='deg',
                        size=[800, 800], pos=[0, 0],
                        color='black')

actual_fr = win.getActualFrameRate(nIdentical=10, nMaxFrames=100,
                                   nWarmUpFrames=10, threshold=1)
# ----------------------------------------------------------------------------

# /// START TRIAL ///

for itrial in range(NTRIALS):

    # -------------------------------
    for frame in range(refresh_rate):
        iquad = (frame + 1) % 4
        if iquad == 0:
            iquad = 4
        stim = visual.Rect(win=win, size=50, fillColor='white', pos=(0, 0))
        stim = reformatForQUAD4x(stim, win, iquad)
        stim.draw()
        if iquad == 4:
            win.flip()

    for frame in range(refresh_rate):
        iquad = (frame + 1) % 4
        if iquad == 0:
            iquad = 4
        stim = visual.Rect(win=win, size=50, fillColor='black', pos=(0, 0))
        stim = reformatForQUAD4x(stim, win, iquad)
        stim.draw()
        if iquad == 4:
            win.flip()
    # -------------------------------

print(f"Measured Frame Rate: {actual_fr} Hz")

win.close()

my_device.setDlpSequencerProgram('QUAD4X')
my_device.writeRegisterCache()
my_device.close()
