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
        #posterior <- list()
        #CombinedBlue <- NULL
        #CombinedRed <- NULL
        #CombinedAge <- NULL
        #CombinedBlueAge <- NULL
        #CombinedRedAge <- NULL
        #CombinedAttention <- NULL
        #CombinedKnowledge <- NULL
        parameters <- c("b[1]", "b[2]", "b[3]", "b[4]", "b[5]", "b[6]", "b[7]")
        RejectDF <- setNames(data.frame(matrix(ncol = 7, nrow = 0)), parameters)
        #** define an empty data.frame to store the mean of the posterior for each sample
        #sample_mean <- NULL
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
            fittedDF <- as.data.frame(fitted)
            #*** take the mean of the posterior estimates for each col
            #mean_posterior <- colMeans(as.data.frame(fitted))
            #*** for each sample, add these mean_posteriors to a dataframe
            #sample_mean <- rbind(data.frame(sample_mean), as.data.frame.list(mean_posterior))
            cis <- as.data.frame(bayestestR::hdi(fittedDF, parameters = c("b"), ci = 0.90)) |>
                subset(grepl("b\\[", Parameter))
            pos <- ifelse(
                cis$CI_low > 0 & cis$CI_high > 0, 1, ifelse(cis$CI_low < 0 & cis$CI_high < 0, 1, 0)
                )
            RejectDF <- rbind(
                RejectDF,
                pos
            )
        }
        SumDF <- as.data.frame.list(colMeans(RejectDF))
        colnames(SumDF) <- parameters
        return(SumDF)
    }