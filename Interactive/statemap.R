library(ggplot2)
library(ggmap)
library(maps)
library(mapdata)

usa <- map_data("usa")
dim(usa)
head(usa)
tail(usa)

ggplot() + geom_polygon(data = usa, aes(x=long, y = lat, group = group)) + 
  coord_fixed(1.3)


library(usmap) #import the package
library(tidyverse)

#Import Data
cleaned_data <- read.csv('Modified_Data.csv')

#This only includes 48 State
state<- cleaned_data %>% group_by(state) %>% summarize(Total = n())
state %>% print( n=56 )

#score_qs
plot_usmap(data = state, values = "Total", color = "red") + 
  scale_fill_continuous(low = "orangered", high = "dark red", name = "Number of School in Each State", label = scales::comma) + 
  labs(title = "US Map", subtitle = "Estimate Number of School in Each State") +
  theme(legend.position = "right")


