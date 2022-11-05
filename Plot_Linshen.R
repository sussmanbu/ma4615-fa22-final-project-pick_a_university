library(tidyverse)
path<- "/Users/lionel/Desktop/ma4615-fa22-final-project-pick_a_university"
data_cleaned <- read.csv("full_data_clean2.csv")

undergraduate_number<- data_cleaned %>% 
  group_by(state) %>% 
  summarise( mean_undergraduate_number = mean (enrollment_kaggle, na.rm = TRUE))

undergraduate_number %>% ggplot(aes(x=reorder(state,mean_undergraduate_number),y=mean_undergraduate_number))+
  geom_col(position = "dodge", fill= "steelblue", na.rm = FALSE)+
  scale_x_discrete(guide=guide_axis(n.dodge=3)) +
  labs(x="state",
       y= "mean of undergraduate enrollment",
       title = "Mean Number of Undergraduate Enrollment in States ")

Tuition_private <- data_cleaned %>% filter(type1_all == "2")
Tuition_private %>% ggplot(aes(x = national_rank_kaggle, y= tuition_kaggle))+
  geom_point()+
  geom_smooth(method = "lm",se = FALSE)+
  labs(x = "National Rank",
       y = "tuition fee(dollars per year)",
       title= "Tuition Fee of Private University")


Tuition_public <- data_cleaned %>% filter(type1_all == "1")
Tuition_public %>% ggplot(aes(x = national_rank_kaggle, y= tuition_kaggle))+
  geom_point()+
  geom_smooth(method = "lm", se= FALSE)+
  labs(x = "National Rank",
       y = "tuition fee(dollars per year)",
       title= "Tuition Fee of Public University")



