# global.R
# Loaded once at app startup: data, constants and palettes ----

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
# App runs from shiny/, parquet is one level up
ds <- open_dataset("./data/gdp_eurostat_nuts2+0.parquet")

# Constants ----
YEAR_MIN <- 2011L
YEAR_MAX <- 2024L

# X-axis variables ----
VARS_X <- c(
  "GDP (millions EUR)"       = "MIO_EUR",
  "GDP (millions PPS 2020)"  = "MIO_PPS_EU27_2020"
)

# Y-axis variables ----
VARS_Y <- c(
  "GDP per capita (EUR)"          = "EUR_HAB",
  "GDP per capita (PPS 2020)"     = "PPS_EU27_2020_HAB",
  "GDP per capita index (EU=100)" = "PPS_HAB_EU27_2020"
)

# EU countries ----
COUNTRIES <- c(
  "Germany"        = "DE",
  "Italy"          = "IT",
  "France"         = "FR",
  "Poland"         = "PL",
  "Belgium"        = "BE",
  "Bulgaria"       = "BG",
  "Greece"         = "EL",
  "Czechia"        = "CZ",
  "Denmark"        = "DK",
  "Estonia"        = "EE",
  "Ireland"        = "IE",
  "Spain"          = "ES",
  "Croatia"        = "HR",
  "Cyprus"         = "CY",
  "Latvia"         = "LV",
  "Lithuania"      = "LT",
  "Luxembourg"     = "LU",
  "Hungary"        = "HU",
  "Malta"          = "MT",
  "Netherlands"    = "NL",
  "Austria"        = "AT",
  "Portugal"       = "PT",
  "Romania"        = "RO",
  "Slovenia"       = "SI",
  "Slovakia"       = "SK",
  "Finland"        = "FI",
  "Sweden"         = "SE"
)

# Colour palette ----
COL_OTHER   <- "#A0B8C8"   # other EU regions
COL_EU_LINE <- "#DC5924"   # EU reference line
COL_NEUTRAL <- "#7A7A7A"   # country reference line

# One distinct viridis colour per country ----
set.seed(42)
N_COUNTRIES     <- length(COUNTRIES)
COUNTRY_COLOURS <- setNames(
  colorRampPalette(c("#440154","#414487","#2A788E","#22A884","#7AD151","#FDE725"))(N_COUNTRIES),
  COUNTRIES
)