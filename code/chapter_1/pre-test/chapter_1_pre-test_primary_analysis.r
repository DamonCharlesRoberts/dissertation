# Title: Primary analysis for chapter 1 pre-test

# Notes:
    #* Description: Rscript of primary analysis for the pre-test in chapter 1
    #* Updated: 2022-08-24
    #* Updated by: dcr 

# Setup
    #* source the cleaning script
source('code/chapter_1/pre-test/chapter_1_pre-test_cleaning.r')
    #* modularly load functions
box::use(
    modelsummary = modelsummary[datasummary_skim, modelsummary],
    dplyr = dplyr[select, rename],
    rstanarm = rstanarm[stan_polr, stan_glm, R2],
    #brms = brms[brm, cumulative, dirichlet]
    tibble = tibble[tribble]
)

# Analyses
model = list()
    #** Associate color with partisanship
model[['party_guess']] = stan_polr(as.factor(t_party) ~ blue_treatment + red_treatment, data = data[['clean']], method = 'logistic', prior = R2(0.3, 'mean'), seed = 90210, chains = 6, iter = 2000, adapt_delta = 0.99)
    #** evaluation of candidate
cand_eval = lm(t_vote ~ blue_treatment + red_treatment + pid + blue_treatment*pid + red_treatment*pid, data = data[['clean']])
model[['cand_eval']]= stan_polr(as.factor(t_vote) ~ blue_treatment + red_treatment + pid + blue_treatment*pid + red_treatment*pid, data = data[['clean']], prior = R2(0.3, 'mean'), seed = 90210, chains = 6, iter = 2000, adapt_delta = 0.99)
    #** evaluation of neighbor
neigh_eval = lm(t_neigh ~ blue_treatment + red_treatment + pid + blue_treatment*pid + red_treatment*pid, data = data[['clean']])
model[['neigh_eval']]  = stan_glm(t_neigh ~ blue_treatment + red_treatment + pid + blue_treatment*pid + red_treatment*pid, data = data[['clean']], seed = 90210, chains = 6, iter = 2000, adapt_delta = 0.99)

# Tables
    #* Descriptive statistics
data[['clean']] |>
    select(female, white, age, pid) |>
    rename(`Female` = female, 
            `White` = white,
            `Age` = age,
            `Party ID` = pid) |>
    datasummary_skim(title = 'Chapter 1 Pre-test descriptive statistics \\label{tab:descriptive_stats}', histogram = FALSE, output = 'figures/chapter_1/pre-test/chapter_1_pre-test_descriptive_statistics.tex')

    #* Models
        #** Set up non-coefficient related information from models 
gm = list(
    list('raw' = 'nobs', 'clean' = 'N', fmt = 0)
)
        #** Convert models to 
        #** Guess the party 
table_contents = list(
    'Party' = model[['party_guess']],
    'Candidate evaluation' = model[['cand_eval']],
    'Neighbor evaluation' = model[['neigh_eval']]
)
rows = tribble(~term, ~`Party`, ~`Candidate evaluation`, ~`Neighbor evaluation`, 'Thresholds', '', '', '')
attr(rows, 'position') = c(13)
table = modelsummary(table_contents, statistic = 'conf.int', coef_map = c('blue_treatment' = 'Blue treatment', 'red_treatment' = 'Red treatment', 'pid' = 'Party ID', 'blue_treatment:pid' = 'Blue treatment $\\times$ Party ID', 'red_treatment:pid' = 'Red treatment $\\times$ Party ID', '(Intercept)' = 'Intercept', '-1|0' = 'Threshold 1', '0|1' = 'Threshold 2'), gof_map = gm, add_rows = rows, notes = list('Median estimate from fitted model with 6 chains and 2000 iterations.', '$95\\%$ credible intervals in brackets.', 'Data source: Pre-test experiment.'), title = 'The association of color with partisanship and its effects \\label{tab:pre-test_models}', escape = FALSE, output = 'figures/chapter_1/pre-test/chapter_1_pre-test_models.tex')