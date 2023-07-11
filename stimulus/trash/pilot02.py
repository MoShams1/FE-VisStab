"""
***** Project Frame Effect and Saccade Main Sequence
***** Pilot Experiment 02

        Mo Shams <MShamsCBR@gmail.com>
        Initiated on: Feb 08, 2023

A sinusoidal grating background moves along a certain distance according to
the typical velocity profile of a saccade at a certain amplitude

"""

import random
import numpy as np
from lib import config_visual as cvis, genpath, gen_sacpath

# ----------------------------------------------------------------------------

# /// GENERAL SETTINGS ///

subID = 'test'
NTRIALS = 5
screen_num = 0  # 0: primary    1: secondary
frame_rate = 1440
full_screen = True
# ----------------------------------------------------------------------------

# /// CONFIGURE VISUAL OBJECTS ///

# /// background
bg_color = 'black'

# /// temporal gap
# sec x Hz = frames
gap_dur_arr = np.round(np.arange(1, 1.5, .1) * frame_rate)
gap_dur_arr = gap_dur_arr.astype(int)

# /// fixation dot
fixdot_size = .7
fixdot_pos = (0, 6)
fixdot_color = 'white'

# /// flashing probe
probe_pos = (0, 0)
probe_size = .5  # radius in deg
probe_color_list = ['DodgerBlue', 'Tomato']

# /// moving object
movobj_size = (15, 10)
# object's path
amp = 10
sf = 2/amp
ph0 = .5  # starting phase
movobj_firstpos = (-amp / 2, 5)
movobj_lastpos = (amp / 2, 5)  # two potential last positions
vmax = gen_sacpath.mainsequence(amp=amp)
dur = amp / vmax  # in sec
movobj_dur = int(round(dur * frame_rate))  # sec x Hz = frames

print(f"amp: {amp}")
print(f"vmax: {vmax}")
print(f"nframes: {movobj_dur}")
# ----------------------------------------------------------------------------

# /// CONFIGURE MONITOR ///

mon = cvis.configmon_imac()
win = cvis.configwin(mon=mon, screen=screen_num,
                     fullscr=full_screen,
                     color=bg_color)
cvis.test_framerate(win=win, nominal_fr=frame_rate)
# ----------------------------------------------------------------------------

# /// START TRIAL ///

for itrial in range(NTRIALS):

    # -------------------------------

    # /// set up trial variables

    # -------------------------------

    # /// run task
    krep = 1
    # motion period (1st leg)
    for iframe in range(0, movobj_dur):
        for irep in range(krep):
            phase = iframe / movobj_dur + ph0
            cvis.addfixdot(win=win, size=fixdot_size, pos=fixdot_pos,
                           color=fixdot_color)
            cvis.gen_grating(win, sf=sf, phase=phase, size=movobj_size)
            if iframe == 0:
                cvis.addprobe(win, radius=probe_size,
                              color=probe_color_list[0], pos=probe_pos)
            win.flip()
    for iframe in range(movobj_dur, 0, -1):
        for irep in range(krep):
            phase = iframe / movobj_dur + ph0
            cvis.addfixdot(win=win, size=fixdot_size, pos=fixdot_pos,
                           color=fixdot_color)
            cvis.gen_grating(win, sf=sf, phase=phase, size=movobj_size)
            if iframe == movobj_dur:
                cvis.addprobe(win, radius=probe_size,
                              color=probe_color_list[1], pos=probe_pos)
            win.flip()
    # -------------------------------

    # /// run gap period
    #
    # for iframe in range(20):
    #     win.flip()
    # -------------------------------

win.close()
