# Title: CAPD Image Scraping

# Notes:
    #* Description: Jupyter Notebook to scrape CAPD site for yard signs in 2018-2022 national elections
    #* Updated: 2022-11-04
    #* Updated by: dcr 
    #* Other notes:
        #** First run 01_capd_text_scraping.ipynb. This should be executed interactively.

# Load Modules
import time # library to help with sleep and wait times
from selenium import webdriver # to setup the driver
from selenium.webdriver.chrome.options import Options # to specify options for my chrome webdriver
from webdriver_manager.chrome import ChromeDriverManager # use the driver manager so that I don't have to download it and keep track of versions myself
from selenium.webdriver.support.ui import WebDriverWait # use this so that I can wait on my driver to load the page completely before searching
from selenium.webdriver.common.by import By # using the By function to help with the xpath searching
from selenium.webdriver.support import expected_conditions as EC # load the expected_conditions function to make sure all elements matching the xpath happen before the driver stops waiting on the loading
import pandas as pd # need the pandas package for dataFrames
import duckdb # need to store data into database
import os # needed to execute 03_capd_downloading_images.py script

# Scraping of CAPD Site

## Driver and Scraping

options = Options() # set options for driver
options.add_argument("start-maximized") # specify the option to open chrome browser when sent to driver

driver = webdriver.Chrome(ChromeDriverManager().install(), options=options) # create ChromeDriver
wait = WebDriverWait(driver, 10000) # set wait time for driver when searching XPATH

url = "https://www.politicsanddesign.com/" # site of url to go to

driver.get(url) # go to url

wait.until(EC.presence_of_all_elements_located((By.XPATH, "//picture[@class='responsive-image-wrapper']/img"))) # search xpath on url. Need to first remove 2020 filter and scroll all the way to the bottom
time.sleep(10) # set sleep timer just in case driver needs more time
img_url = driver.find_elements(By.XPATH, "//picture[@class='responsive-image-wrapper']/img") # search xpath on url

img_url2 = [] # create empty list
for element in img_url:
    new_srcset = 'https:' + element.get_attribute("srcset").split(' 200w', 1)[0] # for elements in the img_url drivers, take the srcset img attribute and paste it into a full link. Also remove everything after the 400w caracter and retain the first part of that split
    img_url2.append(new_srcset) #append the links to the img_url2 list object

## Data Wrangling
### Load database
db = duckdb.connect("data/dissertation_database")
yard_signs = db.execute("SELECT * FROM ch_1_capd_yard_signs").fetchdf()

yard_signs['Img_URL'] = img_url2 # add img_url2 list object and add it to the yard_signs dataFrame

### Drop non-House races
yard_signs = yard_signs.dropna(thresh = 5)
## Store Data


db.execute("CREATE OR REPLACE TABLE ch_1_capd_yard_signs AS SELECT * FROM yard_signs") # add the new version of the table to the database

# Execute downloading image script

os.system("03_capd_downloading_images.py")