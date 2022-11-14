# Title: CAPD Text scraping 

# Notes:
    #* Description: Jupyter Notebook to scrape CAPD site for yard signs in 2018-2022 national elections
    #* Updated: 2022-11-04
    #* Updated by: dcr 

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

# Scraping of CAPD site

## Driver and scraping
options = Options() # set webdriver options
options.add_argument("start-maximized") # set an option for the webdriver to automatically open chrome browser that I can interact with the page

driver = webdriver.Chrome(ChromeDriverManager().install(), options=options) # setup chrome webdriver

wait = WebDriverWait(driver, 100000) # specify wait time for the page before stopping it from collecting links in xpath

url = "https://www.politicsanddesign.com/"

driver.get(url) # Make sure to turn off year filter on page that pops up and scroll all the way down

wait.until(EC.presence_of_all_elements_located((By.XPATH, "//div[@class='candidate-card-text']/ul"))) # tell driver to search along this path, but to not stop the search until it everything has been collected
time.sleep(10) # add an some extra time incase needed 
txt_url = driver.find_elements(By.XPATH, "//div[@class='candidate-card-text']/ul") # go ahead and collect all the elements
txt_url2 = [] # make empty list object to store urls in
for i in txt_url:
    txt_url2.append(i.text) # grab the text for each of the sessions
driver.close() # close the driver

## Data wrangling
txt_url4 = [i for i in txt_url2 if i] # take the elements of txt_url2 and place them in a list

yard_signs = pd.DataFrame(txt_url4) # turn this list into a single column dataframe

# Split the single column into 6 to document each piece of information about the candidate
yard_signs[['Candidate_Name', 'Party']] = yard_signs[0].str.split('(', 1, expand = True)
yard_signs[['Party', 'State']] = yard_signs['Party'].str.split('\n', 1, expand = True)
yard_signs[['State', 'District']] = yard_signs['State'].str.split('-', 1, expand = True)
yard_signs[['District', 'Office', 'Year']] = yard_signs['District'].str.split(',', 2, expand = True)
yard_signs['Party'] = yard_signs.Party.str.strip(')')

# Drop that first column with the original list information 
yard_signs.drop(yard_signs.columns[[0]], axis=1, inplace = True)


## Store Data

db = duckdb.connect('C:/Users/damon/Dropbox/current_projects/dissertation/data/dissertation_database') # connect to the database

yard_signs = db.execute("CREATE OR REPLACE TABLE ch_1_capd_yard_signs AS SELECT * FROM yard_signs").fetchall() # create the table

#database.commit() # commit this to the database

#database.execute("SELECT * FROM ch_1_capd_yard_signs") # go to the ch_1_capd_yard_signs table in the database
#yard_signs = data.DataFrame(database.fetch_all(), columns = ['Candidate_Name', 'District', 'Office', 'Year', 'Party', 'State']) # take that duckdb table and turn it into a pandas dataframe

# Notes:
#* Now run 02_capd_img_scraping.ipynb