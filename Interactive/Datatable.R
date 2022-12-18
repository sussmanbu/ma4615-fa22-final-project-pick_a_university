library(DT)
library(shiny)

# User interface ----
ui <- basicPage(
  title = "School Data",
  sidebarLayout(
    sidebarPanel(
      conditionalPanel(
        'input.dataset === "Datatable"',
        checkboxGroupInput("show_vars", "Columns in School Data to Show:",
                           names(clean_data), selected = names(clean_data))
      ),
    ),
    mainPanel(
      tabsetPanel(
        id = 'dataset',
        tabPanel("Datatable", DT::dataTableOutput("Datatable")),
      )
    )
  )
)


# Server logic ----
server <- function(input, output) {
  output$Datatable = DT::renderDataTable({
    DT::datatable(clean_data[input$show_vars, drop = FALSE], options = list(orderClasses = TRUE))
  })
  
}

# Run app ----
shinyApp(ui, server)