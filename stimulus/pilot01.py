"""
***** Project Frame Effect and Saccade Main Sequence
***** Pilot Experiment 01

        Mo Shams <MShamsCBR@gmail.com>
        Initiated on: Feb 06, 2023

A square-shaped object moves along a certain distance according to the typical
velocity profile of a saccade.

"""

import random
import numpy as np
from lib import config_visual as cvis, genpath, gen_sacpath

# ----------------------------------------------------------------------------

# /// GENERAL SETTINGS ///

subID = 'test'
NTRIALS = 5
screen_num = 0  # 0: primary    1: secondary
frame_rate = 1200
full_screen = False
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
fixdot_pos = (0, 0)
fixdot_color = 'white'

# /// moving object
movobj_size = 5
movobj_color = 'white'
movobj_lw = .1

# object's path
amp = 2
movobj_firstpos = (-amp/2, 5)
movobj_lastpos = (amp/2, 5)  # two potential last positions
vmax = gen_sacpath.mainsequence(amp=amp)
dur = amp / vmax  # in sec
movobj_dur = int(round(dur * frame_rate))  # sec x Hz = frames
movobj_pathx, movobj_pathy = genpath.linear(pos1=movobj_firstpos,
                                            pos2=movobj_lastpos,
                                            dur=movobj_dur)
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

    # decide on gap durations
    firstgap_dur = np.random.choice(gap_dur_arr)
    lastgap_dur = np.random.choice(gap_dur_arr)

    # decide on the motion direction and adjust motion path and flash position
    movobj_dir = random.choice([1, 1])
    if movobj_dir == -1:
        movobj_pathx_tr = -movobj_pathx
    else:
        movobj_pathx_tr = movobj_pathx
    movobj_pathy_tr = movobj_pathy
    # -------------------------------

    # /// run task

    # gap period
    # for frame in range(firstgap_dur):
    #     win.flip()

    # motion period (1st leg)
    for iframe in range(movobj_dur):
        cvis.addfixdot(win=win, size=fixdot_size, pos=fixdot_pos,
                       color=fixdot_color)
        cvis.addsquare(win=win, width=movobj_size, color=movobj_color,
                       fillcolor=bg_color,
                       pos=(movobj_pathx_tr[iframe],
                            movobj_pathy_tr[iframe]),
                       line_width=movobj_lw)
        iframe_last = iframe
        win.flip()
    for i in range(20):
        cvis.addfixdot(win=win, size=fixdot_size, pos=fixdot_pos,
                       color=fixdot_color)
        cvis.addsquare(win=win, width=movobj_size, color=movobj_color,
                       fillcolor=bg_color,
                       pos=(movobj_pathx_tr[iframe_last],
                            movobj_pathy_tr[iframe_last]),
                       line_width=movobj_lw)
        win.flip()

    # motion period (2nd leg)
    for iframe in range(movobj_dur):
        cvis.addfixdot(win=win, size=fixdot_size, pos=fixdot_pos,
                       color=fixdot_color)
        cvis.addsquare(win=win, width=movobj_size, color=movobj_color,
                       fillcolor=bg_color,
                       pos=(-movobj_pathx_tr[iframe],
                            movobj_pathy_tr[iframe]),
                       line_width=movobj_lw)
        iframe_last = iframe
        win.flip()
    for i in range(20):
        cvis.addfixdot(win=win, size=fixdot_size, pos=fixdot_pos,
                       color=fixdot_color)
        cvis.addsquare(win=win, width=movobj_size, color=movobj_color,
                       fillcolor=bg_color,
                       pos=(-movobj_pathx_tr[iframe_last],
                            movobj_pathy_tr[iframe_last]),
                       line_width=movobj_lw)

    # gap period
    # for frame in range(lastgap_dur):
    #     win.flip()
    # -------------------------------

win.close()
