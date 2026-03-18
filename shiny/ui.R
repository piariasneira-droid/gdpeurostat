# ui.R ----
ui <- page_navbar(
  title    = "EU Regional GDP",
  theme    = bs_theme(
    bootswatch = "flatly",
    primary    = "#526DB0",
    base_font  = font_google("Inter")
  ),
  fillable = TRUE,
  
  # Tab 1: GDP dispersion scatter ----
  nav_panel(
    title = "GDP Dispersion",
    icon  = bs_icon("graph-up-arrow"),
    
    layout_columns(
      col_widths = 12,
      fill       = FALSE,
      
      # Top control panel ----
      card(
        fill    = FALSE,
        padding = "10px 16px",
        style   = "background:#f0f3f9; border:1px solid #d0d8ec;",
        
        layout_columns(
          col_widths = c(3, 2, 2, 2, 3),
          gap        = "12px",
          
          # Year slider ----
          div(
            sliderInput(
              inputId = "year",
              label   = "Year",
              min     = YEAR_MIN,
              max     = YEAR_MAX,
              value   = YEAR_MAX,
              step    = 1L,
              sep     = "",
              ticks   = TRUE,
              width   = "100%"
            )
          ),
          
          # X-axis variable ----
          div(
            selectInput(
              inputId  = "varx",
              label    = "X axis \u2013 Total GDP",
              choices  = VARS_X,
              selected = "MIO_PPS_EU27_2020",
              width    = "100%"
            )
          ),
          
          # Y-axis variable ----
          div(
            selectInput(
              inputId  = "vary",
              label    = "Y axis \u2013 GDP per capita",
              choices  = VARS_Y,
              selected = "PPS_HAB_EU27_2020",
              width    = "100%"
            )
          ),
          
          # Country selector ----
          div(
            selectInput(
              inputId  = "country",
              label    = "Highlight country",
              choices  = COUNTRIES,
              selected = "ES",
              width    = "100%"
            )
          ),
          
          # Visual legend ----
          div(
            style = "padding-top:24px; font-size:0.78rem; color:#444; line-height:1.7;",
            tags$span(
              tags$span(style = "display:inline-block;width:12px;height:12px;
                                  border-radius:50%;background:#A0B8C8;
                                  vertical-align:middle;margin-right:4px;"),
              "Other EU regions"
            ), tags$br(),
            tags$span(
              tags$span(style = "display:inline-block;width:12px;height:12px;
                                  border-radius:50%;background:#526DB0;
                                  vertical-align:middle;margin-right:4px;"),
              "Selected country"
            ), tags$br(),
            tags$span(
              tags$span(style = "display:inline-block;width:12px;height:12px;
                                  background:#526DB0;
                                  vertical-align:middle;margin-right:4px;"),
              "Capital region (square)"
            ), tags$br(),
            tags$span(
              tags$span(style = "display:inline-block;width:22px;height:2px;
                                  background:#DC5924;vertical-align:middle;
                                  margin-right:4px;"),
              "EU average (Y)"
            )
          )
        ) # end layout_columns controls
      ),  # end controls card
      
      # Value boxes ----
      layout_columns(
        col_widths = c(3, 3, 3, 3),
        fill       = FALSE,
        
        value_box(
          title    = "NUTS2 regions",
          value    = textOutput("vb_regions", inline = TRUE),
          showcase = bs_icon("map"),
          theme    = "primary"
        ),
        value_box(
          title    = "EU avg GDP p.c.",
          value    = textOutput("vb_eu_y", inline = TRUE),
          showcase = bs_icon("globe-europe-africa"),
          theme    = value_box_theme(bg = "#DC5924", fg = "white")
        ),
        value_box(
          title    = "Country avg GDP p.c.",
          value    = textOutput("vb_ct_y", inline = TRUE),
          showcase = bs_icon("flag"),
          theme    = "secondary"
        ),
        value_box(
          title    = "Top GDP p.c. region",
          value    = textOutput("vb_top", inline = TRUE),
          showcase = bs_icon("trophy"),
          theme    = value_box_theme(bg = "#F5C201", fg = "#222")
        )
      ),
      
      # Scatter plot ----
      card(
        full_screen = TRUE,
        card_header(
          textOutput("plot_title", inline = TRUE),
          class = "fw-semibold"
        ),
        card_body(
          padding = "4px",
          plotlyOutput("scatter_plot", height = "520px")
        )
      ),
      
      # Data table ----
      card(
        full_screen = TRUE,
        card_header("Region data", class = "fw-semibold"),
        card_body(
          padding = "8px",
          DTOutput("data_table")
        )
      )
      
    ) # end outer layout_columns
  )   # end nav_panel
  
  # Additional tabs can be added here with nav_panel(...)
)