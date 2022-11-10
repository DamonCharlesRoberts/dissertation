# Title: Detecting colors

# Notes:
    #* Description: Script to detect the colors on the yard signs
    #* Updated: 2022-11-10
    #* Updated by: dcr

# Load modules
import pandas as pd
import numpy as np
import cv2
import duckdb 

# Load database

db = duckdb.connect('data/dissertation_database')

# Load table as dataframe

df = db.execute("SELECT * FROM ch_1_capd_yard_signs").fetchdf()

# Train
    #* Load csv file to help with color training
index=["color", "color_name", "hex", "R", "G", "B"] # create column names 

csv = pd.read_csv('data/color_training.csv', names = index, header = None) # load csv file

