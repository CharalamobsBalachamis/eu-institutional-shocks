library(tidyverse)

# reading in all the files i struggled to clean
cpi <- read_csv("corruption_perception_index_eu.csv") %>% 
  select(country, year, cpi_score)

economic_freedom <- read_csv("economic_freedom_eu.csv") %>% 
  rename(economic_freedom_overall = overall_score) %>% 
  select(country, year, economic_freedom_overall)

gdp_per_capita <- read_csv("gdp_per_capita.csv")
press_freedom <- read_csv("press_freedom_index_eu.csv")
wgi <- read_csv("wgi_index_eu.csv")


# joining everything by country and year
merged_data <- cpi %>% 
  left_join(economic_freedom, by = c("country", "year")) %>%
  left_join(press_freedom,    by = c("country", "year")) %>%
  left_join(wgi,              by = c("country", "year")) %>%
  left_join(gdp_per_capita,   by = c("country", "year"))


# write the merged file
write_csv(merged_data, "merged_data.csv")