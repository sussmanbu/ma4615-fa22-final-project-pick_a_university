#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#==
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#



library(tidyverse)
library(modelr)
library(shiny)

clean_data <- read_csv(here::here("shiny_app/FinalProjectApp/clean_data.csv"))

# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("Predictors of International Student Population at U.S. Universities"),

    # Sidebar with a select input for variables 
    sidebarLayout(
        sidebarPanel(
          selectInput("outcome", label = h3("Outcome"),
                      choices = list("International.Student.Number" = "international_students_max",
                                     "International.Student.Percentage" = "international_students_natlib"), selected = 1),
          
          selectInput("indepvar", label = h3("Predictor"),
                      choices = list("ARWU.World.Rank" = "world_rank_cat_arwu",
                                     "QS.World.Rank" = "world_rank_qs",
                                     "Selectivity" = "selectivity",
                                     "Public.Private" = "type1_all",
                                     "Two-year.Four-year" = "type2_carnegie",
                                     "National.Liberal-Arts" = "type3_natlib",
                                     "Degree.Granting" = "type4_carnegie",
                                     "Enrollment.Profile" = "enrprofile2021_carnegie",
                                     "Urbanization" = "locale_carnegie",
                                     "Campus.Size" = "size_qs",
                                     "Research.Output" = "research_output_qs",
                                     "City.Population.Density" = "city_population_density",
                                     "City.Population" = "city_population",
                                     "City.Land.Area" = "city_land_area",
                                     "Out-of-state.Tuition" = "tuition_kaggle",
                                     "Student.Faculty.Ratio" = "stu_facl_ratio_qs",
                                     "Undergraduate.Enrollment " = "enrollment_kaggle",
                                     "Total.Enrollment" = "enrollment_top120enrollment"), selected = 1)
          
        ),

        # Show outputs in different tabs
        mainPanel(
          
          tabsetPanel(type = "tabs",
                      
                      tabPanel("Plot", plotOutput("plot")), # Boxplot or scatterplot
                      tabPanel("Linear Regression Model Summary", verbatimTextOutput("summary")), # Regression output
                      
          )
        )
    ))

# Define server logic 
server <- function(input, output) {
  
  # Regression output
  output$summary <- renderPrint({
    varclass <- class(unlist(clean_data[,input$indepvar]))
    ifelse(varclass == "numeric",
           fit <- lm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar])),
           fit <- lm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar]) - 1)
           ) 
    summary(fit)
  })
  
  
  # Boxplot output
  output$plot <- renderPlot({
    varclass <- class(unlist(clean_data[,input$indepvar]))
    ifelse(varclass == "numeric",
    plot(
      clean_data %>% 
      add_predictions(lm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar]))) %>% 
      ggplot(aes(x = unlist(clean_data[,input$indepvar]))) +
      geom_point(aes(y = unlist(clean_data[,input$outcome])),
                 alpha = .3,
                 pch=19)+
      geom_line(aes(y = pred),
                color="red")
      ),
    boxplot(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar]),
            ann = FALSE,
            pch=19)
    )
  }, height=600)
}


# Run the application 
shinyApp(ui = ui, server = server)
