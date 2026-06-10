library(tidyverse)

# huge dirty wide dataset 
corruption_wide <- read_csv("CPI2024-Results-and-trends.csv", skip = 2)


# cleaning so i can make the data long format
corruption_clean_names <- corruption_wide %>%
  rename_with(
    ~ .x %>%
      str_to_lower() %>%
      str_replace_all("cpi score", "cpi_score") %>%
      str_replace_all("\\s|\\/", "_"))


# pivoting to long format so we have one row per year
corruption_long <- corruption_clean_names %>%
  pivot_longer(
    cols = matches("\\d{4}$"), # grab any column ending in a year (e.g. 2024)
    names_to = c(".value", "year"),
    names_pattern = "(.*)_(\\d{4})",
    names_transform = list(year = as.integer)
  ) %>%
  rename(country = country___territory)


# standardize czechia
corruption_long <- corruption_long %>% 
  mutate( country = str_replace(country, "Czech Republic" , "Czechia") )


# kept only european countries
european_countries <- c("Greece", "Germany", "France", "Bulgaria",
                        "Slovakia", "Slovenia", "Denmark", "Belgium",
                        "Cyprus", "Malta", "Netherlands", "Czechia", 
                        "Sweden", "Spain", "Portugal", "Romania",
                        "Ireland", "Italy", "Luxembourg", "Finland",
                        "Estonia", "Latvia", "Lithuania", "Poland",
                        "Croatia", "Austria", "Hungary")



# filter for eu countries and correct years (2018-2023)
corruption_perception_index_eu <- corruption_long %>% 
  filter(
    country %in% european_countries,
    year >= 2018 & year <= 2023
  ) %>%
  select(country, year, cpi_score) 


# export final cleaned data
write_csv(corruption_perception_index_eu, "corruption_perception_index_eu.csv")