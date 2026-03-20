# pruebas.R ----

library(arrow)
library(tidyverse)
library(plotly)
library(DT)

source("./shiny/fun/plots_plotly.R")

# Constants ----

COUNTRIES <- c(
  "Germany"     = "DE", "Italy"       = "IT", "France"      = "FR",
  "Poland"      = "PL", "Belgium"     = "BE", "Bulgaria"    = "BG",
  "Greece"      = "EL", "Czechia"     = "CZ", "Denmark"     = "DK",
  "Estonia"     = "EE", "Ireland"     = "IE", "Spain"       = "ES",
  "Croatia"     = "HR", "Cyprus"      = "CY", "Latvia"      = "LV",
  "Lithuania"   = "LT", "Luxembourg"  = "LU", "Hungary"     = "HU",
  "Malta"       = "MT", "Netherlands" = "NL", "Austria"     = "AT",
  "Portugal"    = "PT", "Romania"     = "RO", "Slovenia"    = "SI",
  "Slovakia"    = "SK", "Finland"     = "FI", "Sweden"      = "SE"
)
country_names <- setNames(names(COUNTRIES), COUNTRIES)


VARS_X <- c(
  "GDP (millions EUR)"      = "MIO_EUR",
  "GDP (millions PPS 2020)" = "MIO_PPS_EU27_2020"
)

VARS_Y <- c(
  "GDP per capita (EUR)"          = "EUR_HAB",
  "GDP per capita (PPS 2020)"     = "PPS_EU27_2020_HAB",
  "GDP per capita index (EU=100)" = "PPS_HAB_EU27_2020"
)

# Parameters ----

country <- "ES"
year    <- 2024L
varx    <- "MIO_PPS_EU27_2020"
vary    <- "PPS_HAB_EU27_2020"

x_label <- names(VARS_X)[VARS_X == varx]
y_label <- names(VARS_Y)[VARS_Y == vary]

para <- list(
  col_other   = "#526DB0",
  col_eu_line = "#7A7A7A",
  col_country = "#FCC201",
  col_accent  = "#A0B8C8"
)

# Load data ----
ds <- open_dataset("./data/output/gdp_eurostat_nuts2+0.parquet")

df_plot <- ds %>%
  filter(
    ano    == !!year,
    var    %in% !!c(varx, vary),
    level  == 0L
  ) %>%
  collect() %>%
  pivot_wider(names_from = var, values_from = valor) %>%
  mutate(country = substr(code, 1, 2),
         rankx   = rank(-get(varx), na.last = "keep", ties.method = "min"),
         ranky   = rank(-get(vary), na.last = "keep", ties.method = "min")
  )

list_eu <- ds %>%
  filter(
    ano  == !!year,
    var  %in% !!c(varx, vary),
    code == "EU27_2020"
  ) %>%
  collect() %>%
  pivot_wider(names_from = var, values_from = valor) %>%
  select(all_of(c(varx, vary))) %>%
  as.list()

# Scatter plot ----
fig <- plot_eu_nuts0_scatter(
  df_plot          = df_plot,
  list_eu          = list_eu,
  selected_country = country,
  varx             = varx,
  vary             = vary,
  year             = year,
  label_x          = x_label,
  label_y          = y_label,
  p                = para
)