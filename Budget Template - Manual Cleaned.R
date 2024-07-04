# The 50-30-20 budget is a method that reserves 50% of income for bills and
# fixed expenses, 30% of income for discretionary expenses, and 20% of income
# for savings. The first table takes user input of the date, description, type 
# (Bills, Discretionary, or Savings), and amount of the transaction. The second 
# table calculates the starting and remaining balances by transaction type.

# For further consideration: Create a user interface using the shiny package.  
# Incorporate machine-learning techniques to automatically assign classes for 
# each transaction. 

##### Necessary packages. #####
library(tidyverse)

# Check for formattable package; install if missing.
if(!require(formattable)) { install.packages("formattable")}
if(!require(writexl)) { install.packages("writexl")}



##### Create a 50-30-20 budget using tidyverse.#####
# Provide monthly income.
income <- 1832

# Create a table for transaction data. 
transactions <- tibble(
  Date = mdy(), 
  Description = character(), 
  Type = character(), 
  Amount = numeric()
  ) 

# Add data to transaction table.

# NOTE: The first row must be entered using the format
# transactions[1, ] <- list(). Everything else can be added by using the list
#  or transactions %>% add_row() functions. 
transactions[1, ] <- list(mdy("06-21-2024"), "boba", "Discretionary", 611.66)
transactions[2, ] <- list(mdy("05-22-2024"), "car payment", "Bills", 80.00)
transactions[3, ] <- list(mdy("03-11-2024"), "deposit", "Savings", 50.00)
transactions[4, ] <- list(mdy("02-11-2023"), "credit card", "Bills", 47.99)

# Create a summary table of transaction totals by type.
budget <- transactions %>% 
  group_by(Type) %>% 
  summarize(Total = sum(Amount)) %>%
  mutate(
    `Starting Balance` = c(income * 0.5, income * 0.3, income * 0.2),
    `Remaining Balance` = `Starting Balance` - Total
  )

# Make balance columns default to two decimal places.
budget$`Starting Balance` <- formattable::comma(budget$`Starting Balance`, digits = 2)



##### Write tables to Excel file sheets. #####
#writexl::write_xlsx(list(transactions, budget), "budget.xlsx")