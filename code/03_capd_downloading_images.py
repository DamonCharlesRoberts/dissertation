# Title: CAPD Image Downloading

# Notes:
    #* Description: Script to open links to images and downloading them from CAPD site
    #* Updated: 2022-11-04
    #* Updated by: dcr
    #* Other notes:
        #** Should execute at end of 02_capd_img_scraping.ipynb


# Importing modules 
import duckdb
import pandas as pd
import urllib.request

# Loading database

db = duckdb.connect("data/dissertation_database")

links_df = db.execute("SELECT * FROM ch_1_capd_yard_signs").fetchdf()
links = links_df["Img_URL"].to_list()
names = links_df["Candidate_Name"].to_list()
years = links_df["year"].astype('string').to_list()
# Downloading the images

for link in links:
    urllib.request.urlretrieve(link, "data/chapter_1/capd_yard_signs/" + link.split('/')[6].split('.')[0] + ".png")