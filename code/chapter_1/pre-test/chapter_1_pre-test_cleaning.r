# Title: Data cleaning of chapter 1 pre-test

# Notes:
    #* Description: Rscript to clean the Fall 2019 SPS data used for the chapter 1 pre-test
    #* Updated: 2022-08-24
    #* Updated by: dcr

# Setup
    #* modularly load functions
box::use(
    haven = haven[read_dta],
    dplyr = dplyr[mutate, case_when]
)
    #* create empty data list object
data = list()
    #* import cleaned dataset 
data[['original']] = read_dta('data/chapter_1/pre-test/sps1.dta')

# Cleaning
data[['clean']] = data[['original']] |>
    mutate(
    #* female - gender of respondent
        #** gender coded as: 1 = male, 2 = female
        #** Recode to: 0 = male, 1 = female
    female = case_when(gender == 1 ~ 0, 
                        gender == 2 ~ 1),
    #* age - age of respondent
        #** age coded as: age of respondent
        #** no change
    #* white - race of respondent
        #** race: 1 = asian, 2 = African-American/Black, 3 = Hispanic/Latino, 4 = Native American, 5 = White, 6 = Other
        #** white: 0 = non-white, 1 = white
    white = ifelse(race == 5, 1, 0),
    #* pid - partisan identification
        #** combination of multiple questions
        #** pid: -3 = strong democrat, -2 = democrat, -1 = leans democratic, 0 = independent, 1 = leans republican, 2 = republican, 3 = strong republican
    pid = case_when(pid == 2 & dem1 == 1 ~ -3,
                    pid == 2 & dem1 == 2 ~ -2,
                    pid == 3 & ind1 == 2 ~ -1,
                    pid == 3 & ind1 == 3 ~ 0,
                    pid == 3 & ind1 == 1 ~ 1,
                    pid == 1 & rep1 == 2 ~ 2,
                    pid == 1 & rep1 == 1 ~ 3),
    #* blue_treatment - did they recieve the blue yard sign treatment
        #** q265: 0 = did not display treatment, 1 = did display treatment
        #** new name
    blue_treatment = case_when(q265 == 1 ~ 1,
                                is.na(q265) ~ 0),
    #* red_treatment - did they receive the red yard sign treatment?
        #** q421: 0 = did not display treatment, 1 = did display treatment 
        #** new name
    red_treatment = case_when(q421 == 1 ~ 1,
                            is.na(q421) ~ 0),
    #* white_treatment - did they recieve the white yard sign treatment?
        #** q423: 0 = did not display treatment, 1 = did display treatment
        #** new name
    white_treatment = case_when(q423 == 1 ~ 1, 
                                is.na(q423) ~ 0),
    #* t_party - party of fictional candidate
        #** dr_pid: 1 = republican, 2 = democrat, 3 = neither
        #** t_party: -1 = democrat, 0 = neither, 1 = republican
    t_party = case_when(dr_pid == 2 ~ -1,
                        dr_pid == 3 ~ 0,
                        dr_pid == 1 ~ 1),
    #* t_vote - vote for fictional candidate
        #** dr_info_4: 2 = do not vote for the candidate, 1 = vote for candidate & dr_info_5: 2 = do not avoid candidate, 1 = avoid candidate
        #** t_vote: -1 = avoid candidate, 0 = avoid & vote/do not avoid & do not vote, 1 = vote
    t_vote = case_when(dr_info_4 == 2 & dr_info_5 == 1 ~ -1,
                        dr_info_4 == 1 & dr_info_5 == 1 ~ 0,
                        dr_info_4 == 2 & dr_info_5 == 2 ~ 0,
                        dr_info_4 == 1 & dr_info_5 == 2 ~ 1),
    #* t_neigh - interact with neighbor about fictional candidate
        #** dr_neigh_1: 2 = do not talk to neighbor about more info, 1 = talk to neighbor about more info, dr_neigh_4: 2 = tell neighbor about support, 1 = do not tell neighbor about support, dr_neigh_5: 2 = avoid neighbor, 1 = do not avoid neighbor
        #** t_neigh: 0 = avoid neighbor, 1 = discuss with neighbor
    t_neigh = case_when(dr_neigh_5 == 1 ~ 0,
                        dr_neigh_1 == 1 | dr_neigh_4 == 1 ~ 1)
    )