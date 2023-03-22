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

Discrepancy <- function(data) {
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
        #** define an empty data.frame to store the mean of the posterior for each sample
        sample_mean <- NULL
        #** for each imputed/amputed dataset for each sample, do the following
        for (j in 1: 500){
            #*** convert the data.frame into a list
            DfList <- list(
                N = nrow(data),
                Y = data$PartyGuess,
                nthres = data$2,
                K = 1,
                X = as.matrix(
                    data$RedTreatment,
                    data$BlueTreatment,
                    data$age,
                    data$Attention,
                    data$Knowledge
                ),
                prior_only = 0
            )
            ##*** fit the stan model with the data from above
            fitted <- sampling(compiled, DfList, chains = 1, iter = 100)
            #*** take the mean of the posterior estimates for each col
            mean_posterior <- colMeans(as.data.frame(fitted))
            #*** for each sample, add these mean_posteriors to a dataframe
            sample_mean <- rbind(data.frame(sample_mean), as.data.frame.list(mean_posterior))
        }
        #** take the difference between the posterior sample means and actual beta coefficients
        mean_x <- mean(sample_mean$beta_1 - 0.6)
        mean_z <- mean(sample_mean$beta_2 - 0.9)
            #** store the discrepancies in a data.frame
        if (model == FALSE){
            combined_x <- bind_rows(data.frame(combined_x), data.frame(mean_x)) # nolint
            combined_z <- bind_rows(data.frame(combined_z), data.frame(mean_z)) # nolint
            combined_y <- bind_rows(data.frame(combined_y), data.frame(mean_y))
            discrepancy_df <- cbind(combined_x, combined_z, combined_y)
        } else {
            combined_x <- bind_rows(data.frame(combined_x), data.frame(mean_x)) # nolint
            combined_z <- bind_rows(data.frame(combined_z), data.frame(mean_z)) # nolint
            discrepancy_df <- cbind(combined_x, combined_z)
        }
        #* return the dataframe of discrepancies
        return(discrepancy_df)
    }