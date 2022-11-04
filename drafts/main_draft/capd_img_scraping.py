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
wait.until(EC.presence_of_all_elements_located((By.XPATH, "//div[@class='responsive-image-wrapper']/img")))
time.sleep(2)
img_url = driver.find_elements(By.XPATH, "//div[@class='responsive-image-wrapper']/img")

img_url2 = []
for element in img_url:
    new_srcset = 'https:' + element.get_attribute("srcset").split(' 400w', 1)[0]
    img_url2.append(new_srcset)

print(len(img_url2))