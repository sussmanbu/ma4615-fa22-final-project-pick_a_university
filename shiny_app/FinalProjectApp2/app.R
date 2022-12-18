#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

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

# User interface ----
ui <- fluidPage(
  titlePanel("Pick A University"),
  mainPanel(leafletOutput("map"))
  
)

# Server logic ----
server <- function(input, output) {
  bins <- c(0, 10, 20, 30, 40, 50, 60, 70)
  pal <- colorBin("YlOrRd", domain = states$density, bins = bins)
  labels <- sprintf(
    "<strong>%s</strong><br/> Total: %g schools",
    states$name, states$density
  ) %>% 
    lapply(htmltools::HTML)
  output$map <- renderLeaflet({
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
    
  })}

# Run app ----
shinyApp(ui, server)
