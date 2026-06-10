library(tidyverse)
library(fixest)   

# load the pca scores
data <- read_csv("pca_scores.csv")

# transforming variables and setting up our panel lags
data_clean <- data %>%
  mutate(log_gdp_per_capita = log(gdp_per_capita)) %>% 
  
  # group by country so our lags don't bleed across borders
  group_by(country) %>%
  arrange(year, .by_group = TRUE) %>%
  mutate(
    # defining the covid shock years
    covid_shock = if_else(year %in% c(2020, 2021), 1, 0),
    
    # lagging all 4 principal components because institutions work with a temporary delay
    pc1_lag = dplyr::lag(PC1, n = 1),
    pc2_lag = dplyr::lag(PC2, n = 1),
    pc3_lag = dplyr::lag(PC3, n = 1),
    pc4_lag = dplyr::lag(PC4, n = 1)
  ) %>%
  ungroup() %>%
  # drop rows that got NAs due to the lag process
  drop_na(pc1_lag, pc2_lag, pc3_lag, pc4_lag)



# Model 1: Pooled OLS baseline with all 4 components
model_ols <- feols(
  log_gdp_per_capita ~ pc1_lag + pc2_lag + pc3_lag + pc4_lag, 
  data = data_clean
)
etable(model_ols)

# Model 2: Country Fixed Effects (Controls for static country traits)
# Clustered standard errors by country are applied automatically by fixest
model_country_fe <- feols(
  log_gdp_per_capita ~ pc1_lag + pc2_lag + pc3_lag + pc4_lag | country, 
  data = data_clean
)

etable(model_country_fe)

# Model 3: Twoway Fixed Effects (Controls for country traits AND global macro shocks like inflation)
model_twoway_fe <- feols(
  log_gdp_per_capita ~ pc1_lag + pc2_lag + pc3_lag + pc4_lag | country + year, 
  data = data_clean
)

# Model 4: Twoway Fixed Effects with Covid Interaction 
# Seeing if institutional features cushioned or worsened the Covid economic shock
model_interaction <- feols(
  log_gdp_per_capita ~ pc1_lag*covid_shock + pc2_lag*covid_shock + 
    pc3_lag*covid_shock + pc4_lag*covid_shock | country + year, 
  data = data_clean
)
etable(model_interaction)

# model 5 Interaction terms without any Fixed Effects (Pooled OLS with Interactions)
model_interaction_no_fe <- feols(
  log_gdp_per_capita ~ pc1_lag*covid_shock + pc2_lag*covid_shock + 
    pc3_lag*covid_shock + pc4_lag*covid_shock, 
  data = data_clean
)

etable(model_interaction_no_fe)

