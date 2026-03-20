plot_eu_nuts0_scatter <- function(df_plot,
                                  list_eu,
                                  selected_country,
                                  varx,
                                  vary,
                                  year,
                                  label_x = varx,
                                  label_y = vary,
                                  p       = list()) {
  
  col_other   <- p$col_other
  col_country <- p$col_country
  
  # Validate required columns ----
  req_cols <- c("code", "name", "namelat", varx, vary, "country")
  missing  <- setdiff(req_cols, names(df_plot))
  if (length(missing)) stop("Missing columns: ", paste(missing, collapse = ", "))
  
  # Reverse COUNTRIES lookup: ISO code -> English name ----
  country_names        <- setNames(names(COUNTRIES), COUNTRIES)
  df_plot$country_name <- country_names[df_plot$country]
  
  # Split data ----
  df_other       <- df_plot[df_plot$country != selected_country, ]
  df_country <- df_plot[df_plot$country == selected_country, ]
  
  # Axis ranges for reference lines ----
  x_range <- range(df_plot[[varx]], na.rm = TRUE)
  
  # Hover tooltip ----
  make_hover <- function(d) {
    paste0(
      "<b>", d$name, "</b> (", d$code, ") [", d$namelat, "]<br>",
      "Country: ", d$country_name, "<br>",
      label_x, ": ", formatC(d[[varx]], format = "fg", big.mark = ","), "<br>",
      "Ranking ", label_x, ": ", d$rankx, "<br>",
      label_y, ": ", formatC(d[[vary]], format = "fg", big.mark = ","), "<br>",
      "Ranking ", label_y, ": ", d$ranky
    )
  }
  
  fig <- plot_ly()
  # Layer 1: other countries ----
  if (nrow(df_other) > 0) {
    fig <- fig %>%
      add_trace(
        data       = df_other,
        x          = df_other[[varx]],
        y          = df_other[[vary]],
        type       = "scatter",
        mode       = "markers",
        name       = "Other EU countries",
        legendrank = 2,
        marker     = list(
          color   = col_other,
          size    = 7,
          symbol  = "circle",
          opacity = 1,
          line    = list(width = 0.4, color = col_other)
        ),
        text       = make_hover(df_other),
        hoverinfo  = "text",
        hoverlabel = list(bgcolor = col_other, font = list(color = "white", size = 11))
      )
  }
  
  # Layer 2: selected country  ----
  if (nrow(df_country) > 0) {
    fig <- fig %>%
      add_trace(
        data       = df_country,
        x          = df_country[[varx]],
        y          = df_country[[vary]],
        type       = "scatter",
        mode       = "markers",
        name       = paste0("Other ",selected_country, " regions"),
        legendrank = 2,
        marker     = list(
          color   = col_country,
          size    = 7,
          symbol  = "circle",
          opacity = 1,
          line    = list(width = 0.4, color = col_country)
        ),
        text       = make_hover(df_country),
        hoverinfo  = "text",
        hoverlabel = list(bgcolor = col_country, font = list(color = "white", size = 11))
      )
  }
  
  # Layout ----
  fig %>%
    layout(
      plot_bgcolor  = "rgba(0,0,0,0)",
      paper_bgcolor = "rgba(0,0,0,0)",
      title = list(
        text    = paste0("EU Countries GDP Dispersion \u2013 ", year),
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
        x = 1, y = -0.15,
        xanchor = "right", yanchor = "top",
        bgcolor     = "rgba(255,255,255, 1)",
        borderwidth = 0,
        font        = list(size = 12)
      ),
      margin      = list(l = 60, r = 20, t = 70, b = 110, pad = 4),
      autosize    = TRUE,
      hovermode   = "closest"
    ) %>%
    config(
      responsive             = TRUE,
      displayModeBar         = FALSE,
      modeBarButtonsToRemove = list("lasso2d", "select2d"),
      displaylogo            = FALSE
    )
}