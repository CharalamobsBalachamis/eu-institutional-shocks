library(tidyverse)

# load the yearly datasets
press_2018 <- read_csv2("2018.csv")
press_2019 <- read_csv2("2019.csv")
press_2020 <- read_csv2("2020.csv")
press_2021 <- read_csv2("2021.csv")
press_2022 <- read_csv2("2022.csv")
press_2023 <- read_csv2("2023.csv")


# combine all years into one big dataframe
press_combined <- bind_rows(
  press_2018,
  press_2019,
  press_2020,
  press_2021,
  press_2022,
  press_2023)


# cleaned up the super dirty column names and made one big dataframe 
press_cleaned <- press_combined %>%
  mutate(
    country_final = coalesce(EN_country, Country_EN),
    score_raw = coalesce(`Score N`, Score),
    year_final = coalesce(`Year (N)`)) %>%
  mutate(
    press_freedom_score = str_replace(as.character(score_raw), ",", ".") %>% 
      as.numeric()) %>%
  select(
    year = year_final, 
    country = country_final, 
    press_freedom_score)


# standardized czechia for consistency
press_cleaned <- press_cleaned %>% 
  mutate( country = str_replace(country, "Czech Republic" , "Czechia"))


#kept only european countries
european_countries <- c("Greece", "Germany", "France", "Bulgaria",
                        "Slovakia", "Slovenia", "Denmark", "Belgium",
                        "Cyprus", "Malta", "Netherlands", "Czechia", 
                        "Sweden", "Spain", "Portugal", "Romania",
                        "Ireland", "Italy", "Luxembourg", "Finland",
                        "Estonia", "Latvia", "Lithuania", "Poland",
                        "Croatia", "Austria", "Hungary")

#kept only the correct years
press_freedom_index <- press_cleaned %>% 
  filter(
    country %in% european_countries,
    year >= 2018 & year <= 2023)



write_csv(press_freedom_index, "press_freedom_index_eu.csv")