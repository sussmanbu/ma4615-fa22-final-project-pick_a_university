#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
# 
#
library(tidyverse)
library(shiny)
df <- read_csv("loan_refusal.csv") %>% 
  pivot_longer(cols = min:hiwhite, names_to = "group", values_to = "reject_rate")

# Define UI for application that draws a histogram
ui <- fluidPage(

  # Application title
  titlePanel("Loan refusal"),

  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput(
        "group",
        "Select groups",
        unique(df$group),
        selected = unique(df$group)[1]
      )
    ),
    # Show a plot of the generated distribution
    mainPanel(
     plotOutput("barPlot")
    )
  )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$barPlot <- renderPlot({
        # show data for  input$group from ui.R
        df %>%
          filter(group %in% input$group) %>% 
          ggplot(aes(y = bank, x = reject_rate, fill = group)) +
          geom_col(position = "dodge")
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
