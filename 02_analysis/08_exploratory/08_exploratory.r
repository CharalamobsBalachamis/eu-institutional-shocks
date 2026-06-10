library(tidyverse)


loadings <- read_csv("pca_loadings.csv")
scores   <- read_csv("pca_scores.csv")
merged_data <- read_csv("merged_data.csv")




#Summary statistics for Principal Components per country
pc_summary_country <- scores %>%
  pivot_longer(cols = c(PC1, PC2, PC3, PC4), names_to = "Component", values_to = "Score") %>%
  group_by(country, Component) %>%
  summarise(
    Mean = mean(Score, na.rm = TRUE),
    StDev = sd(Score, na.rm = TRUE),
    Min = min(Score, na.rm = TRUE),
    Max = max(Score, na.rm = TRUE),
    Observations = n(),
    .groups = "drop"
  )

print("--- COUNTRY-LEVEL DESCRIPTIVE STATISTICS: PRINCIPAL COMPONENTS ---")
print(pc_summary_country)


#plotting 
plot_loadings <- loadings %>%
  select(variable, PC1, PC2, PC3, PC4) %>%
  pivot_longer(
    cols = c(PC1, PC2, PC3, PC4), 
    names_to = "component", 
    values_to = "loading_weight"
  )

p_loadings <- ggplot(plot_loadings, aes(x = reorder(variable, abs(loading_weight)), y = loading_weight, fill = loading_weight > 0)) +
  geom_col(color = "black", alpha = 0.8, show.legend = FALSE) +
  coord_flip() + 
  facet_wrap(~component, ncol = 2, scales = "free_x") + 
  scale_fill_manual(values = c("darkred", "darkblue")) +
  labs(
    title = "Structural Composition of All 4 Institutional Dimensions",
    subtitle = "Comparing variable loading weights across extracted factors",
    x = "Institutional Metrics",
    y = "Component Weight (Loading Coefficient)"
  ) +
  theme_minimal() +
  theme(panel.spacing = unit(1.5, "lines"))


#second plot
scores_long <- scores %>%
  mutate(log_gdp = log(gdp_per_capita)) %>%
  select(country, year, log_gdp, PC1, PC2, PC3, PC4) %>%
  pivot_longer(
    cols = c(PC1, PC2, PC3, PC4), 
    names_to = "component", 
    values_to = "factor_score"
  )

p_scores <- ggplot(scores_long, aes(x = factor_score, y = log_gdp)) +
  geom_point(aes(color = country), size = 2, alpha = 0.6, show.legend = TRUE) + 
  geom_smooth(method = "lm", color = "black", linetype = "dashed", se = FALSE) +
  facet_wrap(~component, ncol = 2, scales = "free_x") +
  labs(
    title = "Log GDP per Capita vs. Dimensional Institutional Factor Scores",
    subtitle = "Baseline pooled slopes for all 4 components before fixed-effects transformations",
    x = "Extracted Factor Score",
    y = "Log GDP per Capita",
    color = "Country Ledger"
  ) +
  theme_minimal() +
  theme(
    panel.spacing = unit(1.5, "lines"),
    legend.position = "bottom",
    legend.text = element_text(size = 8),
    legend.title = element_text(size = 9, face = "bold"),
    legend.box.spacing = unit(0.5, "cm")
  ) +
  guides(
    color = guide_legend(
      nrow = 3, 
      byrow = TRUE, 
      override.aes = list(size = 3, alpha = 1)
    )
  )

#saving the plots
ggsave("03_outputs/figures/pca_loadings_grid.png", plot = p_loadings, width = 14, height = 10, dpi = 300)
ggsave("03_outputs/figures/gdp_vs_pc_factors.png", plot = p_scores, width = 14, height = 11, dpi = 300)

