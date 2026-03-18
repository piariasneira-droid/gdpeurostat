# Load environment ----
library(readxl)
library(tidyverse)
library(data.table)
library(glue)
library(arrow)

source("./scr/aux/funcread.R")
source("./scr/parameters.R")

# Read data ----
metanuts <- read_meta(path = parameters$path_nuts)
eurostat <- read_eurostat(since = parameters$year_eurostat)

# Transform gdp data ----
## Nuts 2 ----
df_gdpn2 <- eurostat$gdp[
  TIME_PERIOD >= parameters$year_0 &
    nchar(geo) == 4 &
    substr(geo, 1, 2) %in% unique(metanuts$nuts0$NUTS0_Code),
  .(
    var = unit,
    ano = TIME_PERIOD,
    geo = geo,
    valor = OBS_VALUE
  )
]

# Join with meta
df_gdpn2f <- metanuts$nuts2[
  df_gdpn2, 
  on = .(NUTS2_Code = geo)
][, .(
  code    = NUTS2_Code, 
  name    = NUTS2_Name, 
  namelat = NUTS2_Namelatino, 
  nombre  = NUTS2_Nombre, 
  capital = Capital,
  ano, 
  var, 
  valor,
  level = 2L
)]

## Nuts 1 ----
df_gdpn1 <- eurostat$gdp[
  TIME_PERIOD >= parameters$year_0 & 
    nchar(geo) == 3 & 
    substr(geo, 1, 2) %in% unique(metanuts$nuts0$NUTS0_Code), 
  .(
    var = unit,
    ano = TIME_PERIOD,
    geo = geo,
    valor = OBS_VALUE
  )
]

# Join with meta
df_gdpn1f <- metanuts$nuts1[
  df_gdpn1, 
  on = .(NUTS1_Code = geo)
][, .(
  code    = NUTS1_Code, 
  name    = NUTS1_Name, 
  namelat = NUTS1_Namelatino, 
  nombre  = NUTS1_Nombre, 
  ano, 
  var, 
  valor,
  level = 1L
)]

## Nuts 0 ----
df_gdpn0 <- eurostat$gdp[
  TIME_PERIOD >= parameters$year_0 &
  geo %in% unique(metanuts$nuts0$NUTS0_Code),
  .(
    var = unit,
    ano = TIME_PERIOD,
    geo = geo,
    valor = OBS_VALUE
  )
]

df_gdpn0f <- metanuts$nuts0[
  df_gdpn0, 
  on = .(NUTS0_Code = geo)
][, .(
  code    = NUTS0_Code, 
  name    = NUTS0_Name, 
  namelat = NUTS0_Namelatino, 
  nombre  = NUTS0_Nombre, 
  ano, 
  var, 
  valor,
  level = 0L
)]

## EU ----
df_gdpneu <- eurostat$gdp[
  TIME_PERIOD >= parameters$year_0 &
    geo == "EU27_2020",
  .(
    var = unit,
    ano = TIME_PERIOD,
    code = geo,
    valor = OBS_VALUE,
    name    = "European Union", 
    namelat = "European Union", 
    nombre  = "Unión Europea",
    level   = 9L
  )
]

# Save final dataframe
df <- rbindlist(list(df_gdpn2f, df_gdpn0f, df_gdpneu),
                use.names = TRUE, fill = TRUE)

write_parquet(df, sink = parameters$path_parquet)
