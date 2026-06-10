library(tidyverse)

# load the hellscape up
gdp <- read_csv("WEO_Data.csv")


# I HATE THIS FILE. the columns are shifted for no reason so i have to 
# manually frankenstein the numbers back together. 
gdp_dirty <- gdp %>% 
  select(Country, `2021`, `2022`, `2023`, `Estimates Start After`, 
         ...15, ...16, ...17, ...18, ...19, ...20, ...21, ...22) %>% 
  mutate(
    `2018_` = as.numeric(paste0(`2021`, `2022`)), # why is 2018 inside 2021/22???
    `2019_` = as.numeric(paste0(`2023`, `Estimates Start After`)),
    `2020_` = as.numeric(paste0(...15, ...16)),
    `2021_` = as.numeric(paste0(...17, ...18)),
    `2022_` = as.numeric(paste0(...19, ...20)),
    `2023_` = as.numeric(paste0(...21, ...22))
  )

# deleting the trash at the bottom
gdp_eu <- gdp_dirty %>% 
  slice(1:(n() - 2)) %>%
  select(Country, `2018_`, `2019_`, `2020_`, `2021_`, `2022_`, `2023_`) 

# the stitching process ruined the magnitudes so now i have to guess 
# where the decimal point goes based on vibes alone
gdp_eu <- gdp_eu %>% 
  mutate(
    across(
      .cols = c(`2018_`, `2019_`, `2020_`, `2021_`, `2022_`, `2023_`),
      .fns = ~ case_when(
        . < 10000 & . >= 1000 ~ round(. * 10, digits = 0),
        . < 1000 ~ round(. * 100, digits = 0),
        TRUE ~ round(., digits = 0)
      )
    )
  ) %>%
  # ireland broke again specifically in 2021 because of course it did
  mutate(
    `2021_` = case_when(
      Country == "Ireland" & `2021_` < 100000 ~ round(`2021_` * 10, digits = 0),
      TRUE ~ `2021_` 
    )
  )

# sanitize the names so i dont have to look at underscores anymore
gdp_eu <- gdp_eu %>%
  rename_with(
    ~ .x %>%
      str_to_lower() %>%
      str_replace_all("_", "")
  )

# pivot longer to make it look like actual data
gdp_eu <- gdp_eu %>%
  pivot_longer(
    cols = c(`2018`, `2019`, `2020`, `2021`, `2022`, `2023`),
    names_to = "year",
    values_to = "gdp_per_capita"
  ) %>%
  mutate(year = as.integer(year))  


# fixing country names one last time
gdp_eu <- gdp_eu %>% 
  mutate(country = str_replace(country, "Czech Republic", "Czechia")) %>% 
  mutate(country = str_replace(country, "Slovak Republic", "Slovakia"))


# get this thing out of my sight(war is over)
write_csv(gdp_eu, "gdp_per_capita.csv")