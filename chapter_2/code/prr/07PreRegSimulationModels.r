# Title: Pre-registration simulation models

# Notes:
    #* Description:
        #** Models for pre-registration simulations
    #* Updated:
        #** 2023/04/05
        #** dcr
# Setup
    #* Set wd
setwd("chapter_2/code/prr")
    #* Set seed
set.seed(12062022)
    #* Load necessary functions
box::use(
    brms[make_stancode, make_standata, cumulative, prior, brmsformula],
    cmdstanr[...],
    rstan[stan_model, sampling]
)
    #* Load helpful helper functions
source("helper.R")
    #* Simulate data
# source("06_pre-reg_simulation.R") # UNCOMMENT IF DOING COMPLETE REPLICATION
load("../../data/prr/SimData.RData")
# Models from simulated data
    #* PartyGuess models
PartyFormula = brmsformula(
    PartyGuess ~ RedTreatment + BlueTreatment + age + RedTreatment:age + BlueTreatment:age + Attention + Knowledge
)

PartyCompiled <- stan_model(
    "vote_guess_simulated_model.stan",
    model_name = "PartyGuess"
)

Sample200Results <- Discrepancy(compiled = PartyCompiled, data = Sample200, formula = PartyFormula, family = cumulative(link = "logit"), model = "PartyGuess")
saveRDS(Sample200Results,"../../data/prr/sample200SimResults.RDS")
Sample400Results <- Discrepancy(compiled = PartyCompiled, data = Sample400, formula = PartyFormula, family = cumulative(link = "logit"), model = "PartyGuess")
saveRDS(Sample400Results,"../../data/prr/sample400SimResults.RDS")
Sample600Results <- Discrepancy(compiled = PartyCompiled, data = Sample600, formula = PartyFormula, family = cumulative(link = "logit"), model = "PartyGuess")
saveRDS(Sample600Results,"../../data/prr/sample600SimResults.RDS")
Sample800Results <- Discrepancy(compiled = PartyCompiled, data = Sample800, formula = PartyFormula, family = cumulative(link = "logit"), model = "PartyGuess")
saveRDS(Sample800Results,"../../data/prr/sample800SimResults.RDS")
