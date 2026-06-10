library(tidyverse)

# load the merged data
data <- read_csv("merged_data.csv")


# i want only the variables of interest here
data_for_pca <- data %>% 
  select(-country, -year, -gdp_per_capita)


# scale the data
# pca only works with scaled data
df_scaled <- as.data.frame(scale(data_for_pca))

# performin pca
# center=FALSE/scale.=FALSE because we literally just did it above manually
pca_results <- prcomp(df_scaled, center = FALSE, scale. = FALSE)


# calculate raw scores
raw_scores <- pca_results$x[, 1] # just grabbing PC1 for the check

# check correlation with a variable we KNOW is good
direction_check <- cor(raw_scores, data$economic_freedom_overall)

if(direction_check < 0) {
  print("WARNING: PCA pointed in the wrong direction. Flipping signs now...")
  pca_results$x <- pca_results$x * -1
  pca_results$rotation <- pca_results$rotation * -1
} else {
  print("PCA direction looks correct (High Score = Good Institutions).")
}

# -----------------------------------------------------------------------------


# 4. extract the results
# combining the pc scores back with the country identifiers so we know who is who
pca_scores <- as.data.frame(pca_results$x) %>%
  bind_cols(data %>% select(country, year, gdp_per_capita), .)

# checking the variance explained 
print("--- VARIANCE EXPLAINED ---")
print(summary(pca_results))

# extracting loadings to see which variables matter most
pca_loadings <- as.data.frame(pca_results$rotation) %>%
  rownames_to_column(var = "variable") %>%
  arrange(desc(PC1)) # sorting so we see the winners at the top

print("--- VARIABLE LOADINGS (PC1) ---")
print(head(pca_loadings, 10))


# 5. save the fidnings
write_csv(pca_scores, "pca_scores.csv")
write_csv(pca_loadings, "pca_loadings.csv")