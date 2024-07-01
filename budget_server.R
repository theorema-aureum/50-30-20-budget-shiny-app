# Define server logic required to render fields, buttons, and tables.
server <- function(input, output, session) {
  
  # Start with creating the transaction table (table2) and then assign buttons.
  xyTable <- reactiveVal(
    tibble(
      Date = ymd(), 
      Description = character(), 
      Category = character(), 
      Amount = numeric()
    ) 
  )
  
  # Add rows of transaction data. Remove most-recent row if mistake.
  observeEvent(input$button3, {
    xyTable() %>%
      add_row(
        Date = input$date,
        Description = input$desc,
        Category = input$type,
        Amount = input$amt
      ) %>%
      xyTable()
    }
  )
  
  observeEvent(input$button4,{ xyTable() %>% filter(row_number() < n()) %>% xyTable()})
  
  # Render the table and change date format.
  output$table2 <- DT::renderDT(
    {
      xyTable() %>% 
        mutate(Date = format(Date, "%m-%d-%Y")) %>%
        DT::datatable() %>%
        DT::formatRound(columns = "Amount", digits = 2)
    }
  )  
  
  # Assign functions to the buttons used for table2 (transactions). Reset monthly
  # income and reset transaction information.
  observeEvent(input$button, {shinyjs::reset("inc")})
  
  observeEvent(input$button2,{
    updateDateInput(session, "date", value = "06-25-2024")
    updateTextInput(session, "desc", value = "")
    updateSelectInput(session, "type", choices = c("Bills", "Discretionary", "Savings"))
    updateAutonumericInput(session, "amt", value = 0.00)
    }
  )
  
  # Create the budget table (table1).
  xyTable2 <- reactiveVal(
    tibble(
      Category = c("Bills", "Discretionary", "Savings"),
      `Starting Balance` = c(num(0, digits = 2), num(0, digits = 2), num(0, digits = 2)),
      `Remaining Balance` = c(num(0, digits = 2), num(0, digits = 2), num(0, digits = 2))
    )
  ) 
  
  # Update balance columns based on the monthly income input for the 50/30/20 split.
  observeEvent(input$inc, {
    xyTable2() %>% 
      mutate(
        `Starting Balance` = c(input$inc * 0.5, input$inc * 0.3, input$inc * 0.2),
        `Remaining Balance` = c(input$inc * 0.5, input$inc * 0.3, input$inc * 0.2)
      ) %>%
      xyTable2()
    }
  )
  
  # Update balance columns by making a grouped summary of transaction totals and
  # and joining it to table1. This should update for added and removed rows.
  observeEvent(input$button3, {
    temp <- xyTable() %>%
      group_by(Category) %>%
      summarize(Total = sum(Amount))
    
    xyTable2() %>%
      left_join(temp, by = "Category") %>%
      mutate(`Remaining Balance` = `Starting Balance` - Total) %>%
      select(-Total) %>%
      mutate(`Remaining Balance` = case_when(
        Category == "Bills" & is.na(`Remaining Balance`) == TRUE         ~ input$inc * 0.5,
        Category == "Discretionary" & is.na(`Remaining Balance`) == TRUE ~ input$inc * 0.3,
        Category == "Savings" & is.na(`Remaining Balance`)               ~ input$inc * 0.2,
        .default = `Remaining Balance`
        )
      ) %>%
      xyTable2()
    }
  )
  
  observeEvent(input$button4, {
    temp <- xyTable() %>%
      group_by(Category) %>%
      summarize(Total = sum(Amount))
    
    xyTable2() %>%
      left_join(temp, by = "Category") %>%
      mutate(`Remaining Balance` = `Starting Balance` - Total) %>%
      select(-Total) %>%
      mutate(`Remaining Balance` = case_when(
        Category == "Bills" & is.na(`Remaining Balance`) == TRUE         ~ input$inc * 0.5,
        Category == "Discretionary" & is.na(`Remaining Balance`) == TRUE ~ input$inc * 0.3,
        Category == "Savings" & is.na(`Remaining Balance`)               ~ input$inc * 0.2,
        .default = `Remaining Balance`
        )
      ) %>%
      xyTable2()
    }
  ) 
  
  # Render the table.
  output$table1 <- renderTable({xyTable2()})
  
  # Use the download button to write tables to Excel file for local download.
  output$download <- downloadHandler(
    filename = function() {
      paste0("50-30-20", month(Sys.Date(), label = TRUE), year(Sys.Date()), ".xlsx")
    },
    content = function(file) {
      # Write workbook and add transaction table (table2) as the first sheet.
      xlsx::write.xlsx(xyTable(), file, sheetName = "Transactions", append = FALSE)
      
      # Add the budget table (table1) as the second sheet.
      xlsx::write.xlsx(xyTable2(), file, sheetName = "Budget", append = TRUE)
    }
  )
}

# Run the application.
shinyApp(ui = ui, server = server)