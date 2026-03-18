# animated_dispersion.R ----

# Libraries ----
library(arrow)
library(tidyverse)
library(ggrepel)
library(ragg)
library(gifski)

# Config ----
PARQUET_PATH <- "./data/output/gdp_eurostat_nuts2+0.parquet"
OUTPUT_PATH  <- "./output/dispersion_eu_nuts2_animated.gif"

COUNTRY     <- "ES"
VARX        <- "MIO_PPS_EU27_2020"
VARY        <- "PPS_HAB_EU27_2020"
FRAME_DELAY <- 0.8
WIDTH       <- 1000
HEIGHT      <- 680
RES         <- 110

# Spanish region short labels ----
ES_LABELS <- c(
  ES11 = "GAL", ES12 = "AST", ES13 = "CANT",
  ES21 = "PV",  ES22 = "NAV", ES23 = "RIO",
  ES24 = "ARA", ES30 = "MAD", ES41 = "CYL",
  ES42 = "CLM", ES43 = "EXT", ES51 = "CAT",
  ES52 = "VAL", ES53 = "BAL", ES61 = "AND",
  ES62 = "MUR", ES63 = "CEU", ES64 = "MEL",
  ES70 = "CAN"
)

# Colour palette ----
COL_OTHER   <- "#A0B8C8"
COL_EU_LINE <- "#DC5924"
COL_ES      <- "#F5C201"
COL_MADRID  <- "#526DB0"

colour_map <- c("Madrid" = COL_MADRID, "Spain (other)" = COL_ES, "Other EU" = COL_OTHER)
size_map   <- c("Madrid" = 4.5,        "Spain (other)" = 3.5,   "Other EU" = 1.8)
alpha_map  <- c("Madrid" = 1.0,        "Spain (other)" = 0.9,   "Other EU" = 0.55)

# Theme ----
anim_theme <- theme_bw(base_size = 12) +
  theme(
    plot.background    = element_rect(fill = "white", color = NA),
    panel.background   = element_rect(fill = "white", color = NA),
    panel.border       = element_blank(),
    panel.grid.major.x = element_blank(),
    panel.grid.minor   = element_blank(),
    panel.grid.major.y = element_line(color = "#e8e8e8", linewidth = 0.35),
    axis.line          = element_line(color = "#cccccc", linewidth = 0.4),
    axis.ticks         = element_line(color = "#cccccc"),
    plot.title         = element_text(face = "bold", size = 14, hjust = 0.5,
                                      color = "grey10"),
    plot.subtitle      = element_text(size = 10, hjust = 0.5, color = "grey40"),
    plot.caption       = element_text(size = 8,  hjust = 0,   color = "grey55"),
    legend.position    = "bottom",
    legend.background  = element_rect(fill = "white", color = NA),
    legend.key         = element_rect(fill = "white"),
    legend.title       = element_text(face = "bold", size = 9),
    legend.text        = element_text(size = 9),
    plot.margin        = margin(10, 15, 8, 10)
  )

# Read data ----
message("Reading parquet...")
ds <- open_dataset(PARQUET_PATH)

dat_wide <- ds %>%
  filter(
    var    %in% !!c(VARX, VARY),
    nombre != "Extra-Regio NUTS 2",
    level  == 2L
  ) %>%
  collect() %>%
  pivot_wider(names_from = var, values_from = valor) %>%
  filter(!is.na(.data[[VARX]]), !is.na(.data[[VARY]])) %>%
  mutate(
    country     = substr(code, 1, 2),
    region_type = case_when(
      code    == "ES30"  ~ "Madrid",
      country == COUNTRY ~ "Spain (other)",
      TRUE               ~ "Other EU"
    ),
    label_text = if_else(
      country == COUNTRY,
      coalesce(ES_LABELS[code], code),
      NA_character_
    )
  )

# EU27 average per year ----
eu_ref <- ds %>%
  filter(var == !!VARY, code == "EU27_2020") %>%
  collect() %>%
  select(ano, eu_y = valor)

years <- sort(unique(dat_wide$ano))
message("Years: ", paste(years, collapse = ", "))

# Fixed axis limits ----
x_lim <- range(dat_wide[[VARX]], na.rm = TRUE)
y_lim <- range(dat_wide[[VARY]],  na.rm = TRUE)
x_lim <- x_lim + c(-1, 1) * diff(x_lim) * 0.03
y_lim <- y_lim + c(-1, 1) * diff(y_lim) * 0.05

# Frame builder ----
build_frame <- function(yr) {
  
  d    <- dat_wide[dat_wide$ano == yr, ]
  eu_y <- eu_ref$eu_y[eu_ref$ano == yr]
  
  # Spanish subset for labels only ----
  d_es <- d[d$country == COUNTRY, ]
  
  # EU avg label string ----
  eu_label <- paste0("EU avg: ", formatC(eu_y, format = "f", digits = 0, big.mark = ","))
  
  ggplot(d, aes(x = .data[[VARX]], y = .data[[VARY]])) +
    
    # EU reference line ----
  geom_hline(
    yintercept = eu_y,
    color      = COL_EU_LINE,
    linewidth  = 0.55,
    linetype   = "dotted"
  ) +
    
    # EU avg label – NO fontface, plain color name ----
  geom_text(
    data        = data.frame(x = x_lim[2], y = eu_y, label = eu_label),
    aes(x = x, y = y, label = label),
    inherit.aes = FALSE,
    hjust       = 1,
    vjust       = -0.45,
    size        = 3,
    color       = COL_EU_LINE
  ) +
    
    # Points ----
  geom_point(
    aes(color = region_type, size = region_type, alpha = region_type),
    shape = 16,
    na.rm = TRUE
  ) +
    
    # Spanish labels ----
  geom_text_repel(
    data        = d_es,
    aes(x = .data[[VARX]], y = .data[[VARY]], label = label_text),
    inherit.aes = FALSE,
    color       = "grey20",
    size        = 2.6,
    box.padding        = 0.4,
    point.padding      = 0.25,
    force              = 2.5,
    max.overlaps       = Inf,
    show.legend        = FALSE,
    segment.color      = "grey75",
    segment.size       = 0.25,
    min.segment.length = 0.2
  ) +
    
    # Scales ----
  scale_color_manual(
    values   = colour_map,
    na.value = "grey80",
    name     = "Region",
    breaks   = c("Madrid", "Spain (other)", "Other EU"),
    labels   = c("Madrid", "Spain - other NUTS2", "Other EU NUTS2")
  ) +
    scale_size_manual( values = size_map,  na.value = 1.5, guide = "none") +
    scale_alpha_manual(values = alpha_map, na.value = 0.3, guide = "none") +
    
    scale_x_continuous(
      name   = "Total GDP in PPS 2020 (billions)",
      labels = function(x) formatC(x / 1000, format = "f", digits = 0, big.mark = ","),
      limits = x_lim,
      expand = c(0, 0)
    ) +
    scale_y_continuous(
      name   = "GDP per capita in PPS 2020",
      labels = function(x) formatC(x, format = "f", digits = 0, big.mark = ","),
      limits = y_lim,
      expand = c(0, 0)
    ) +
    
    labs(
      title    = paste0("EU NUTS2 GDP Dispersion - ", yr),
      subtitle = "Spain highlighted  |  Total GDP (x)  vs  GDP per capita (y)",
      caption  = "Source: Eurostat. Dotted line = EU27 average GDP per capita."
    ) +
    
    anim_theme
}

# Render frames ----
message("Rendering frames...")

tmp_dir   <- file.path(tempdir(), "anim_frames")
dir.create(tmp_dir, showWarnings = FALSE)
png_files <- character(length(years))

for (i in seq_along(years)) {
  yr   <- years[i]
  path <- file.path(tmp_dir, sprintf("frame_%03d.png", i))
  
  agg_png(path, width = WIDTH, height = HEIGHT, res = RES)
  print(build_frame(yr))
  dev.off()
  
  png_files[i] <- path
  message(sprintf("  [%d/%d] %d", i, length(years), yr))
}

# Stitch GIF ----
message("Stitching GIF...")
dir.create(dirname(OUTPUT_PATH), showWarnings = FALSE, recursive = TRUE)

gifski(
  png_files = png_files,
  gif_file  = OUTPUT_PATH,
  width     = WIDTH,
  height    = HEIGHT,
  delay     = FRAME_DELAY
)

unlink(tmp_dir, recursive = TRUE)
message("Done! Saved to: ", OUTPUT_PATH)