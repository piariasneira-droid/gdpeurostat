# Environment ----
library(arrow)
library(tidyverse)
library(bsicons)

ds <- open_dataset("./data/output/gdp_eurostat_nuts2+0.parquet")
country <- "ES"
year <- 2024L
varx <- "MIO_PPS_EU27_2020"
vary <- "PPS_HAB_EU27_2020"

df_plot <- ds %>%
  filter(
    ano == !!year,
    var %in% !!c(varx, vary),
    nombre != "Extra-Regio NUTS 2",
    level == 2L
  ) %>% 
  collect() %>%
  pivot_wider(names_from = var, values_from = valor) %>%
  mutate(
    country = substr(code, 1, 2)
  )

list_country <- ds %>%
  filter(
    ano == !!year,
    var %in% !!c(varx, vary),
    code == !!country
  ) %>%
  collect() %>%
  pivot_wider(names_from = var, values_from = valor) %>%
  select(!!varx, !!vary) %>%
  as.list()

list_eu <- ds %>%
  filter(
    ano == !!year,
    var %in% !!c(varx, vary),
    code == "EU27_2020"
  ) %>%
  collect() %>%
  pivot_wider(names_from = var, values_from = valor) %>%
  select(!!varx, !!vary) %>%
  as.list()
