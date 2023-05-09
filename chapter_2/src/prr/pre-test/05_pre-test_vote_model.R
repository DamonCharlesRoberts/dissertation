# Title: Pre-test vote models

# Notes:
    #* Description: 
        #** Script to execute and return ame plot for vote pre-test models
    #* Updated:
        #** 2023-03-16
        #** dcr
# Set up
    #* Set seed
set.seed(12102022)
# Source cleaning script
source("./pre-test/01_pre-test_cleaning.R")
    #* Load functions
box::use(
    brms[
        bf
        ,cumulative
        ,brm
    ]
)

# Models
    #* On engagement willingness
        #** Model specification
VotePreTestFormula <- bf(
  Vote ~ RedTreatment + BlueTreatment + PartyId + RedTreatment * PartyId + BlueTreatment * PartyId,
  family = cumulative(link = "logit")
)

VotePreTestModel <- brm(
    formula = VotePreTestFormula,
    data = data[["clean"]],
    chains = 1,
    silent = 0
)

# Store model object
save(
    VotePreTestModel
    ,file="../../data/models/prr/pre-test/pre-test_vote_model.RDS"
)