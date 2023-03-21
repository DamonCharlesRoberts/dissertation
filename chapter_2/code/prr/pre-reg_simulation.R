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
        prob = 1/3
    ),
    BlueTreatment = draw_binary(
        N,
        prob = 1/3
    ),
    PartyGuess = draw_ordered(
        x = rnorm(
            N,
            mean = 2 * RedTreatment + -2 * BlueTreatment - 0.01 * age - 0.1 * RedTreatment * age + 0.1 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E),
        breaks = c(
            -Inf, -0.5, 0, Inf
        )
    ),
    PartyGuessTrialTwo = draw_ordered(
        x = rnorm(
            N,
            mean = 1 * RedTreatment + -1 * BlueTreatment - 0.01 * age - 0.05 * RedTreatment * age + 0.05 * BlueTreatment * age + 0.1 * Attention + 0.1 * Knowledge + E
        ),
        breaks = c(
            -Inf, -1, 1, Inf
        )
    ),
    Vote = draw_ordered(
        x = rnorm(
            N,
            mean = 1 * RedTreatment + - 1 * BlueTreatment - 0.01 * age + 0.1 * Attention + 0.1 * Knowledge + E
        ),
        breaks = c(
            -Inf, 0, Inf
        )
    )
)

NumOfSamples <- 500
NumOfObs <- c(100, 200, 300, 400)

GenerateSamples <- function(data, n) {
    OneSample <- function(data, n) {
        Sampled <- data[sample(1:nrow(data), n), ]
    }
    SampleData  <- lapply(n, OneSample, data = dgp)
}

Sample <- replicate(NumOfSamples, GenerateSamples(data=dgp, n = NumOfObs))

Sample100 <- purrr::keep(Sample, function(x) nrow(x) == 100)
Sample200 <- purrr::keep(Sample, function(x) nrow(x) == 200)
Sample300 <- purrr::keep(Sample, function(x) nrow(x) == 300)
Sample400 <- purrr::keep(Sample, function(x) nrow(x) == 400)
