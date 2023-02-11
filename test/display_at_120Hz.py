"""
        Mo Shams <MShamsCBR@gmail.com>
        Initiated on: Feb 11, 2023

To test an blink an probe at 1 Hz via AOC monitor working at 120 Hz

"""
from psychopy import visual, monitors


# ----------------------------------------------------------------------------

# /// GENERAL SETTINGS ///

NTRIALS = 4
frame_rate = 120
full_screen = True

# ----------------------------------------------------------------------------

# /// CONFIGURE MONITOR ///

monitor = monitors.Monitor('prim_mon', width=60.45, distance=57)
monitor.setSizePix([1920, 1080])

if full_screen:
    win = visual.Window(monitor=monitor, screen=0, units='pix',
                        pos=[0, 0], fullscr=full_screen, color='black', size=(1920, 1080))
else:
    win = visual.Window(monitor=monitor, units='deg',
                        size=[800, 800], pos=[0, 0],
                        color='black')
# ----------------------------------------------------------------------------

# /// START TRIAL ///

for itrial in range(NTRIALS):

    # -------------------------------
    for frame in range(120):
        stim = visual.Rect(win=win, size=50, fillColor='white', pos=(0, 0))
        stim.draw()
        win.flip()

    # gap period
    for frame in range(120):
        stim = visual.Rect(win=win, size=50, fillColor='black', pos=(0, 0))
        stim.draw()
        win.flip()
    # -------------------------------

win.close()
