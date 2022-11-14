# Title: CAPD detecting colors

# Notes: 
    #* Description: Script to detect the colors on the yard signs
    #* Updated: 2022-11-14
    #* Updated by: dcr

# Load modules
    #* From visual_env 
import duckdb # to access the database
import numpy as np # to wrangle arrays
import pandas as pd # to wrangle dataFrames
import re # to wrangle strings
from PIL import Image # to load images
import cv2 # to do color detection
import sys # to wrangle paths
import os # to wrangle local files
    #* User defined
sys.path.append("code/")
from fun import names, colorDetector

# Connect to database

db = duckdb.connect('data/dissertation_database')

# Define colors to detect
    #* White
        #** Not defined. Default for colorDetector()
    #* Red
republican_red = [232, 27, 35] # target color
red_lower = [93, 9, 12] # lower end of spectrum for red
red_higher = [237, 69, 75] # higher end of spectrum for red
    #* Blue
democrat_blue = [0, 174, 243] # target color
blue_lower = [0, 18, 26] # lower end of spectrum for blue
blue_higher = [102, 212, 255] # higher end of spectrum for blue

# Detect colors
    #* Create an empty dataframe to store them in
df = pd.DataFrame(columns = [
                    "Last_Name",
                    "Year",
                    "White_Percent",
                    "Blue_Percent",
                    "Red_Percent"
])

for filename in os.listdir("data/chapter_1/capd_yard_signs"):
    #* check to make sure the file is a png file
    if filename.endswith('.png'):
    #* join the directory to the file name
            f = os.path.join("data/chapter_1/capd_yard_signs", filename)
            print("read file")
    #* split the file name and store the information
            lastName, year, file = re.split(r'[_.]', filename)
            print("split file name")
    #* open the image's file
            pil = Image.open(f).convert('RGB')
            pilCv = np.array(pil)
            img = pilCv[:,:,::-1].copy()
            print("load file")
    #* calculate the percent of the image that is white
            whitePercent = colorDetector(img = img, color_lower = [255,255,255], color_upper = [255,255,255])
            print("calculated whitePercent")
    #* calculate the percent of the image that is blue
            bluePercent = colorDetector(img = img, color_upper = blue_higher, color_lower = blue_lower)
            print("calculated bluePercent")
    #* calculate the percent of the image that is red
            redPercent = colorDetector(img = img, color_upper = red_higher, color_lower = red_lower)
            print("calculated redPercent")
    #* store these things in a temporary dataframe
            tempDf = pd.DataFrame({
                                    "Last_Name":[lastName], 
                                    "Year":[year], 
                                    "White_Percent":[whitePercent],
                                    "Blue_Percent":[bluePercent],
                                    "Red_Percent":[redPercent]
                                    })
            print("stored in tempDf")
    #* append the temporary dataframe to the main dataframe
            df = df.append(tempDf, ignore_index = True)
            print("appended to df")

# Merge this information to the yard_signs table

yard_signs = db.execute("SELECT * FROM ch_1_capd_yard_signs").fetch_df() # grab the ch_1_capd_yard_signs table

yard_signs["Last_Name"] = names(yard_signs) # add a last names column

merged = pd.merge(yard_signs, df, how = 'left', left_on=["Last_Name", 'Year'], right_on = ["Last_Name", 'Year']) # merge the dataset with the colors and the candidate information together

# Store data as new table

db.execute("CREATE OR REPLACE TABLE ch_1_capd_color_detected AS SELECT * FROM merged")