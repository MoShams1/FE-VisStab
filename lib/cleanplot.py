import numpy as np
import matplotlib as plt
from matplotlib.patches import Polygon


def trim_spines(ax):
    # removes the upper and the right borders of the axis
    ax.spines[['top', 'right']].set_visible(False)
    ax.spines[['left', 'bottom']].set_position(('outward', 5))


def prep4ai():
    plt.rcParams['pdf.fonttype'] = 42  # AI can detect text now
    plt.rcParams['font.sans-serif'] = "Arial"
    plt.rcParams['font.size'] = 8
