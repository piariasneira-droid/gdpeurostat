# server.R ----
server <- function(input, output, session) {
  
  # Reactives ----
  
  df_plot <- reactive({
    req(input$year, input$varx, input$vary)
    
    ds %>%
      filter(
        ano    == !!as.integer(input$year),
        var    %in% !!c(input$varx, input$vary),
        nombre != "Extra-Regio NUTS 2",
        level  == 2L
      ) %>%
      collect() %>%
      pivot_wider(names_from = var, values_from = valor) %>%
      mutate(
        country = substr(code, 1, 2),
        rankx   = rank(-get(input$varx), na.last = "keep", ties.method = "min"),
        ranky   = rank(-get(input$vary), na.last = "keep", ties.method = "min")
      )
  })
  
  list_country <- reactive({
    req(input$year, input$varx, input$vary, input$country)
    
    ds %>%
      filter(
        ano  == !!as.integer(input$year),
        var  %in% !!c(input$varx, input$vary),
        code == !!input$country
      ) %>%
      collect() %>%
      pivot_wider(names_from = var, values_from = valor) %>%
      select(any_of(c(input$varx, input$vary))) %>%
      as.list()
  })
  
  list_eu <- reactive({
    req(input$year, input$varx, input$vary)
    
    ds %>%
      filter(
        ano  == !!as.integer(input$year),
        var  %in% !!c(input$varx, input$vary),
        code == "EU27_2020"
      ) %>%
      collect() %>%
      pivot_wider(names_from = var, values_from = valor) %>%
      select(any_of(c(input$varx, input$vary))) %>%
      as.list()
  })
  
  # Value boxes ----
  
  output$vb_regions <- renderText({
    nrow(df_plot())
  })
  
  output$vb_eu_y <- renderText({
    val <- list_eu()[[input$vary]]
    if (!is.null(val) && !is.na(val)) formatC(val, format = "fg", big.mark = ",") else "N/A"
  })
  
  output$vb_ct_y <- renderText({
    val <- list_country()[[input$vary]]
    if (!is.null(val) && !is.na(val)) formatC(val, format = "fg", big.mark = ",") else "N/A"
  })
  
  output$vb_top <- renderText({
    df  <- df_plot()
    col <- input$vary
    if (!col %in% names(df) || !nrow(df)) return("N/A")
    idx <- which.max(df[[col]])
    paste0(df$nombre[idx], " (", formatC(df[[col]][idx], format = "fg", big.mark = ","), ")")
  })
  
  # Plot title ----
  
  output$plot_title <- renderText({
    x_label <- names(VARS_X)[VARS_X == input$varx]
    y_label <- names(VARS_Y)[VARS_Y == input$vary]
    paste0(y_label, " vs ", x_label, " \u2013 ", input$year)
  })
  
  # Scatter plot ----
  
  output$scatter_plot <- renderPlotly({
    df <- df_plot()
    req(nrow(df) > 0)
    
    x_label <- names(VARS_X)[VARS_X == input$varx]
    if (!length(x_label)) x_label <- input$varx
    y_label <- names(VARS_Y)[VARS_Y == input$vary]
    if (!length(y_label)) y_label <- input$vary
    
    plot_eu_nuts2_scatter(
      df_plot          = df,
      list_country     = list_country(),
      list_eu          = list_eu(),
      selected_country = input$country,
      varx             = input$varx,
      vary             = input$vary,
      year             = input$year,
      label_x          = x_label,
      label_y          = y_label,
      p                = PARA
    )
  })
  
  # Data table ----
  
  output$data_table <- renderDT({
    df      <- df_plot()
    varx    <- input$varx
    vary    <- input$vary
    x_label <- names(VARS_X)[VARS_X == varx]
    y_label <- names(VARS_Y)[VARS_Y == vary]
    if (!length(x_label)) x_label <- varx
    if (!length(y_label)) y_label <- vary
    
    country_names <- setNames(names(COUNTRIES), COUNTRIES)
    
    df_tbl <- df %>%
      mutate(country_name = country_names[country]) %>%
      select(
        Code    = code,
        Region  = nombre,
        Country = country_name,
        Capital = capital,
        Year    = ano,
        all_of(setNames(c(varx, vary), c(x_label, y_label)))
      ) %>%
      arrange(Country, desc(.data[[y_label]]))
    
    datatable(
      df_tbl,
      rownames   = FALSE,
      filter     = "top",
      class      = "hover compact",
      extensions = "Buttons",
      options    = list(
        pageLength = 15,
        scrollX    = TRUE,
        dom        = "Bfrtip",
        buttons    = list(
          list(extend = "csv",   text = "CSV",   className = "btn-dt"),
          list(extend = "excel", text = "Excel", className = "btn-dt")
        ),
        columnDefs = list(
          list(className = "dt-center", targets = c(0, 2, 3, 4))
        ),
        initComplete = JS(paste0(
          "function(settings, json) {",
          "  $('a.btn-dt').css({",
          "    'background-color': '", PARA$col_accent, "',",
          "    'border-color': '", PARA$col_accent, "',",
          "    'color': 'white',",
          "    'font-size': '0.8rem'",
          "  });",
          "}"
        )),
        rowCallback = JS(
          "function(row, data, index) {",
          "  var color = (index % 2 === 0) ? '#ffffff' : '#f8f8f8';",
          "  $(row).css('background-color', color);",
          "  $('td', row).css('background-color', color);",
          "}"
        )
      )
    ) %>%
      formatRound(columns = x_label, digits = 0) %>%
      formatRound(columns = y_label, digits = 1) %>%
      formatStyle(
        columns            = y_label,
        background = styleColorBar(df_tbl[[y_label]], "#18bc9c"),        
        backgroundSize     = "100% 90%",
        backgroundRepeat   = "no-repeat",
        backgroundPosition = "center"
      )
  })
}