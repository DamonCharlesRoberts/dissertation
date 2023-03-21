# Title: pre-registration study 1 simulation

# Notes:
    #* Description: 
        #** Simulations for Study 1 pre-registration
    #* Updated:
        #** 2023-03-17
        #** dcr

# Setup
    #* Set seed
set.seed(12062022)
    #* Load necessary functons
box::use(
    data.table[...],
    DeclareDesign[...],
    fabricatr[...]
)

# Define fxn for data generation

DataGenerate <- function(N) {
    #' Generate data for pre-registration simulations
    #' 
    #' Parameters
    #' ----
    #' - n (int): number of observations in the sample
    #' 
    #' Returns
    #' ----
    #' - Data (data.table): a data.table object of simulated data
     
    dgp <- fabricate(
        N = 100000,
        E = rnorm(N),
        age = round(
            runif(N, 18, 85)
        ),
        gender = draw_binary(
            N,
            prob = 0.5
        ),
        white = draw_binary(
            N,
            prob = 0.2
        ),
        PartyId = draw_ordered(
            x = rnorm(
                N,
                mean = 0.4 * age - 0.6 * gender + 0.7 * white + E
            ),
            breaks = c(
                -Inf, 20.14, 23.01, Inf
            )
        ),
        Attention = draw_ordered(
            x = rnorm(
                N,
                mean = 0.5 * age - 0.3 * gender + 0.1 * white + E
            ),
            breaks = c(
                -Inf, 16.5, 28.26, 36.54, 43.82, Inf
            )
        ),
        Knowledge = rnorm(
            N,
            mean = 0.6 * age - 0.5 * gender + 0.2 * white + 0.8 * Attention + E
        )/100,
        RedTreatment = draw_binary(
            N,
            prob = 0.5
        ),
        BlueTreatment = draw_binary(
            N,
            prob = 0.5
        ),
        PartyGuess = draw_ordered(
            x = rnorm(
                N,
                mean = 2 * RedTreatment + -2 * BlueTreatment - 0.01 * age - 0.1 * RedTreatment * age + 0.1 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E),
                breaks = c(
                    -Inf, 2, 4, Inf
                )
        )
    )
    #TrialData <- data.table(
    #    "TrialOneTreatmentOne" = integer(),
    #    "TrialOneTreatmentTwo" = integer(),
    #    "TrialTwoTreatmentOne" = integer(),
    #    "TrialTwoTreatmentTwo" = integer(),
    #    "TrialThreeTreatmentOne" = integer(),
    #    "TrialThreeTreatmentTwo" = integer()
    #)
    #TrialOne <- replicate(N, sample(x = 1:3, size = 2))
    #TrialTwo <- replicate(N, sample(x = 1:3, size = 2))
    #TrialThree <- replicate(N, sample(x = 1:3, size = 2))
    #for (n in 1: N) {
    #    df <- data.table(
    #        "TrialOneTreatmentOne" = TrialOne[[1,n]],
    #        "TrialOneTreatmentTwo" = TrialOne[[2,n]],
    #        "TrialTwoTreatmentOne" = TrialTwo[[1,n]],
    #        "TrialTwoTreatmentTwo" = TrialTwo[[2,n]],
    #        "TrialThreeTreatmentOne" = TrialThree[[1,n]],
    #        "TrialThreeTreatmentTwo" = TrialThree[[2,n]]
    #    )
    #    TrialData <- rbindlist(list(TrialData, df))
    #}
#
    #population <- fabricate(
    #    N = 500,
    #    age = round(runif(N, 18, 85)),
    #    gender = draw_binary(prob = 0.5, N),
    #    white = draw_binary(prob = 0.2, N),
    #    PartyId = draw_ordered(
    #        x = rnorm(N, mean = 0.4 * age - 0.6 * gender + 0.7 * white),
    #        breaks = c(-Inf, 20.14, 23.01, Inf),
    #        #break_labels = c("Democrat", "Independent", "Republican"),
    #    ),
    #    Attention = draw_ordered(
    #        x = rnorm(N, mean = 0.5 * age - 0.3 * gender + 0.1 * white),
    #        breaks = c(-Inf, 16.5, 28.26, 36.54, 43.82, Inf),
    #        #break_labels = c("Never", "Some of the time", "About half of the time", "Almost always", "Always"),
    #    ),
    #    Knowledge = rnorm(N, mean = 0.6 * age - 0.5 * gender + 0.2 * white + 0.8 * Attention)/100,
    #)