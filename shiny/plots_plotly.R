# plots_plotly.R ----

# plot_eu_nuts2_scatter() ----
# Scatter: total GDP (x) vs GDP per capita (y) for all EU NUTS2 regions.
# Selected country rendered in its viridis colour; all others in grey.
# Capital regions use a square marker; all others use a circle – for ALL countries.
# Two horizontal reference lines on the Y axis: EU27 average and country average.

plot_eu_nuts2_scatter <- function(df_plot,
                                  list_country,
                                  list_eu,
                                  selected_country,
                                  varx,
                                  vary,
                                  year,
                                  label_x = varx,
                                  label_y = vary) {
  
  # Validate required columns ----
  req_cols <- c("code", "name", "namelat", "capital", varx, vary, "country")
  missing  <- setdiff(req_cols, names(df_plot))
  if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))
  
  # Country colour ----
  country_col <- COUNTRY_COLOURS[selected_country]
  if (is.na(country_col)) country_col <- "#526DB0"
  
  # Reverse COUNTRIES lookup: ISO code -> English name ----
  country_names <- setNames(names(COUNTRIES), COUNTRIES)
  
  # Add English country name column ----
  df_plot$country_name <- country_names[df_plot$country]
  
  # Split data ----
  # Other EU: split by capital flag
  df_other       <- df_plot[df_plot$country != selected_country, ]
  df_other_cap   <- df_other[df_other$capital == "Sí", ]
  df_other_nocap <- df_other[df_other$capital != "Sí", ]
  
  # Selected country: split by capital flag
  df_country <- df_plot[df_plot$country == selected_country, ]
  df_cap     <- df_country[df_country$capital == "Sí", ]
  df_nocap   <- df_country[df_country$capital != "Sí", ]
  
  # Axis ranges for reference lines ----
  x_range <- range(df_plot[[varx]], na.rm = TRUE)
  y_range <- range(df_plot[[vary]], na.rm = TRUE)
  
  # Hover tooltip ----
  make_hover <- function(d) {
    paste0(
      "<b>", d$name, "</b> (", d$code, ") [", d$namelat, "]<br>",
      "Country: ", d$country_name, "<br>",
      label_x, ": ", formatC(d[[varx]], format = "fg", big.mark = ","), "<br>",
      label_y, ": ", formatC(d[[vary]], format = "fg", big.mark = ",")
    )
  }
  
  # Plot layers ----
  fig <- plot_ly()
  
  # Layer 1: other EU regions – non-capitals (grey circles) ----
  if (nrow(df_other_nocap) > 0) {
    fig <- fig %>%
      add_trace(
        data       = df_other_nocap,
        x          = df_other_nocap[[varx]],
        y          = df_other_nocap[[vary]],
        type       = "scatter",
        mode       = "markers",
        name       = "Other EU regions",
        marker     = list(
          color   = COL_OTHER,
          size    = 7,
          symbol  = "circle",
          opacity = 0.6,
          line    = list(width = 0.4, color = "white")
        ),
        text       = make_hover(df_other_nocap),
        hoverinfo  = "text",
        hoverlabel = list(bgcolor = "#555", font = list(color = "white", size = 11))
      )
  }
  
  # Layer 2: other EU regions – capitals (grey squares) ----
  if (nrow(df_other_cap) > 0) {
    fig <- fig %>%
      add_trace(
        data       = df_other_cap,
        x          = df_other_cap[[varx]],
        y          = df_other_cap[[vary]],
        type       = "scatter",
        mode       = "markers",
        name       = "Other EU capitals",
        marker     = list(
          color   = COL_OTHER,
          size    = 9,
          symbol  = "square",
          opacity = 0.8,
          line    = list(width = 0.6, color = "white")
        ),
        text       = make_hover(df_other_cap),
        hoverinfo  = "text",
        hoverlabel = list(bgcolor = "#555", font = list(color = "white", size = 11))
      )
  }
  
  # Layer 3: selected country non-capital regions (coloured circles) ----
  if (nrow(df_nocap) > 0) {
    fig <- fig %>%
      add_trace(
        data       = df_nocap,
        x          = df_nocap[[varx]],
        y          = df_nocap[[vary]],
        type       = "scatter",
        mode       = "markers",
        name       = paste0(selected_country, " regions"),
        marker     = list(
          color   = country_col,
          size    = 9,
          symbol  = "circle",
          opacity = 0.9,
          line    = list(width = 0.6, color = "white")
        ),
        text       = make_hover(df_nocap),
        hoverinfo  = "text",
        hoverlabel = list(bgcolor = country_col, font = list(color = "white", size = 11))
      )
  }
  
  # Layer 4: selected country capital region (coloured square) ----
  if (nrow(df_cap) > 0) {
    fig <- fig %>%
      add_trace(
        data       = df_cap,
        x          = df_cap[[varx]],
        y          = df_cap[[vary]],
        type       = "scatter",
        mode       = "markers",
        name       = paste0(selected_country, " capital"),
        marker     = list(
          color   = country_col,
          size    = 11,
          symbol  = "square",
          opacity = 1,
          line    = list(width = 1.2, color = "white")
        ),
        text       = make_hover(df_cap),
        hoverinfo  = "text",
        hoverlabel = list(bgcolor = country_col, font = list(color = "white", size = 11))
      )
  }
  
  # Horizontal reference lines (Y axis only) ----
  shapes      <- list()
  annotations <- list()
  
  eu_y <- list_eu[[vary]]
  ct_y <- list_country[[vary]]
  
  # EU27 average ----
  if (!is.null(eu_y) && !is.na(eu_y)) {
    shapes <- c(shapes, list(list(
      type  = "line",
      x0 = x_range[1], x1 = x_range[2],
      y0 = eu_y, y1 = eu_y,
      line  = list(color = COL_EU_LINE, width = 1.5, dash = "dot"),
      layer = "below"
    )))
    annotations <- c(annotations, list(list(
      x = x_range[2], y = eu_y,
      text      = paste0("EU avg: ", formatC(eu_y, format = "fg", big.mark = ",")),
      showarrow = FALSE, xanchor = "right", yanchor = "bottom",
      font      = list(color = COL_EU_LINE, size = 10),
      bgcolor   = "rgba(255,255,255,0.7)"
    )))
  }
  
  # Selected country average ----
  if (!is.null(ct_y) && !is.na(ct_y)) {
    shapes <- c(shapes, list(list(
      type  = "line",
      x0 = x_range[1], x1 = x_range[2],
      y0 = ct_y, y1 = ct_y,
      line  = list(color = country_col, width = 1.5, dash = "dash"),
      layer = "below"
    )))
    annotations <- c(annotations, list(list(
      x = x_range[1], y = ct_y,
      text      = paste0(selected_country, " avg: ", formatC(ct_y, format = "fg", big.mark = ",")),
      showarrow = FALSE, xanchor = "left", yanchor = "top",
      font      = list(color = country_col, size = 10),
      bgcolor   = "rgba(255,255,255,0.7)"
    )))
  }
  
  # Layout ----
  fig %>%
    layout(
      plot_bgcolor  = "rgba(0,0,0,0)",
      paper_bgcolor = "rgba(0,0,0,0)",
      title = list(
        text    = paste0("EU NUTS2 GDP Dispersion \u2013 ", year),
        font    = list(size = 16, color = "#222"),
        x       = 0.5,
        xanchor = "center"
      ),
      xaxis = list(
        title    = label_x,
        showline = TRUE, linecolor = "#bbb",
        zeroline = FALSE, showgrid = FALSE,
        ticks    = "outside", tickcolor = "#bbb"
      ),
      yaxis = list(
        title     = label_y,
        showline  = TRUE, linecolor = "#bbb",
        zeroline  = FALSE,
        showgrid  = TRUE, gridcolor = "rgba(0,0,0,0.07)", gridwidth = 1,
        ticks     = "outside", tickcolor = "#bbb"
      ),
      legend = list(
        orientation = "h",
        x = 0, y = -0.15,
        xanchor = "left", yanchor = "top",
        bgcolor     = "rgba(255,255,255,0.7)",
        bordercolor = "#ddd", borderwidth = 1,
        font        = list(size = 12)
      ),
      shapes      = shapes,
      annotations = annotations,
      margin      = list(l = 60, r = 20, t = 70, b = 110, pad = 4),
      autosize    = TRUE,
      hovermode   = "closest"
    ) %>%
    config(
      responsive             = TRUE,
      displayModeBar         = TRUE,
      modeBarButtonsToRemove = list("lasso2d", "select2d"),
      displaylogo            = FALSE
    )
}