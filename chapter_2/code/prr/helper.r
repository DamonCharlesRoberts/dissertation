# Title: helper for chapter 2 pre-registered report

# Notes:
    #* Description: 
        #** R script that defines helper functions for chapter 2 pre-registered report
    #* Updated
        #** 2023-03-22
        #** dcr

GenerateSamples <- function(data, n) {
    OneSample <- function(data, n) {
        Sampled <- data[sample(1:nrow(data), n), ]
    }
    SampleData  <- lapply(n, OneSample, data = dgp)
}

Discrepancy <- function(compiled, data, formula, family, model) {
    #' discrepancy
    #'
    #' Description:
    #' ----
    #'  Function that calculates the mean discrepancy between estimates and parameters # nolint
    #'
    #' Parameters:
    #' ----
    #' data(list):
    #'  - List of sample data.frames
    #' model(bool):
    #'
    #' Returns:
    #' ----
    #' data.frame of average discrepancies for each dataset
        # Create empty objects
        CombinedBlue <- NULL
        CombinedRed <- NULL
        CombinedAge <- NULL
        CombinedBlueAge <- NULL
        CombinedRedAge <- NULL
        CombinedAttention <- NULL
        CombinedKnowledge <- NULL
        #** define an empty data.frame to store the mean of the posterior for each sample
        sample_mean <- NULL
        #** for each imputed/amputed dataset for each sample, do the following
        for (j in 1: 500){
            #*** convert the data.frame into a list
            DfList <- make_standata(
                formula,
                data = data[[j]],
                family = family,
                priors = prior(Normal(0,1), class = b)
            )
            ##*** fit the stan model with the data from above
            fitted <- sampling(compiled, DfList, chains = 1, iter = 100)
            #*** take the mean of the posterior estimates for each col
            mean_posterior <- colMeans(as.data.frame(fitted))
            #*** for each sample, add these mean_posteriors to a dataframe
            sample_mean <- rbind(data.frame(sample_mean), as.data.frame.list(mean_posterior))
        }
        #** take the difference between the posterior sample means and actual beta coefficients
        if (model == "PartyGuess" | model == "PartyGuesTrialTwo") {
            MeanRed <- sample_mean[,1] - 2
            MeanBlue <- sample_mean[,2] + 2 
            MeanAge <-sample_mean[,3] + 0.01
            MeanRedAge <- sample_mean[,4] + 0.1
            MeanBlueAge <- sample_mean[,5] - 0.1
            MeanAttention <- sample_mean[,6] - 0.1
            MeanKnowledge <- sample_mean[,7] - 0.1
        } else if (model == "PartyGuessTrialThree") {
            MeanRed <- sample_mean[,1] - 1
            MeanBlue <- sample_mean[,2] + 1
            MeanAge <- sample_mean[,3] + 0.01
            MeanRedAge <- sample_mean[,4] + 0.05
            MeanBlueAge <- sample_mean[,5] - 0.05
            MeanAttention <- sample_mean[,6] - 0.1
            MeanKnowledge <- sample_mean[,7] - 0.1
        } else if (model == "Vote") {
            MeanRed <- sample_mean[,1] - 1
            MeanBlue <- sample_mean[,2] + 1
            MeanAge <- sample_mean[,3] + 0.01
            MeanAttention <- sample_mean[,4] - 0.1
            MeanKnowledge <- sample_mean[,5] - 0.1
        }

            #** store the discrepancies in a data.frame
        CombinedRed <- rbind(
            data.frame(CombinedRed), data.frame(MeanRed)
        ) # nolint
        CombinedBlue <- rbind(
            data.frame(CombinedBlue), data.frame(MeanBlue)
        ) # nolint
        CombinedAge <- rbind(
            data.frame(CombinedAge), data.frame(MeanAge)
        )
        CombinedRedAge <- rbind(
            data.frame(CombinedRedAge), data.frame(MeanRedAge)
        )
        CombinedBlueAge <- rbind(
            data.frame(CombinedBlueAge), data.frame(MeanBlueAge)
        )
        CombinedAttention <- rbind(
            data.frame(CombinedAttention), data.frame(MeanAttention)
        )
        CombinedKnowledge <- rbind(
            data.frame(CombinedKnowledge), data.frame(MeanKnowledge)
        )
        DiscrepancyDf <- cbind(
            CombinedRed,
            CombinedBlue,
            CombinedAge,
            CombinedRedAge,
            CombinedBlueAge,
            CombinedAttention,
            CombinedKnowledge
            )
        #* return the dataframe of discrepancies
        return(DiscrepancyDf)
    }