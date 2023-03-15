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
    brms[bf, prior, make_stancode, make_standata, pp_check, cumulative, bernoulli],
    rstan[read_stan_csv],
    marginaleffects[avg_slopes, posterior_draws],
    ggplot2[ggplot, aes, labs, theme_minimal],
    ggmosaic[geom_mosaic, product],
    bayesplot[color_scheme_set, bayesplot_theme_set, mcmc_combo, mcmc_areas, pp_check],
    ggdist[stat_halfeye]
)
    #* create empty data list object
data <- list()
    #* import cleaned dataset 
data[['original']] <- setDT(read_dta("../../data/prr/pre-test/sps1.dta"))

    #* default theme
red_custom <- c("#DCBCBC", "#C79999", "#B97C7C", "#FFFFFF", "#8F2727", "#7C0000")
color_scheme_set(red_custom)
bayesplot_theme_set(new = theme_minimal())
    #* default tails
options("marginaleffects_posterior_interval" = "hdi")

# Models
    #* On party guesses
        #** Setup
            #*** Model specification
party_formula <- bf(
    Party ~ RedTreatment + BlueTreatment, 
    family = cumulative(link = "logit")
)
weak_priors <- prior(normal(0, 10), class = b)
strong_priors <- prior(normal(0, 1), class = b)
            #*** Convert model and data into cmdstanr
party_weak_code <- make_stancode(
    formula = party_formula,
    data = data[["clean"]],
    priors = weak_priors
)

party_strong_code <- make_stancode(
    formula = party_formula, 
    data = data[["clean"]],
    priors = strong_priors
)

party_data <- make_standata(
    formula = party_formula,
    data = data[["clean"]]
    )

class(party_data) <- NULL
            #*** Store the model in a temp stan file
party_weak_file <- write_stan_file(party_weak_code)
party_strong_file <- write_stan_file(party_strong_code)
        #** Compile models
party_weak_model <- cmdstan_model(
    party_weak_file,
    cpp_options = list(stan_threads = TRUE),
    #stanc_options = list("OExperimental")
)
party_weak_model$format(
    overwrite_file = TRUE,
    canonicalize = TRUE,
    quiet = TRUE
)
party_strong_model <- cmdstan_model(
    party_strong_file,
    cpp_options = list(stan_threads = TRUE),
)
party_strong_model$format(
    overwrite_file = TRUE,
    canonicalize = TRUE,
    quiet = TRUE
)
        #** Fit the models
party_weak_fitted <- party_weak_model$sample(
    data = party_data,
    chains = 4,
    parallel_chains = 4,
    threads_per_chain = 5,
    refresh = 500
)
party_strong_fitted <- party_strong_model$sample(
    data = party_data,
    chains = 4,
    parallel_chains = 4,
    threads_per_chain = 5,
    refresh = 500
)
            #*** Convert the cmdstanr models into brmsfit objects
party_weak_brms <- brm(party_formula, data = data[["clean"]], empty = TRUE)
party_weak_brms$fit <- read_stan_csv(party_weak_fitted$output_files())
party_weak_brms <- rename_pars(party_weak_brms)

party_strong_brms <- brm(party_formula, data = data[["clean"]], empty = TRUE)
party_strong_brms$fit<- read_stan_csv(party_strong_fitted$output_files())
party_strong_brms <- rename_pars(party_strong_brms)
        #** Check model performance
party_weak_brms
party_strong_brms
mcmc_combo(party_weak_brms)
mcmc_combo(party_strong_brms)
pp_check(party_weak_brms, ndraws = 500)
pp_check(party_strong_brms, ndraws = 500)
pp_check(party_weak_brms, type = "stat")
pp_check(party_weak_brms, type = "stat")

        #** plot model results
ames <- avg_slopes(party_weak_brms, type = "link") |>
    posterior_draws()

ggplot(ames, aes(x = draw, y = term)) +
    stat_halfeye(slab_alpha = 0.89) +
    theme_minimal() +
    labs(
        x = "Average Marginal Effect",
        y = "",
        caption = "Data source: Pre-test.\n Distribution of Average Marginal Effects for model posterior draws.\n Inverse logit applied to calculate the AME's. Bars reflect 89% HDI's."
    )


# TODO: Set up these models like I did above. Also clean all of this up and document it a bit better while I am at it.
    #* On vote choice
        #** Setup
            #*** Model specification
vote_formula <- bf(
    Vote ~ RedTreatment + BlueTreatment + PartyId + RedTreatment * PartyId + BlueTreatment * PartyId,
    family = bernoulli(link = "logit")
)
weak_priors <- priors(normal(0, 10), class = b)
strong_priors <- priors(normal(0, 1), class = b)
            #*** convert model and data into cmdstanr
vote_weak_code <- make_stancode(
    formula = vote_formula,
    data = data[["clean"]],
    priors = weak_priors
)
vote_strong_code <- make_stancode(
    formula = vote_formula,
    data = data[["clean"]],
    priors = strong_priors
)
vote_data <- make_standata(
    formula = vote_formula,
    data = data[["clean"]]
)
class(vote_data) <- NULL
            #*** Store the model in a temp stan file
vote_weak_file <- write_stan_file(vote_weak_code)
vote_strong_file <- write_stan_file(vote_strong_code)

        #** Compile models
vote_weak_model <- cmdstan_model(
    vote_weak_file,
    cpp_options = list(stan_threads = TRUE)
)
vote_weak_model$format(
    overwrite_file = TRUE,
    canonicalize = TRUE,
    quiet = TRUE
)
vote_strong_model <- cmdstan_model(
    vote_strong_file,
    cpp_options = list(stan_threads = TRUE)
)
vote_strong_model$format(
    overwrite_file = TRUE,
    canonicalize = TRUE,
    quiet = TRUE
)

        #** Fit models
vote_weak_fitted <- vote_weak_model$sample(
    data = vote_data,
    chains = 4,
    parallel_chains = 4,
    threads_per_chain = 5,
    refresh = 500
)
vote_strong_fitted <- vote_strong_model$sample(
    data = vote_data,
    chains = 4,
    parallel_chains = 4,
    threads_per_chain = 5,
    refresh = 500
)

        #** convert cmdstanfit to brmsfit objects
vote_weak_brms <- brm(
    party_formula,
    data = data[["clean"]],
    empty = TRUE
)
vote_weak_brms$fit <- read_stan_csv(
    party_weak_fitted$output_files()
)
vote_weak_brms <- rename_pars(party_weak_brms)

vote_strong_brms <- brm(
    party_formula,
    data = data[["clean"]],
    empty = TRUE
)
vote_strong_brms$fit <- read_stan_csv(
    party_strong_fitted$output_files()
)
vote_strong_brms <- rename_pars(party_strong_brms)

        #** model checks
vote_weak
vote_strong
mcmc_combo(vote_weak)
mcmc_combo(vote_strong)
pp_check(vote_weak, ndraws = 500)
pp_check(vote_strong, ndraws = 500)
pp_check(vote_weak, type = "stat")
pp_check(vote_strong, type = "stat")