library(tidyverse)


# skipped the first 3 rows because otherwise the weird csv file is messed up
economic_freedom <- read_csv("economic_freedom2012-2024.csv", skip = 3)

# made everything lowercase and used snake_case for consistency 
economic_freedom <- economic_freedom %>%
  rename_with(
    ~ .x %>%
      str_to_lower() %>%
      str_replace_all("\\s|\\/", "_"))


# renamed the year column to something simple
economic_freedom <- economic_freedom %>% 
  rename(year = index_year)


# changed the name of czechia for consistency
economic_freedom <- economic_freedom %>% 
  mutate( country = str_replace(country, "Czech Republic" , "Czechia"))


# this is so that i only keep the data of european countries
european_countries <- c("Greece", "Germany", "France", "Bulgaria",
                        "Slovakia", "Slovenia", "Denmark", "Belgium",
                        "Cyprus", "Malta", "Netherlands", "Czechia", 
                        "Sweden", "Spain", "Portugal", "Romania",
                        "Ireland", "Italy", "Luxembourg", "Finland",
                        "Estonia", "Latvia", "Lithuania", "Poland",
                        "Croatia", "Austria", "Hungary")


# and this is so that i only keep the correct years
economic_freedom <- economic_freedom %>% 
  filter(
    country %in% european_countries,
    year >= 2018 & year <= 2023)

# save the cleaned economic freedom data into a csv
write_csv(economic_freedom, "economic_freedom_eu.csv")