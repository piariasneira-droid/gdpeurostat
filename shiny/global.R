# global.R
# Libraries ----
library(shiny)
library(bslib)
library(bsicons)
library(plotly)
library(arrow)
library(tidyverse)
library(data.table)
library(DT)

source("./plots_plotly.R")

# Data ----
ds <- open_dataset("./data/gdp_eurostat_nuts2+0.parquet")

# Constants ----
YEAR_MIN <- 2011L
YEAR_MAX <- 2024L

VARS_X <- c(
  "GDP (millions EUR)"      = "MIO_EUR",
  "GDP (millions PPS 2020)" = "MIO_PPS_EU27_2020"
)

VARS_Y <- c(
  "GDP per capita (EUR)"          = "EUR_HAB",
  "GDP per capita (PPS 2020)"     = "PPS_EU27_2020_HAB",
  "GDP per capita index (EU=100)" = "PPS_HAB_EU27_2020"
)

VARS_X_LABELS <- c(
  "M€ nominal"  = "MIO_EUR",
  "M€ PPS 2020" = "MIO_PPS_EU27_2020"
)

VARS_Y_LABELS <- c(
  "€ p.c."         = "EUR_HAB",
  "PPS p.c."       = "PPS_EU27_2020_HAB",
  "Index EU=100"   = "PPS_HAB_EU27_2020"
)

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

# Colour palette ----
PARA <- list(
  col_other   = "#526DB0",
  col_eu_line = "#7A7A7A",
  col_country = "#FCC201",
  col_accent  = "#A0B8C8",
  col_accent2 = "#18bc9c"
)