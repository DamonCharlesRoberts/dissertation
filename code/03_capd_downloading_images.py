# Title: CAPD Image Downloading

# Notes:
    #* Description: Script to open links to images and downloading them from CAPD site
    #* Updated: 2022-11-04
    #* Updated by: dcr
    #* Other notes:
        #** Should execute at end of 02_capd_img_scraping.py


# Importing modules 
    #* From environment
import duckdb # for database management
import pandas as pd # for dataFrame management
import urllib.request # to access site
import sys # to deal with paths

    #* User-defined
sys.path.append("code/") # set path for imported modules
from fun import names

# Loading database

db = duckdb.connect("data/dissertation_database")

links_df = db.execute("SELECT * FROM ch_1_capd_yard_signs").fetchdf()
links_df["Last_Name"] = names(links_df)
links_df["Year"] = links_df["Year"].astype(str)
# Downloading the images

for index, row in links_df.iterrows():
    urllib.request.urlretrieve(row["Img_URL"], "data/chapter_1/capd_yard_signs/" + row["Last_Name"] + "_" + row["Year"] + ".png")