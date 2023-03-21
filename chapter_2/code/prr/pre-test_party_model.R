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
source("pre-test_cleaning.R")
    #* Load functions
box::use(
    data.table[...],
    modelsummary[modelsummary],
    cmdstanr[...],
    brms[bf, prior, brm, rename_pars, make_stancode, make_standata, pp_check, cumulative, bernoulli],
    rstan[read_stan_csv],
    marginaleffects[avg_slopes, posterior_draws, plot_slopes],
    ggplot2[ggplot, aes, labs, theme_minimal, scale_y_discrete],
    bayesplot[color_scheme_set, bayesplot_theme_set, mcmc_combo, mcmc_areas, pp_check],
    ggdist[stat_halfeye]
)
cmdstanr::set_cmdstan_path("C:\\cmdstan")
    #* default theme
#red_custom <- c("#DCBCBC", "#C79999", "#B97C7C", "#FFFFFF", "#8F2727", "#7C0000")
color_scheme_set(scheme = "gray")
bayesplot_theme_set(new = theme_minimal())
    #* default tails
options("marginaleffects_posterior_interval" = "hdi")

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