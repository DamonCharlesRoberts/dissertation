# Title: Merging MIT Election Lab Data to Yard Signs dataset

# Notes:
    #* Description: Script to merge MIT Election Lab US House 1976-2020 Election Returns dataset to Yard signs table
    #* Updated: 2022-11-08
    #* Updated by: dcr
    #* Other notes:
        #** To access dataset go to:
        #** https://dataverse.harvard.edu/dataset.xhtml?persistentId=doi:10.7910/DVN/IG0UN2

# Load modules
import duckdb
import pandas as pd
import numpy as np

# Check out the election lab data
election_lab = pd.read_csv("data/chapter_1/1976-2020-house.csv")
    #* Recoding
election_lab = election_lab[["year", "state", "district", "candidate", "party", "candidatevotes", "totalvotes"]] # select the year, state, district, candidate, party, candidatevotes, and totalvotes columns
election_lab["state"] = election_lab["state"].str.lower() # convert the text in the state column to lowwer case
election_lab["candidate"] = election_lab["candidate"].str.lower().astype('str') # convert candidate column to lower case and make sure to turn it into string object
election_lab["Last_Name"] = election_lab["candidate"].str.split(' ').str.get(-1) # split the string to grab the last name and grab the last part of that split
#election_lab["Party"] = np.select([(election_lab.party == 'DEMOCRAT'), (election_lab.party == 'REPUBLICAN')], ['D', 'R']) # if the party column equals Democrat, re-store it as D. if the party column equals republican, re-store it as R.
election_lab["year"] = pd.to_numeric(election_lab["year"]).astype(float) # take the year column and convert it to a numeric column stored as a float
election_lab['State_District'] = election_lab[["state", "district"]].apply(lambda x: '-'.join(x.astype(str)), axis = 1)
election_lab.drop(election_lab.index[election_lab['totalvotes'] <= 0], inplace = True)

print("clean election_lab")
    #* Create Dem vote share column
mapping_vals = (
    election_lab[election_lab['party'].eq('DEMOCRAT')]
    .set_index(['year', 'State_District'])
    .apply(lambda x: x['candidatevotes']/x['totalvotes'],axis=1)
    .groupby(level=[0,1]).sum()
)

election_lab['Dem_vote_share'] = election_lab.set_index(['year', 'State_District']).index.map(mapping_vals).fillna(0)

    #* Create 5-year simple moving average column
filtered = election_lab.drop_duplicates(subset=['State_District', 'year'])

filtered["sma"] = filtered.groupby("State_District")['Dem_vote_share'].rolling(5).mean().reset_index(0, drop = True)

filtered.drop(filtered.index[filtered['year'] < 2015], inplace = True)

    #* Merge 5-year simple moving average column
election_lab_merge = pd.merge(election_lab, filtered, how = 'left', left_on=["State_District", "year"], right_on = ["State_District", "year"])

#past = dict(tuple(election_lab.groupby("State_District")))


#mapping_past = (
#    election_lab.set_index(['year', 'State_District'])
#    .groupby(level=[0,1]).rolling(5).mean()
#)
#
#election_lab['Dem_past_vote_share'] = election_lab.set_index(['year', 'State_District']).index.map(mapping_past)
print("create dem vote share column in election lab")
# Load database

db = duckdb.connect("data/dissertation_database") # connect to my database

yard_sign = db.execute("SELECT * FROM ch_1_capd_yard_signs").fetch_df() # grab the ch_1_capd_yard_signs table from the database and store it as a pandas dataframe 

print('load yard_sign')

    #* Recoding
yard_sign["Candidate_Name"] = yard_sign ["Candidate_Name"].str.lower().str.replace('.', '').astype(str) # take the candidate_name column, convert it to lower case, and remove all of the periods in it, also be sure to store it as a string object
yard_sign["Last_Name"] = yard_sign["Candidate_Name"].str.split(' ').str.get(-2) # take the candidate_name column and separate it up. Grab the second to last result and store that as the candidate's last name
yard_sign["state"] = yard_sign["State"].str.lower() # convert the state column to lower case
yard_sign["year"] = pd.to_numeric(yard_sign["year"]).astype(float) # take the year column and be sure to store it as a numeric column and as a float

print('clean yard_sign')

# Join the databases
merged = pd.merge(yard_sign, election_lab_merge, how = 'left', left_on=["Last_Name", "year"], right_on = ["Last_Name_x", "year"]) # merge the two datasets based on the last_name of the candidate and the year of the election

print('merged dataset')

# Add merged table to database

db.execute("CREATE OR REPLACE TABLE capd_mit_merged AS SELECT * FROM merged") # store merged df in database as capd_mit_merged table

print('SCRIPT COMPLETE')