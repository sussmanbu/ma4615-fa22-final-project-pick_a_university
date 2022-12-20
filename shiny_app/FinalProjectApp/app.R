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
library(htmlwidgets)

load("clean_data.RData")


# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("Predictors of International Student Population at U.S. Universities"),

    # Sidebar with a select input for variables 
    sidebarLayout(
        sidebarPanel(
          selectInput("outcome", label = h3("Select an Outcome"),
                      choices = list("International.Student.Number" = "international_students_max",
                                     "International.Student.Percentage" = "international_students_natlib"), selected = 1),
          
          selectInput("indepvar", label = h3("Select a Predictor"),
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
                      
                      tabPanel("Plot", plotOutput("plot")), 
                      tabPanel("Linear Regression Model Summary", tableOutput("summary")), # Regression output
                      
          )
        )
    ))

# Define server logic 
server <- function(input, output) {
  
  # Plot output
  output$plot <- renderPlot({
    varclass <- class(unlist(clean_data[,input$indepvar]))
    ifelse(varclass == "numeric",
    plot(
      clean_data %>% 
      add_predictions(lm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar]))) %>% 
      ggplot(aes(x = unlist(clean_data[,input$indepvar]))) +
      geom_point(aes(y = unlist(clean_data[,input$outcome])),
                 alpha = .3,
                 position = "jitter")+
      geom_smooth(aes(y = unlist(clean_data[,input$outcome])), se=FALSE)+
      geom_line(aes(y = pred),
                color="red")+
        labs(title="Note: \n x-axis is the values of selected predictor; \n y-axis is the value of selected outcome; \n blue line represents the smoothened line of raw data; \n red line represents the fitted line of linear regression model between the two variables.",
             x=NULL,
             y=NULL)+
        theme_minimal()
      ),
    plot(
      clean_data %>% 
      # group_by(unlist(clean_data[,input$indepvar])) %>%
      # mutate(n=n()) %>% 
      ggplot(aes(x = unlist(clean_data[,input$indepvar]), 
                 y=unlist(clean_data[,input$outcome]))
      ) +
        stat_summary(
          fun = mean,
          fun.min = min,
          fun.max = max,
          geom = "crossbar",
          color = "blue"
        )+
      # geom_boxplot(aes(color = n),
      #             outlier.alpha = .1) +
        geom_point(
          position = "jitter"
        )+
      # scale_fill_viridis_c()+
      labs(title="Note: \n x-axis is the levels of selected predictor; \n y-axis is the value of selected outcome; \n NA refers to missing values of the selected predictor; \n middle line of the crossbar represents the mean outcome value of the given predictor level.",
           x=NULL,
           y=NULL)+
           # color="count of universities")+
      theme_minimal()
    )
    )
  }, height=600)
  
  # Regression output
  output$summary <- renderTable({
    varclass <- class(unlist(clean_data[,input$indepvar]))
    #outtype <- max(unlist(clean_data[,input$outcome]), na.rm = TRUE)
    #ifelse(outtype > 1,
    ifelse(varclass == "numeric",
           fit <- lm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar])),
           fit <- lm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar]) - 1)
           #),
           #ifelse(varclass == "numeric",
           #fit <- glm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar]), family=binomial(), na.action=na.omit),
           #fit <- glm(unlist(clean_data[,input$outcome]) ~ unlist(clean_data[,input$indepvar]) - 1), family=binomial(), na.action=na.omit)
    )
    # summary(fit)
    
     # 
     # fit <- lm(clean_data$international_students_max~clean_data$city_population)
    # #  # 
    object <- summary(fit)[4][[1]]
    #  # 
    # # 
    # rownames(object)
    # object[,"Estimate"]
    # object[,"Pr(>|t|]"]
    
    if(varclass == "numeric"){
      df <- data.frame(
        term = c("intercepts", str_sub(rownames(object)[2], 10)),
        estimate = object[,"Estimate"],
        p.value = object[,"Pr(>|t|)"]
      )}
    
    else{
     df <- data.frame(
       term = str_sub(rownames(object), 37),
       estimate = object[,"Estimate"],
       p.value = object[,"Pr(>|t|)"]
     )}

  
     

      # broom::tidy(fit) %>%
      # select(term, estimate, p.value) %>%
      # mutate(across(where(is.numeric), ~round(., 2))) %>%
      # mutate(term=str_sub(term, 23)) %>%
      # DT::datatable()
  })
  
  
}


# Run the application 
shinyApp(ui = ui, server = server)
