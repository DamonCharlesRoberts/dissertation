import time # library to help with sleep and wait times
from selenium import webdriver # to setup the driver
from selenium.webdriver.chrome.options import Options # to specify options for my chrome webdriver
from webdriver_manager.chrome import ChromeDriverManager # use the driver manager so that I don't have to download it and keep track of versions myself
from selenium.webdriver.support.ui import WebDriverWait # use this so that I can wait on my driver to load the page completely before searching
from selenium.webdriver.common.by import By # using the By function to help with the xpath searching
from selenium.webdriver.support import expected_conditions as EC # load the expected_conditions function to make sure all elements matching the xpath happen before the driver stops waiting on the loading
import pandas as pd # need the pandas package for dataFrames
import duckdb # need the duckdb package for managing the database 

options = Options()
options.add_argument("start-maximized")

driver = webdriver.Chrome(ChromeDriverManager().install(), options=options)

wait = WebDriverWait(driver, 10000)

url = "https://www.politicsanddesign.com/"

driver.get(url)
wait.until(EC.presence_of_all_elements_located((By.XPATH, "//div[@class='candidate-card-text']/ul[@class='candidate-card-name']/li")))
time.sleep(10)
txt_url = driver.find_elements(By.XPATH, "//div[@class='candidate-card-text']/ul[@class='candidate-card-name']/li")

txt_url2 = []
for i in txt_url:
    txt_url2.append(i.text)

print(len(txt_url2))

