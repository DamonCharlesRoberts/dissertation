# Title: Chapter 2 pre-test eda

# Notes:
    #* Description:
        #** Exploratory data analysis for chapter 2 pre-test
    #* Updated:
        #** 2023-03-15
        #** by: dcr 

# Setup
    #* set working directory
setwd("./chapter_2/code/prr")
    #* Modularly load functions
box::use(
    modelsummary[
        datasummary_skim,
        datasummary_crosstab
    ],
    ggplot2[
        ggplot,
        geom_bar,
        aes,
        labs,
        theme_minimal,
        scale_fill_manual
    ]
)
    #* Source cleaning script
source("pre-test_cleaning.R")

# Univariate EDA
    #* Make table
data_summary_table <- data[["clean"]][
    , .(Female, White, age, PartyId, BlueTreatment, RedTreatment, Vote)
] |>
datasummary_skim(
    notes = c(
        "Data source: Pre-test experiment.",
        '"Unique" column includes missing values.'
    )
)

# Bivariate EDA
    #* Party as DV
        #** Plots
red_party_bivariate <- ggplot(
    data = data[["clean"]]
) +
geom_bar(
    aes(
        x = PartyCat,
        fill = RedTreatmentCat
    ),
    position ="dodge"
) +
theme_minimal() +
scale_fill_manual(
    values = c("#D3D3D3", "#8F2727")
) +
labs(
    x = "Assumed party",
    y = "Count",
    fill = "Red treatment?",
    caption = "Data source: Pre-treatment.\n Perceptions of candidate party based on yard sign in treatment."
)
blue_party_bivariate <- ggplot(
    data = data[["clean"]]
) +
geom_bar(
    aes(
        x = PartyCat,
        fill = BlueTreatmentCat
    ),
    position = "dodge"
) +
theme_minimal() +
scale_fill_manual(
    values = c("#D3D3D3", "#8F2727")
) +
labs(
    x = "Assumed party",
    y = "Count",
    fill = "Blue Treatment?",
    caption = "Data source: Pre-treatment.\n Perceptions of candidate party based on yard sign in treatment."
)
white_party_bivariate <- ggplot(
    data = data[["clean"]]
) +
geom_bar(
    aes(
        x = PartyCat,
        fill = WhiteTreatmentCat
    ),
    position = "dodge"
) +
theme_minimal() +
scale_fill_manual(
    values = c("#D3D3D3", "#8F2727")
) +
labs(
    x = "Assumed party",
    y = "Count",
    fill = "White Treatment?",
    caption = "Data source: Pre-treatment.\n Perceptions of candidate party based on yard sign in treatment."
)
        #** Crosstabs
red_party_xtab <- datasummary_crosstab(
    RedTreatmentCat ~ PartyCat,
    data = data[["clean"]]
)
blue_party_xtab <- datasummary_crosstab(
    BlueTreatmentCat ~ PartyCat,
    data = data[["clean"]]
)
white_party_xtab <- datasummary_crosstab(
    WhiteTreatmentCat ~ PartyCat,
    data = data[["clean"]]
)
    #** Vote intention as DV
        #** Plots
red_vote_bivariate <- ggplot(
    data = data[["clean"]]
) +
geom_bar(
    aes(
        x = VoteCat,
        fill = RedTreatmentCat
    ),
    position ="dodge"
) +
theme_minimal() +
scale_fill_manual(
    values = c("#D3D3D3", "#8F2727")
) +
labs(
    x = "Vote?",
    y = "Count",
    fill = "Red treatment?",
    caption = "Data source: Pre-treatment.\n Willingness to cast vote based on yard sign in treatment."
)
blue_vote_bivariate <- ggplot(
    data = data[["clean"]]
) +
geom_bar(
    aes(
        x = VoteCat,
        fill = BlueTreatmentCat
    ),
    position = "dodge"
) +
theme_minimal() +
scale_fill_manual(
    values = c("#D3D3D3", "#8F2727")
) +
labs(
    x = "Vote?",
    y = "Count",
    fill = "Blue Treatment?",
    caption = "Data source: Pre-treatment.\n Willingness to cast vote based on yard sign in treatment."
)
white_vote_bivariate <- ggplot(
    data = data[["clean"]]
) +
geom_bar(
    aes(
        x = VoteCat,
        fill = WhiteTreatmentCat
    ),
    position = "dodge"
) +
theme_minimal() +
scale_fill_manual(
    values = c("#D3D3D3", "#8F2727")
) +
labs(
    x = "Vote?",
    y = "Count",
    fill = "White Treatment?",
    caption = "Data source: Pre-treatment.\n Willingness to cast vote based on yard sign in treatment."
)
        #** Crosstabs
red_vote_xtab <- datasummary_crosstab(
    RedTreatmentCat ~ VoteCat,
    data = data[["clean"]]
)
blue_vote_xtab <- datasummary_crosstab(
    BlueTreatmentCat ~ VoteCat,
    data = data[["clean"]]
)
white_vote_xtab <- datasummary_crosstab(
    WhiteTreatmentCat ~ VoteCat,
    data = data[["clean"]]
)
