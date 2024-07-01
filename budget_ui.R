##### Necessary packages. #####
if(!require(DT)) { install.packages("DT")}
library(shiny)
if(!require(shinyjs)) { install.packages("shinyjs")}
if(!require(shinyWidgets)) { install.packages("shinyWidgets")}
library(tidyverse)
if(!require(writexl)) { install.packages("writexl")}



##### Creating the app. #####
# Define UI for application that creates an interactive budget. 
ui <- fluidPage(
  
  # Application title.
  titlePanel(h1("50-30-20 Interactive Budget", align = "center")),
  
  # Sidebar with fields for income and transaction information and buttons to
  # reset, add, remove, or download information.
  sidebarLayout(
    sidebarPanel(
      shinyjs::useShinyjs(),
      id = "side_panel",
      
      shinyWidgets::autonumericInput(
        "inc",
        "Enter your monthly income:",
        min = 0,
        value = "",
        decimalPlaces = 2
      ),
      actionButton("button", "Reset Monthly Income"),
      
      tableOutput("table1"),
      tags$hr(),
      
      dateInput(
        "date", 
        "Enter the transaction date:", 
        format = "mm-dd-yyyy",
        value = "06-25-2024"
      ),
      textInput("desc", "Enter the transaction description:"),
      selectInput(
        "type",
        "Select the transaction category:",
        choices = c("Bills", "Discretionary", "Savings")
      ),
      shinyWidgets::autonumericInput(
        "amt",
        "Enter the transaction amount:",
        min = 0,
        value = 0.00,
        decimalPlaces = 2
      ),
      
      actionButton("button2", "Reset Transaction Information"),
      actionButton("button3", "Add Information to Table"),
      actionButton("button4", "Remove Previous Row"),
      downloadButton("download","Download Tables")
    ),
    
    # Display an explanation of the budget and display the transaction table.
    mainPanel(
      p(
        "The 50-30-20 budget divides monthly income into categories of 50% of 
      income for bills and fixed expenses, 30% for discretionary purchases, and 
      20% for savings. Please enter your monthly income and the transaction 
      date, description, type (Bills, Discretionary, or Savings), and amount 
      below. The app will calculate each category's starting and remaining 
      monthly balance. Resetting the app will clear all information. Please
      fill out all information before downloading."
      ),
      
      DT::DTOutput("table2")
    )
  )
)