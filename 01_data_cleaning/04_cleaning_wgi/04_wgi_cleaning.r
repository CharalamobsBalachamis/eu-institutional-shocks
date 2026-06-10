library(tidyverse)

# load the raw wgi data
wgi_data_raw <- read_csv("wgidataset.csv")

# the data was super long so i pivoted it wide to get columns for indicators
wgi_wide <- wgi_data_raw %>%
  select(
    countryname, 
    year, 
    indicator,
    estimate
  ) %>%
  pivot_wider(
    id_cols = c(countryname, year), 
    names_from = indicator, 
    values_from = estimate
  ) %>% 
  # renamed the weird codes to something understandable
  rename(
    accountability = va,
    political_stability = pv,
    government_effectiveness = ge,
    regulatory_quality = rq,
    rule_of_law = rl,
    control_of_corruption = cc)


# made sure all the scores are actually numbers 
wgi_wide <- wgi_wide %>% 
  mutate(
    across(
      .cols = c(accountability, political_stability, government_effectiveness,
                regulatory_quality, rule_of_law, control_of_corruption),
      .fns = as.numeric ))


# fixed country names for Czechia and Slovakia
wgi_wide <- wgi_wide %>% 
  rename(country = countryname) %>% 
  mutate(country = str_replace(country, "Czech Republic", "Czechia")) %>% 
  mutate(country = str_replace(country, "Slovak Republic", "Slovakia"))


# kept only european countries
european_countries <- c("Greece", "Germany", "France", "Bulgaria",
                        "Slovakia", "Slovenia", "Denmark", "Belgium",
                        "Cyprus", "Malta", "Netherlands", "Czechia", 
                        "Sweden", "Spain", "Portugal", "Romania",
                        "Ireland", "Italy", "Luxembourg", "Finland",
                        "Estonia", "Latvia", "Lithuania", "Poland",
                        "Croatia", "Austria", "Hungary")


# kept only the correct years
wgi_index <- wgi_wide %>% 
  filter(
    country %in% european_countries,
    year >= 2018 & year <= 2023)

# save the cleaned data
write_csv(wgi_index, "wgi_index_eu.csv")