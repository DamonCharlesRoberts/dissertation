# Title: Pre-test party models

# Notes:
    #* Description: 
        #** Script to execute and return ame plot for party pre-test models
    #* Updated:
        #** 2023-03-16
        #** dcr
# Set up
    #* Set seed
set.seed(12062022)
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
    #* On partisan perceptions
        #** Model specification
PartyFormula <- bf(
  Party ~ RedTreatment + BlueTreatment,
  family = cumulative(link = "logit")
)

PartyModel <- brm(
    formula = PartyFormula,
    data = data[["clean"]],
    chains = 1,
    silent = 0
)

# Store model object
save(
    PartyModel
    ,file="../../data/models/prr/pre-test/pre-test_party_model.RDS"
)
