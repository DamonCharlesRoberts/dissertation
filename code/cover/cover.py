"""
    Title: Cover art
    Notes:
        - Description: Script to create cover art
        - Updated: 2022-12-08
        - Updated by: dcr
        - Output: ../../assets/cover.jpeg
"""

# Import packages
import matplotlib.pyplot as plt # for plots
from samila import GenerativeImage
from samila import Projection # for generative art
import time
import sys # to deal with paths

    #* User-defined
sys.path.append("code/cover/") # set path for imported modules
from cover_fun import f1, f2

# Create plot
colorArray = [
    "#E81B23",
    "#5d090c",
    "#ed454b",
    "#00aef3",
    "#00121a",
    "#66d4ff",
]

g = GenerativeImage(f1, f2)
g.generate(seed=1018273)
g.plot(cmap=colorArray, bgcolor="white", color = g.data2, projection=Projection.POLAR, size = (15,20))
g.save_image("assets/cover.jpeg", depth = 5)