fetch_eurostat_csv <- function(url) {
  readr::read_csv(url, show_col_types = FALSE, locale = readr::locale(decimal_mark = "."))
}

read_meta <- function(path) {
  list(
    nuts0 = readxl::read_xlsx(path, sheet = "NUTS 0"),
    nuts1 = readxl::read_xlsx(path, sheet = "NUTS 1"),
    nuts2 = readxl::read_xlsx(path, sheet = "NUTS 2"),
    nuts3 = readxl::read_xlsx(path, sheet = "NUTS3")
  )
}

read_eurostat <- function(since = 2000) {
  base <- "https://ec.europa.eu/eurostat/api/dissemination/sdmx/3.0/data/dataflow/ESTAT"
  list(
    pop = fetch_eurostat_csv(glue::glue("{base}/demo_r_d2jan/1.0/*.*.*.*.*?format=csvdata&c[sex]=T&c[age]=TOTAL&c[TIME_PERIOD]=ge:{since}&formatVersion=2.0&compress=false")),
    sur = fetch_eurostat_csv(glue::glue("{base}/demo_r_d3area/1.0/*.*.*.*?format=csvdata&c[landuse]=TOTAL&c[TIME_PERIOD]=ge:{since}&formatVersion=2.0&compress=false")),
    den = fetch_eurostat_csv(glue::glue("{base}/demo_r_d3dens/1.0/*.*.*?format=csvdata&c[TIME_PERIOD]=ge:{since}&formatVersion=2.0&compress=false")),
    gdp = fetch_eurostat_csv(glue::glue("{base}/nama_10r_2gdp/1.0/*.*.*?format=csvdata&c[unit]=MIO_EUR,EUR_HAB,MIO_PPS_EU27_2020,PPS_EU27_2020_HAB,PPS_HAB_EU27_2020&c[TIME_PERIOD]=ge:{since}&formatVersion=2.0&compress=false"))
  )
}