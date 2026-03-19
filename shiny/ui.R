# ui.R ----
ui <- page_fillable(
  title   = "EU Regional GDP",
  padding = "16px",
  gap     = "16px",
  style   = "background-color: #ffffff !important;",
  theme = bs_theme(
    bootswatch = "flatly",
    primary    = PARA$col_other,
    base_font  = font_google("Inter")
  ),
  
  # CSS ----
  tags$style(HTML(paste0(
    "body, html { background-color: #ffffff; }",
    ".bslib-page-fill { background-color: #ffffff; }",
    ".nav-tabs {",
    "background-color: ", PARA$col_other, ";",
    "padding: 0 16px;",
    "border-bottom: none;",
    "margin-bottom: 0;",
    "border-radius: 0 0 8px 8px;",
    "}",
    ".nav-tabs .nav-link {",
    "color: rgba(255,255,255,0.75);",
    "border: none; border-radius: 0;",
    "padding: 10px 16px;",
    "}",
    ".nav-tabs .nav-link.active {",
    "color: ", PARA$col_country, ";",
    "background-color: transparent;",
    "border-bottom: 3px solid ", PARA$col_country, ";",
    "border-top: none; border-left: none; border-right: none;",
    "}",
    ".nav-tabs .nav-link:hover { color: ", PARA$col_country, "; }",
    ".tab-content { background-color: #ffffff; padding: 16px 0 0 0; }",
    ".header-wrapper {",
    "background-color: ", PARA$col_other, ";",
    "border-radius: 12px;",
    "overflow: hidden;",
    "box-shadow: 0 2px 6px rgba(0,0,0,0.15);",
    "margin-bottom: 0;",
    "}",
    ".selectize-dropdown { z-index: 9999 !important; }",
    ".selectize-dropdown .option {",
    "  padding: 8px 12px !important;",
    "  line-height: 1.5 !important;",
    "}"
  ))),
  
  # Header azul: solo título + tabs (SIN contenido dentro) ----
  tags$div(
    class = "header-wrapper",
    
    tags$div(
      style = "color: white; padding: 12px 16px; font-size: 1.2rem; font-weight: 600; text-align: center;",
      "EU Regional GDP"
    ),
    
    tags$ul(
      class = "nav nav-tabs",
      tags$li(
        class = "nav-item",
        tags$a(class = "nav-link", href = "#tab-nuts0", `data-bs-toggle` = "tab",
               bsicons::bs_icon("globe-europe-africa"), " NUTS0")
      ),
      tags$li(
        class = "nav-item",
        tags$a(class = "nav-link active", href = "#tab-nuts2", `data-bs-toggle` = "tab",
               bsicons::bs_icon("graph-up-arrow"), " NUTS2")
      )
    )
  ),
  
  tags$div(
    class = "tab-content",
    
    tags$div(
      class = "tab-pane fade",
      id    = "tab-nuts0"
    ),
    
    tags$div(
      class = "tab-pane fade show active",
      id    = "tab-nuts2",
      
      layout_columns(
        col_widths = 12,
        fill       = FALSE,
        
        # Controls ----
        card(
          fill    = FALSE,
          padding = "10px 16px",
          style   = paste0("background:", "#F8F8F8", "; border:1px solid ", PARA$col_accent, ";"),
          
          tags$style(HTML(
            ".controls-row { display: flex; align-items: flex-end; gap: 12px; }",
            ".controls-row > div { flex: 1; margin-bottom: 0; }",
            ".controls-row label { font-size: 0.8rem; font-weight: 600; margin-bottom: 4px; display: block; }",
            ".controls-row .selectize-input {",
            "  height: 38px !important; min-height: 38px !important;",
            "  overflow: hidden !important; white-space: nowrap !important;",
            "  text-overflow: ellipsis !important; line-height: 30px !important;",
            "}",
            ".controls-row .selectize-input input { height: 0 !important; }",
            ".controls-row .form-group { margin-bottom: 0 !important; }"
          )),
          
          tags$div(
            class = "controls-row",
            div(selectInput("varx",    "GDP Var",      choices = VARS_X_LABELS, selected = "MIO_PPS_EU27_2020", width = "100%")),
            div(selectInput("vary",    "GDP p.c. Var", choices = VARS_Y_LABELS, selected = "PPS_HAB_EU27_2020", width = "100%")),
            div(selectInput("country", "Country",      choices = COUNTRIES, selected = "ES",             width = "100%"))
          ),
          tags$div(
            class = "controls-row",
            style = "margin-top: 10px;",
            div(sliderInput("year", "Year", min = YEAR_MIN, max = YEAR_MAX,
                            value = YEAR_MAX, step = 1L, sep = "", ticks = TRUE, width = "100%"))
          )
        ),
        
        # Value boxes ----
        layout_columns(
          col_widths = c(3, 3, 3, 3),
          fill       = FALSE,
          
          value_box("NUTS2 regions",   textOutput("vb_regions", inline = TRUE),
                    showcase = bs_icon("map"),                theme = value_box_theme(bg = PARA$col_other,    fg = "white")),
          value_box("EU avg GDP p.c.", textOutput("vb_eu_y",   inline = TRUE),
                    showcase = bs_icon("globe-europe-africa"), theme = value_box_theme(bg = PARA$col_eu_line, fg = "white")),
          value_box("Country avg GDP p.c.", textOutput("vb_ct_y", inline = TRUE),
                    showcase = bs_icon("flag"),               theme = value_box_theme(bg = PARA$col_accent,   fg = "#222")),
          value_box("Top GDP p.c. region",  textOutput("vb_top",  inline = TRUE),
                    showcase = bs_icon("trophy"),             theme = value_box_theme(bg = PARA$col_country,  fg = "#222"))
        ),
        
        # Scatter plot ----
        card(
          full_screen = TRUE,
          card_header(textOutput("plot_title", inline = TRUE), class = "fw-semibold"),
          card_body(padding = "4px", plotlyOutput("scatter_plot", height = "520px"))
        ),
        
        # Data table ----
        card(
          full_screen = TRUE,
          card_header("Region data", class = "fw-semibold"),
          card_body(padding = "8px", DTOutput("data_table"))
        )
      )
    )
  )
)