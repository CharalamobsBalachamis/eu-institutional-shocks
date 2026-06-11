# EU Institutional Resilience to Macroeconomic Shocks (2018–2023)

A panel data econometric analysis evaluating how institutional quality affected the GDP trajectories of 27 European Union member states during the Covid-19 economic shock.

## Methods & Tech Stack

* **Data Engineering:** Automated ETL pipeline harmonizing 5 fragmented databases (IMF WEO, RSF, WGI, Heritage, Transparency International).
* **Dimensionality Reduction (PCA):** Applied Principal Component Analysis to resolve severe multicollinearity ($r>0.85$) among governance indicators, extracting orthogonal institutional dimensions.
* **Econometrics:** Balanced panel ($N=27, T=6$). Models include Pooled OLS and Twoway Fixed Effects (TWFE) with lagged regressors ($t-1$) and country-level clustered standard errors to isolate within-country variation.
* **Stack:** R (`tidyverse`, `fixest`).

## Core Findings

Fixed Effects estimation confirms that structural institutions have low temporal variance and do not drive year-over-year baseline GDP growth in the short term. However, interacting institutional dimensions with the 2020-2021 shock period reveals a statistically significant cushioning effect: countries with stronger baseline governance experienced less severe GDP contractions relative to their peers.

##  Econometric Specification

The core framework maps lagged institutional characteristics against real economic outcomes at time $t$:

$$ \log(\text{GDP per Capita}_{it}) = \alpha_i + \gamma_t + \sum_{k=1}^4 \beta_k PC_{k, i, t-1} \times \text{Covid}_{it} + \varepsilon_{it} $$

Where:
* $\alpha_i$ **(Country Fixed Effects):** Absorbs time-invariant unobserved unit traits (geography, baseline wealth).
* $\gamma_t$ **(Year Fixed Effects):** Absorbs symmetric global macro-shocks.
* $\text{Covid}_{it}$: Indicator variable for the core crisis window (2020–2021).
* $PC_{k, i, t-1}$: Four lagged Principal Components (Broad Governance, Fiscal Scale, Market Openness, Price/Labor Flexibility).

### Model Progression
1. **Pooled OLS Baseline:** Shows a positive return to $PC1$, but is compromised by cross-sectional wealth bias (richer countries naturally correlate with higher governance scores).
2. **Fixed Effects (TWFE):** Controls for time-invariant country characteristics. The main coefficient on lagged $PC1$ drops to statistical insignificance due to institutional stickiness.
3. **Interaction Model:** Interacting institutional components with the Covid-19 dummy isolates the shock-absorbing effect. General governance ($PC1 \times \text{Covid}$), market flexibility ($PC3 \times \text{Covid}$), and labor/price stability ($PC4 \times \text{Covid}$) show statistically significant positive effects against the macroeconomic shock.

This pipeline synthesizes publicly available macroeconomic and institutional data spanning 2018–2023. Raw inputs were extracted from the following institutions:

* **International Monetary Fund (IMF):** Real GDP per Capita (World Economic Outlook Database).
* **World Bank:** Worldwide Governance Indicators (Rule of Law, Government Effectiveness, Political Stability).
* **Heritage Foundation:** Index of Economic Freedom (Property Rights, Tax Burden, Market/Labor Flexibility).
* **Transparency International:** Corruption Perceptions Index (CPI).
* **Reporters Without Borders (RSF):** World Press Freedom Index.
