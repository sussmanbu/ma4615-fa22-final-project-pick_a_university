library(DT)
library(shiny)
library(leaflet) #import the package
library(tidyverse)
library("geojsonio")
source("Map2.R")
library(maps)
library(mapproj)
file = paste(getwd(), "/us-states.geojson", sep = '')
states <- geojsonio::geojson_read("map.geojson", what = "sp")
class(states)
names(states)
bins <- c(0, 10, 20, 30, 40, 50, 60, 70)
pal <- colorBin("YlOrRd", domain = states$density, bins = bins)
labels <- sprintf(
  "<strong>%s</strong><br/> Total: %g schools",
  states$name, states$density
) %>% 
  lapply(htmltools::HTML)

# User interface ----
ui <- basicPage(
  title = "School Data",
  sidebarLayout(
    sidebarPanel(
      checkboxGroupInput("show_vars", "Columns in School Data to Show:",
                        names(clean_data), selected = names(clean_data)),
    ),
    mainPanel(
      tabsetPanel(
        type = "tabs",
        tabPanel("Datatable", DT::dataTableOutput("Datatable")),
        tabPanel("SchoolMap", leafletOutput("SchoolMap")),
      )
    )
  )
)


# Server logic ----
server <- function(input, output) {
  output$Datatable = DT::renderDataTable({
    DT::datatable(clean_data[input$show_vars, drop = FALSE], options = list(orderClasses = TRUE))
  })
  
  output$SchoolMap <- renderLeaflet({
    leaflet(states) %>%
      setView(-96, 37.8, 4) %>%
      addTiles() %>% 
      addPolygons(fillColor = ~pal(density),
                  weight = 3,
                  opacity = 1,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 5, 
                  highlight = highlightOptions(weight = 5,
                                               color = "#666",
                                               dashArray = "",
                                               fillOpacity = 0.7,
                                               bringToFront = TRUE), 
                  label = labels,
                  labelOptions = labelOptions(style = list("font-weight" = "normal", 
                                                           padding = "3px 8px"),
                                              textsize = "15px",
                                              direction = "auto")) %>%
      addLegend(pal = pal, values = ~density, opacity = 0.7, 
                title = NULL, position = "bottomright")
    
  })
  
}

# Run app ----
shinyApp(ui, server)