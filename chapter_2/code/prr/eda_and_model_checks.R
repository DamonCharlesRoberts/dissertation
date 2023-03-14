# Title: pre-test model exploratory

# Notes:
    #* Description: Script to do exploratory data analysis along with checking model assumptions
    #* Updated: 2023-03-13
    #* Updated by: dcr

# Set up
    #* Set seed
set.seed(12062022)
    #* Set working directory
setwd("./chapter_2/code/prr")
    #* Load functions
box::use(
    haven[read_dta],
    data.table[...],
    modelsummary[datasummary_skim, datasummary_crosstab, modelsummary],
    cmdstanr[...],
    #rstan[stan_model, sampling],
    #brms[brm, pp_check],
    broom[tidy],
    #marginaleffects[marginaleffects, posteriordraws],
    ggplot2[ggplot, aes, labs, theme_minimal],
    ggmosaic[geom_mosaic, product],
    bayesplot[color_scheme_set, bayesplot_theme_set, ppc_dens_overlay, mcmc_areas]
    #ggdist[stat_halfeye]
)
    #* create empty data list object
data <- list()
    #* import cleaned dataset 
data[['original']] <- setDT(read_dta("../../data/prr/pre-test/sps1.dta"))

    #* default theme
red_custom <- c("#DCBCBC", "#C79999", "#B97C7C", "#FFFFFF", "#8F2727", "#7C0000")
color_scheme_set(red_custom)
bayesplot_theme_set(new = theme_minimal())
# Data cleaning

data[["clean"]] <- data[["original"]][
  #* Female - binary gender id of respondent
    #** gender coded as: 1 = male, 2 = female
    #** Recode to: 0 = male, 1 = female
  , Female := fifelse(
      gender == 1, 0, 1, na = NA
    )
][
    , FemaleCat := factor(
        Female,
        labels = c(
            "Male",
            "Female"
        ),
        ordered = TRUE
    )
][
  #* white - race of respondent
    #** race: 1 = Asian, 2 = African-American/Black, 3 = Hispanic/Latino, 4 = Native American, 5 = White, 6 = Other
    #** Recode to: 0 = non-White, 1 = White
  , White := fifelse(
      race == 5, 1, 0
    )
][
    , WhiteCat := factor(
        White,
        labels = c(
            "Non-White",
            "White"
        ),
        ordered = TRUE
    )
][
    #* pid - partisan identification
      #** combination of multiple questions
      #** pid: -3 = strong democrat, -2 = democrat, -1 = leans democratic, 0 = independent, 1 = leans republican, 2 = republican, 3 = strong republican
  , PartyId := fcase(
      pid == 2 & dem1 == 1, -3,
      pid == 2 & dem1 == 2, -2,
      pid == 3 & ind1 == 2, -1,
      pid == 3 & ind1 == 3, 0,
      pid == 3 & ind1 == 1, 1,
      pid == 1 & rep1 == 2, 2,
      pid == 1 & rep1 == 1, 3,
      default = NA
    )
][
    , PartyIdCat := factor(
        PartyId,
        labels = c(
            "Strong Democrat",
            "Democrat",
            "Leans Democratic",
            "Independent",
            "Leans Republican",
            "Republican",
            "Strong Republican"
        ),
        ordered = TRUE
    )
][
    #* blue_treatment - did they receive the blue yard sign treatment
      #** q265: 0 = did not display treatment, 1 = did display treatment
      #** recoded to: 0 = did not display treatment, 1 = did display treatment
  , BlueTreatment := fifelse(
      q265 == 1, 1, 0, na = 0
    )
][
    , BlueTreatmentCat := factor(
        BlueTreatment,
        labels = c(
            "Did not receive",
            "Received"
        ),
        ordered = TRUE
    )
][
    #* red_treatment - did they receive the red yard sign treatment?
      #** q421: 0 = did not display treatment, 1 = did display treatment
      #** recoded to: 0 = did not display treatment, 1 = did display treatment
  , RedTreatment := fifelse(
      q421 == 1, 1, 0, na = 0
    )
][
    , RedTreatmentCat := factor(
        RedTreatment,
        labels = c(
            "Did not receive",
            "Received"
        ),
        ordered = TRUE
    )
][
    #* white_treatment - did they receive the white yard sign treatment?
      #** q423: 0 = did not display treatment, 1 = did display treatment
      #** recoded to: 0 = did not display treatment, 1 = did display treatment
  , WhiteTreatment := fifelse(
      q423 == 1, 1, 0, na = 0
    )
][
    , WhiteTreatmentCat := factor(
        WhiteTreatment,
        labels = c(
            "Did not receive",
            "Received"
        ),
        ordered = TRUE
    )
][
    #* t_party - party of fictional candidate
      #** dr_pid: 1 = republican, 2 = democrat, 3 = neither
      #** recoded to: -1 = democrat, 0 = neither, 1 = republican
  , Party := fcase(
      dr_pid == 2, 1,
      dr_pid == 3, 2,
      dr_pid == 1, 3
    )
][
    , PartyCat := factor(
        Party,
        labels = c(
            "Democrat",
            "Independent",
            "Republican"
        ),
        ordered = TRUE
    )
][
    #* t_vote - vote for fictional candidate
        #** dr_info_4: 2 = do not vote for the candidate, 1 = vote for candidate & dr_info_5: 2 = do not avoid candidate, 1 = avoid candidate
        #** t_vote: -1 = avoid candidate, 0 = avoid & vote/do not avoid & do not vote, 1 = vote
  , Vote := fcase(
      dr_info_4 == 2 & dr_info_5 == 1, 1,
      dr_info_4 == 1 & dr_info_5 == 1, 0,
      dr_info_4 == 2 & dr_info_5 == 2, 0,
      dr_info_4 == 1 & dr_info_5 == 2, 1
    )
][
    , VoteCat := factor(
        Vote,
        labels = c(
            "Won't vote for",
            "Will vote for"
        ),
        ordered = TRUE)
]

# Univariate EDA
    #* Make table
data_summary_table <- data[["clean"]][
    , .(Female, White, age, PartyId, BlueTreatment, RedTreatment, Vote)
] |>
    datasummary_skim(
      notes = c(
        'Data source: Pre-test experiment.',
        'Unique column includes NA values.'
      )
    )

# Bivariate EDA
    #* On party of candidate
red_party_xtab <- datasummary_crosstab(RedTreatmentCat ~ PartyCat, data = data[["clean"]])
blue_party_xtab <- datasummary_crosstab(BlueTreatmentCat ~ PartyCat, data = data[["clean"]])    
white_party_xtab <- datasummary_crosstab(WhiteTreatmentCat ~ PartyCat, data = data[["clean"]])    
    #* On vote choice
red_treatment_xtab <- datasummary_crosstab(RedTreatmentCat ~ VoteCat, data = data[["clean"]])
blue_treatment_xtab <- datasummary_crosstab(BlueTreatmentCat ~ VoteCat, data = data[["clean"]])
white_treatment_xtab <- datasummary_crosstab(WhiteTreatmentCat ~ VoteCat, data = data[["clean"]])

# Models
    #* On party guesses
data_complete <- na.omit(data[["clean"]], cols = c("RedTreatment", "BlueTreatment", "Party"))

data_list <- list(
    N = nrow(data_complete),
    Y = data_complete$Party,
    nthres = 2,
    K = 2,
    X = as.matrix(data_complete[, .(RedTreatment, BlueTreatment)]),
    prior_only = 0
)

party_weak <- cmdstan_model("pre-test_party_weak.stan")
party_weak_model <- party_weak$sample(data = data_list, chains = 1)

party_strong <- cmdstan_model("pre-test_party_strong.stan")
party_strong_model <- party_strong$sample(data = data_list, chains = 1)

    #* Check models
y <- data_complete$Party
y_weak_rep <- party_weak_model$draws("y_rep", format = "matrix")
y_strong_rep <- party_strong_model$draws("y_rep", format = "matrix")

ppc_dens_overlay(y = y, yrep = y_weak_rep)
ppc_dens_overlay(y = y, yrep = y_strong_rep)
    #* On vote choice
data_complete <- na.omit(data[["clean"]], cols = c("RedTreatment", "BlueTreatment", "Vote", "PartyId"))

data_list <- list(
    N = nrow(data_complete),
    Y = data_complete$Vote,
    K = 5,
    red = data_complete$RedTreatment,
    blue = data_complete$BlueTreatment,
    pid = data_complete$PartyId
)

vote_weak <- cmdstan_model("pre-test_vote_weak.stan")
vote_weak_fitted <- vote_weak$sample(
    data = data_list,
    chains = 1
)
y <- data_complete$Vote
y_weak_rep <- vote_weak_fitted$draws("y_rep", format = "matrix")
ppc_dens_overlay(y = y, yrep = y_weak_rep)
model_draws <- vote_weak_fitted$draws(c("beta_1", "beta_2", "beta_3", "beta_4", "beta_5"), format = "matrix")
mcmc_areas(model_draws, prob = 0.89, border_size = 1, point_size = 10) + 
    ggplot2::scale_y_discrete(
        labels = c("beta_1" = "Red", "beta_2" = "Blue", "beta_3" = "Party ID", "beta_4" = "Red X Party ID", "beta_5" = "Blue X Party ID")
    ) +
    ggplot2::geom_vline(aes(xintercept = 0), color = "#000000", linetype = 2, linewidth = 1) +
    labs(
        x = "Estimated effect",
        caption ="Data source: Pre-test.\nDistribution of posterior draws from a binary logistic regression.\nb ~ Normal(0, 10)"
    )
