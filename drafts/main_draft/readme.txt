# Create environment
conda create --prefix=C:/Users/damon/Dropbox/current_projects/dissertation/drafts/main_draft/visual_env jupyter

# Activate environment
conda activate C:/Users/damon/Dropbox/current_projects/dissertation/assets/visual_env

# Manually installed packages
    #* python
    - bs4 # good package for webscraping 
    - requests # to make requests to sites for scraping
    - requests-html # kind of like bs4 and requests but allows to deal with sites rendering JS
    - selenium # to help with the scraping of javascript loaded pages
    - pyautogui # to help with selecting images to scrape
    #* r