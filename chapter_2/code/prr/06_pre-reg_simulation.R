# Title: pre-registration study 1 simulation

# Notes:
    #* Description: 
        #** Simulations for Study 1 pre-registration
    #* Updated:
        #** 2023-03-17
        #** dcr

# Setup
    #* Set wd
setwd("chapter_2/code/prr")
    #* Set seed
set.seed(12062022)
    #* Load necessary functions
box::use(
    data.table[...],
    fabricatr[...],
    purrr[keep],
)
    #* Load helpful helper functions
source("helper.R")

# Create empty data list object
SimData <- list()
# Define the population data
dgp <- fabricate(
    N = 100000, # N in the population
    E = rnorm(N), # epsilon term
    age = round( # define age variable
        runif(N, 18, 85)
    ),
    gender = draw_binary( # define binary gender identity variable
        N,
        prob = 0.5
    ),
    white = draw_binary( # define white indicator variable
        N,
        prob = 0.6
    ),
    PartyId = draw_ordered( # define party identification of simulated respondents
        x = rnorm(
            N,
            mean = 0.4 * age - 0.6 * gender + 0.7 * white + E
        ),
        breaks = c(
            -Inf, 20.14, 23.01, Inf
        )
    ),
    Attention = draw_ordered( # define Attention variable
        x = rnorm(
            N,
            mean = 0.5 * age - 0.3 * gender + 0.1 * white + E
        ),
        breaks = c(
            -Inf, 16.5, 28.26, 36.54, 43.82, Inf
        )
    ),
    Knowledge = rnorm( # define Knowledge variable
        N,
        mean = 0.6 * age - 0.5 * gender + 0.2 * white + 0.8 * Attention + E
    )/100,
    RedTreatment = draw_binary( # Simulate treatment assignment
        N,
        prob = 1/3
    ),
    BlueTreatment = draw_binary( # Simulate treatment assignment
        N,
        prob = 1/3
    ),
    PartyGuess = draw_ordered( # Define PartyGuess outcome variable
        x = rnorm(
            N,
            mean = 2 * RedTreatment + -2 * BlueTreatment - 0.01 * age - 0.1 * RedTreatment * age + 0.1 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E),
        breaks = c(
            -Inf, -0.5, 0, Inf
        )
    ),
    PartyGuessTrialTwo = draw_ordered( # Define PartyGuess outcome variable
        x = rnorm(
            N,
            mean = 2 * RedTreatment + -2 * BlueTreatment - 0.01 * age - 0.1 * RedTreatment * age + 0.1 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E),
        breaks = c(
            -Inf, -0.5, 0, Inf
        )
    ),
    PartyGuessTrialThree = draw_ordered( # Define PartyGuessTrialTwo outcome variable
        x = rnorm(
            N,
            mean = 1 * RedTreatment + -1 * BlueTreatment - 0.01 * age - 0.05 * RedTreatment * age + 0.05 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E
        ),
        breaks = c(
            -Inf, -1, 1, Inf
        )
    ),
    Vote = draw_ordered( # Define Vote outcome variable
        x = rnorm(
            N,
            mean = 1 * RedTreatment + - 1 * BlueTreatment - 0.01 * age + 0.1 * Attention + 0.1 * Knowledge + E
        ),
        breaks = c(
            -Inf, 0, Inf
        )
    )
)

# Sample from population
NumOfObs <- c(200, 400, 600, 800) # Simulate random samples that vary on n
NumOfSamples <- 500 # I want 500 samples for each sample size
    #* For each sample size, replicate the sampling procedure 500 times
Sample <- replicate(NumOfSamples, GenerateSamples(data=dgp, n = NumOfObs))
    #* Create a list of the 500 samples for each sample size
Sample200 <- keep(
    Sample,
    function(x) nrow(x) == 200
)
Sample400 <- keep(
    Sample,
    function(x) nrow(x) == 400
)
Sample600 <- keep(
    Sample,
    function(x) nrow(x) == 600
)
Sample800 <- keep(
    Sample,
    function(x) nrow(x) == 800
)
save(Sample, Sample200, Sample400, Sample600, Sample800, file ="../../data/prr/simData.RData")
