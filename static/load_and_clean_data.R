
### Initial Cleaning


# Our initial data cleaning for each data subset included loading each data set, checking for problems, as well as selecting, arranging, and renaming relevant variables.


suppressMessages({
library(tidyverse)
library(readxl)
library(here)
})


# The arwu dataset
arwu2018 <- read_delim(here::here("dataset/arwu-usa-2018.csv"), 
                       delim = ";", 
                       escape_double = FALSE, 
                       trim_ws = TRUE)

problems(arwu2018)

arwu2018 <- arwu2018 %>% 
  select(University, `Total score`, `World rank`, `World rank integer`, `National rank`, `N&S`, `Hi Ci`, Alumni, Award, PUB, PCP) %>% 
  rename(university = University,
         total_score_arwu = `Total score`, 
         world_rank_cat_arwu = `World rank`, 
         world_rank_arwu = `World rank integer`, 
         national_rank_arwu = `National rank`, 
         n_s_arwu = `N&S`, 
         hi_ci_arwu = `Hi Ci`, 
         alumni_arwu = Alumni, 
         award_arwu = Award, 
         pub_arwu = PUB, 
         pcp_arwu = PCP)


# The qs dataset
qs2022 <- read_csv(here::here("dataset/qs_world_university_ranking_2022.csv"))
  
problems(qs2022)

qs2022 <- qs2022 %>% 
  select(university, size, type, city, score, rank_display, research_output, faculty_count, student_faculty_ratio, international_students) %>% 
  rename(size_qs = size, 
         type1_qs = type, 
         score_qs = score, 
         world_rank_qs = rank_display, 
         research_output_qs = research_output, 
         faculty_count_qs = faculty_count, 
         stu_facl_ratio_qs = student_faculty_ratio, 
         international_students_qs = international_students)


# The selectivity dataset
selectivity <- read_excel(here::here("dataset/Selectivity rank.xlsx"))
  
problems(selectivity)

selectivity <- selectivity %>% 
  rename(university = `Institution Name`, 
         state = State, 
         selectivity = Selectivity)


# The city_population_density dataset
city_population_density2016 <- read_csv(here::here("dataset/US Population Density.csv"))

problems(city_population_density2016)

city_population_density2016 <- city_population_density2016 %>% 
  rename(city = City, 
         state = State, 
         city_population_density = `Population Density (Persons/Square Mile)`, 
         city_population = `2016 Population`, 
         city_land_area = `Land Area (Square Miles)`)


# The opendoors dataset
opendoors_2021SY <- read_csv(here::here("dataset/OpendoorsPopulation.csv"),
                             skip = 1)

problems(opendoors_2021SY)

opendoors_2021SY <- opendoors_2021SY %>% 
  rename(university = Institutions, 
         city = City, 
         state_opendoors = State,
         international_students_opendoors = `Int'l Students`)


# The kaggle dataset
kagglecolleges <- read_csv(here::here("dataset/Kagglecolleges.csv"))

problems(kagglecolleges)

kagglecolleges <- kagglecolleges %>% 
  rename(national_rank_kaggle = ...1, 
         university = `College Name`, 
         tuition_kaggle = Tuition,
         enrollment_kaggle = `Enrollment Numbers`) %>% 
  mutate(national_rank_kaggle = national_rank_kaggle + 1) 


# The P1_Carnegie dataset
p1_carnegie <- read_csv(here::here("dataset/P1_Carnegie.csv"))

problems(p1_carnegie)

p1_carnegie <- p1_carnegie %>% 
  rename(university = name, 
         state_carnegie = state)


# The top120enrollment2020fall dataset
top120enrollment2020fall <- read_excel(here::here("dataset/total erollment size top120.xls"),
                                       skip = 1)

problems(top120enrollment2020fall)

top120enrollment2020fall <- top120enrollment2020fall %>% 
  select(-Rank) %>% 
  rename(university = Institution, 
         state_top120enrollment = State, 
         type1_top120enrollment = Control,
         type2_top120enrollment = Level,
         enrollment_top120enrollment = TotalEnrollment)


# The nat_lib_uscolleges dataset
nat_lib_uscolleges <- read_excel(here::here("dataset/Nat_Lib_USColleges.xlsx"))

problems(nat_lib_uscolleges)

nat_lib_uscolleges <- nat_lib_uscolleges %>% 
  rename(university = SCHOOL, 
         city = City,
         state_natlib = State, 
         international_students_natlib = INTERNATIONAL,
         type3_natlib = Type)




### Joining eight out of nine data subsets, followed by some cleaning


# After some basic cleaning presented above, we first did a full join of the seven out of nine data sets (excluding the Carnegie Classification data and population density data), which was then left joined with the Carnegie Classification data. 



full_data_leftjoinCarnegie <- arwu2018 %>% 
  full_join(kagglecolleges, by = "university") %>% 
  full_join(nat_lib_uscolleges, by = "university") %>% 
  full_join(opendoors_2021SY, by = "university") %>% 
  full_join(qs2022, by = "university") %>% 
  full_join(selectivity, by = "university") %>% 
  full_join(top120enrollment2020fall, by = "university") %>% 
  left_join(p1_carnegie, by = "university") 

write_csv(full_data_leftjoinCarnegie, file = here::here("dataset/full_data_leftjoinCarnegie.csv"))



# For variables that had multiple columns due to coming from different data sources, such as city and state, we aggregated the information to one column. Initially, The left joined data set had 961 observations, with each row representing a university. Our outcome of interest, international student population, had three datapoints: the percentage in 2021 from US news, the actual number in 2021 from opendoors, and actual number from 2022 from QS but downloaded from Kaggle. We further filtered the dataset to universities which had at least one datapoint out of these three, which resulted in 499 observations. We saved the updated dataset.


## Turn type1_top120enrollment and type1_qs into numeric variable (NOTE: This is just an intermediate step; later in the cleaning, this variable will be turned into factor)
full_data_leftjoinCarnegie <- full_data_leftjoinCarnegie %>% 
  mutate(type1_top120enrollment = ifelse(type1_top120enrollment=="Public", 1, type1_top120enrollment)) %>%
  mutate(type1_top120enrollment = ifelse(type1_top120enrollment=="PrivNp", 2, type1_top120enrollment)) %>%
  mutate(type1_top120enrollment = ifelse(type1_top120enrollment=="PrivFp", 3, type1_top120enrollment)) %>%
  mutate(type1_qs = ifelse(type1_qs=="Public", 1, type1_qs)) %>%
  mutate(type1_qs = ifelse(type1_qs=="Private", 4, type1_qs))

full_data_leftjoinCarnegie$type1_top120enrollment <- as.numeric(full_data_leftjoinCarnegie$type1_top120enrollment)
full_data_leftjoinCarnegie$type1_qs <- as.numeric(full_data_leftjoinCarnegie$type1_qs)


## Only keep one city column (there are four after joining) 
full_data_leftjoinCarnegie1 <- full_data_leftjoinCarnegie %>% 
  filter(!is.na(university)) %>% 
  head(-4) %>% 
  relocate(university, city.x, city.y, city.x.x, city.y.y) %>%
  arrange(is.na(city.x)) %>% 
  mutate(city.x = ifelse(is.na(city.x), city.y, city.x)) %>% 
  mutate(city.x = ifelse(is.na(city.x), city.x.x, city.x)) %>% 
  mutate(city.x = ifelse(is.na(city.x), city.y.y, city.x)) %>% 
  arrange(is.na(city.x)) %>% 
  select(-city.y, -city.x.x, -city.y.y) %>% 
  rename(city = city.x) %>% 
  ## Only keep one state column (there are five after joining)
  relocate(university, city, state, state_natlib, state_opendoors, state_top120enrollment, state_carnegie) %>%
  arrange(is.na(state)) %>% 
  mutate(state = ifelse(is.na(state), state_natlib, state)) %>% 
  mutate(state = ifelse(is.na(state), state_opendoors, state)) %>% 
  mutate(state = ifelse(is.na(state), state_top120enrollment, state)) %>%
  mutate(state = ifelse(is.na(state), state_carnegie, state)) %>%
  arrange(is.na(state)) %>% 
  select(-state_natlib, -state_opendoors, -state_top120enrollment, -state_carnegie) %>% 
  ## Relocate international students population datapoints (there are three)
  relocate(university, city, state, international_students_natlib, international_students_opendoors, international_students_qs) %>%
  ## Filter out if data is misisng on international_students_natlib, international_students_qs, or international_students_opendoors
  filter(!is.na(international_students_natlib) | !is.na(international_students_opendoors) | !is.na(international_students_qs)) 

write_csv(full_data_leftjoinCarnegie1, file = here::here("dataset/full_data_leftjoinCarnegie1.csv"))



### Some manually cleaning directly in the .csv file

# Then, we realized that some universities had multiple observations due to inconsistency use from different sources. For example, Purdue University has three observations: “Purdue University”, “Purdue University–West Lafayette”, and “Purdue University - West Lafayette.”  To solve this issue, we exported the dataset to a .csv file, sorted by university name, and manually de-duplicated the dataset.  More specifically, we identified those universities with multiple observations, filled the information to all observations, and then deleted the duplicate observations to only keep one row. This procedure resulted in 441 observations (reducing from 499 observations), each of which represent a unique university.  We then imported the de-duplicated csv file (`full_data_leftjoinCarnegie1_dedup.csv`) back to R and proceeded to further data cleaning.


full_data_leftjoinCarnegie1_dedup <- read_csv(here::here("dataset/full_data_leftjoinCarnegie1_dedup.csv"))

problems(full_data_leftjoinCarnegie1_dedup)



### Deeper cleaning with the de-duplicated dataset


# This round of deeper cleaning focused on four main areas. First, we combined predictor variables that had multiple data points (such as private or public, 2-year vs 4-year). Second, given that we had two columns (from two sources) on number of international students (which is one of our outcome variables), we combined them by creating a new variable that takes the maximum value of the two original columns. Third, we left joined the dataset with the remaining US city population data, which included variables on the city population, city land area, and city population density in 2016. Fourth, we dealt with the categorical variables, including re-leveling and re-ordering.  
                                
                                
semi_clean_data <- 
  full_data_leftjoinCarnegie1_dedup %>% 
  ## Clean type1 variables (private or public) based on control_carnegie, type1_qs, and type1_top120enrollment
  mutate(type1_all = ifelse(is.na(control_carnegie), type1_top120enrollment, control_carnegie)) %>% 
  mutate(type1_all = ifelse(is.na(type1_all), type1_qs, type1_all)) %>% 
  arrange(type1_all) %>% 
  ## Update the three university with value 4 (private) to 2 (not for profit private)
  mutate(type1_all = ifelse(type1_all==4, 2, type1_all)) %>% 
  ## drop the 3 original type1 variables
  select(-control_carnegie, -type1_qs, -type1_top120enrollment) %>% 
  ## clean other control type variables
  select(-type2_top120enrollment) %>% 
  rename(type2_carnegie = sizeset2021_carnegie,
         type4_carnegie = basic2021_carnegie) %>% 
  ## Create a new variable for international student population so that it takes the maximum value 
  ## from the international_students_qs and international_students_opendoors
  mutate(international_students_max = pmax(international_students_qs, international_students_opendoors, na.rm = TRUE)) %>% 
  ## left join with city_population_density2016
  left_join(city_population_density2016, by = c("city","state")) %>% 
  ## Relocate the variables
  relocate(university, city, state,
           city_population_density, city_population, city_land_area,
           international_students_natlib, international_students_max, international_students_qs, international_students_opendoors, 
           tuition_kaggle,
           selectivity,
           world_rank_cat_arwu, world_rank_arwu, world_rank_qs,
           national_rank_arwu, national_rank_kaggle,
           type1_all,
           type2_carnegie,
           type3_natlib,
           type4_carnegie, enrprofile2021_carnegie,
           locale_carnegie,
           size_qs,
           faculty_count_qs, stu_facl_ratio_qs,
           research_output_qs, award_arwu, hi_ci_arwu, n_s_arwu, pub_arwu,
           pcp_arwu, alumni_arwu,
           enrollment_kaggle, enrollment_top120enrollment,
           total_score_arwu, score_qs) 


## Collapse, label, and reorder levels for categorical variables
clean_data <- semi_clean_data

# selectivity
clean_data$selectivity[clean_data$selectivity == 1] <- "most competitive"
clean_data$selectivity[clean_data$selectivity == 2] <- "highly competitive plus"
clean_data$selectivity[clean_data$selectivity == 3] <- "highly competitive"
clean_data$selectivity[clean_data$selectivity == 4] <- "very competitive plus"

selectivity_levels <- c(
  "most competitive",
  "highly competitive plus",
  "highly competitive",
  "very competitive plus")

clean_data$selectivity <- factor(clean_data$selectivity, levels = selectivity_levels)

clean_data %>% ggplot(aes(x=factor(selectivity)))+geom_bar()


# enrprofile2021_carnegie 
clean_data$enrprofile2021_carnegie[clean_data$enrprofile2021_carnegie == 1 | 
                                     clean_data$enrprofile2021_carnegie == 2 | 
                                     clean_data$enrprofile2021_carnegie == 3] <- "Exclusive/Very high undergraduate"

clean_data$enrprofile2021_carnegie[clean_data$enrprofile2021_carnegie == 4 | 
                                     clean_data$enrprofile2021_carnegie == 5] <- "Majority undergraduate"


clean_data$enrprofile2021_carnegie[clean_data$enrprofile2021_carnegie == 6 | 
                                     clean_data$enrprofile2021_carnegie == 7] <- "Exclusive/Majority graduate"

enrprofile2021_carnegie_levels <- c(
  "Exclusive/Very high undergraduate",
  "Majority undergraduate",
  "Exclusive/Majority graduate")

clean_data$enrprofile2021_carnegie <- factor(clean_data$enrprofile2021_carnegie, levels = enrprofile2021_carnegie_levels)

clean_data %>% ggplot(aes(x=factor(enrprofile2021_carnegie)))+geom_bar()


# type4_carnegie
clean_data$type4_carnegie[clean_data$type4_carnegie == 1 | 
                            clean_data$type4_carnegie == 2 |
                            clean_data$type4_carnegie == 3 |
                            clean_data$type4_carnegie == 4 |
                            clean_data$type4_carnegie == 5 | 
                            clean_data$type4_carnegie == 6 |
                            clean_data$type4_carnegie == 14 ] <- "Associate's Colleges"

clean_data$type4_carnegie[clean_data$type4_carnegie == 15 | 
                            clean_data$type4_carnegie == 16 |
                            clean_data$type4_carnegie == 17 ] <- "Doctoral Universities"

clean_data$type4_carnegie[clean_data$type4_carnegie == 18 | 
                            clean_data$type4_carnegie == 19 |
                            clean_data$type4_carnegie == 20 ] <- "Master's Colleges & Universities"

clean_data$type4_carnegie[clean_data$type4_carnegie == 21 | 
                            clean_data$type4_carnegie == 22 |
                            clean_data$type4_carnegie == 23 ] <- "Baccalaureate Colleges"

clean_data$type4_carnegie[clean_data$type4_carnegie == 24 | 
                            clean_data$type4_carnegie == 25 |
                            clean_data$type4_carnegie == 26 |
                            clean_data$type4_carnegie == 27 |
                            clean_data$type4_carnegie == 28 | 
                            clean_data$type4_carnegie == 29 |
                            clean_data$type4_carnegie == 30 ] <- "Special Focus Four-Year"

type4_carnegie_levels <- c(
  "Doctoral Universities",
  "Master's Colleges & Universities",
  "Baccalaureate Colleges",
  "Special Focus Four-Year",
  "Associate's Colleges")

clean_data$type4_carnegie <- factor(clean_data$type4_carnegie, levels = type4_carnegie_levels)

clean_data %>% ggplot(aes(x=factor(type4_carnegie)))+geom_bar()+scale_x_discrete(guide = guide_axis(n.dodge=2))



# type2_carnegie
clean_data$type2_carnegie[clean_data$type2_carnegie == 3 | 
                            clean_data$type2_carnegie == 4 |
                            clean_data$type2_carnegie == 5 ] <- "Two-year"

clean_data$type2_carnegie[clean_data$type2_carnegie == 6 | 
                            clean_data$type2_carnegie == 7 |
                            clean_data$type2_carnegie == 8 |
                            clean_data$type2_carnegie == 9 |
                            clean_data$type2_carnegie == 10 |
                            clean_data$type2_carnegie == 11 ] <- "Four-year (small)"

clean_data$type2_carnegie[clean_data$type2_carnegie == 12 | 
                            clean_data$type2_carnegie == 13 |
                            clean_data$type2_carnegie == 14 ] <- "Four-year (median)"

clean_data$type2_carnegie[clean_data$type2_carnegie == 15 | 
                            clean_data$type2_carnegie == 16 |
                            clean_data$type2_carnegie == 17 ] <- "Four-year (large)"

type2_carnegie_levels <- c(
  "Four-year (large)",
  "Four-year (median)",
  "Four-year (small)",
  "Two-year")

clean_data$type2_carnegie <- factor(clean_data$type2_carnegie, levels = type2_carnegie_levels)

clean_data %>% ggplot(aes(x=factor(type2_carnegie)))+geom_bar()


# locale_carnegie
clean_data$locale_carnegie[clean_data$locale_carnegie == 11 | 
                             clean_data$locale_carnegie == 12 |
                             clean_data$locale_carnegie == 13 ] <- "city"

clean_data$locale_carnegie[clean_data$locale_carnegie == 21 | 
                             clean_data$locale_carnegie == 22 |
                             clean_data$locale_carnegie == 23 ] <- "suburb"

clean_data$locale_carnegie[clean_data$locale_carnegie == 31 | 
                             clean_data$locale_carnegie == 32 |
                             clean_data$locale_carnegie == 33 |
                             clean_data$locale_carnegie == 41 |
                             clean_data$locale_carnegie == 42 ] <- "town or rural"

locale_carnegie_levels <- c(
  "city",
  "suburb",
  "town or rural")

clean_data$locale_carnegie <- factor(clean_data$locale_carnegie, levels = locale_carnegie_levels)

clean_data %>% ggplot(aes(x=factor(locale_carnegie)))+geom_bar()


# type1_all
clean_data <- clean_data %>% 
  mutate(type1_all = ifelse(type1_all==3, 2, type1_all)) 

clean_data$type1_all[clean_data$type1_all == 1 ] <- "public"
clean_data$type1_all[clean_data$type1_all == 2 ] <- "private"
clean_data$type1_all <- factor(clean_data$type1_all)

clean_data %>% ggplot(aes(x=factor(type1_all)))+geom_bar()


# size_qs
size_levels <- c(
  "S",
  "M",
  "L",
  "XL")

clean_data$size_qs <- factor(clean_data$size_qs, levels = size_levels)

clean_data %>% ggplot(aes(x=factor(size_qs)))+geom_bar()


# research_output_qs
clean_data$research_output_qs[clean_data$research_output_qs == "High" |
                                clean_data$research_output_qs == "Medium" ] <- "Medium High"

clean_data$research_output_qs <- factor(clean_data$research_output_qs)

clean_data %>% ggplot(aes(x=factor(research_output_qs)))+geom_bar()


# world_rank_cat_arwu
suppressWarnings({
  clean_data$world_rank_cat_arwu[as.integer(clean_data$world_rank_cat_arwu) > 0  & 
                                   as.integer(clean_data$world_rank_cat_arwu) < 21] <- "1-20"
  clean_data$world_rank_cat_arwu[as.integer(clean_data$world_rank_cat_arwu) > 20  & 
                                   as.integer(clean_data$world_rank_cat_arwu) < 51] <- "21-50"
  clean_data$world_rank_cat_arwu[as.integer(clean_data$world_rank_cat_arwu) > 50  & 
                                   as.integer(clean_data$world_rank_cat_arwu) < 101] <- "51-100"
})


arwu_levels <- c(
  "1-20",
  "21-50",
  "51-100",
  "101-150",
  "151-200",
  "201-300",
  "301-400",
  "401-500")

clean_data$world_rank_cat_arwu <- factor(clean_data$world_rank_cat_arwu, levels = arwu_levels)

clean_data %>% ggplot(aes(x=factor(world_rank_cat_arwu)))+geom_bar()


# world_rank_qs
suppressWarnings({
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 0  & 
                             as.integer(clean_data$world_rank_qs) < 21] <- "1-20"
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 20  & 
                             as.integer(clean_data$world_rank_qs) < 51] <- "21-50"
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 50  & 
                             as.integer(clean_data$world_rank_qs) < 101] <- "51-100"
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 100  & 
                             as.integer(clean_data$world_rank_qs) < 151] <- "101-150"
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 150  & 
                             as.integer(clean_data$world_rank_qs) < 201] <- "151-200"
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 200  & 
                             as.integer(clean_data$world_rank_qs) < 301] <- "201-300"
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 300  & 
                             as.integer(clean_data$world_rank_qs) < 401] <- "301-400"
  clean_data$world_rank_qs[as.integer(clean_data$world_rank_qs) > 400  & 
                             as.integer(clean_data$world_rank_qs) < 501] <- "401-500"
  clean_data$world_rank_qs[clean_data$world_rank_qs == "511-520" |
                             clean_data$world_rank_qs == "541-550" |
                             clean_data$world_rank_qs == "561-570" |
                             clean_data$world_rank_qs == "571-580" |
                             clean_data$world_rank_qs == "581-590"] <- "501-600"
  clean_data$world_rank_qs[clean_data$world_rank_qs == "601-650" |
                             clean_data$world_rank_qs == "651-700" |
                             clean_data$world_rank_qs == "701-750" |
                             clean_data$world_rank_qs == "751-8000"] <- "601-800"
  clean_data$world_rank_qs[clean_data$world_rank_qs == "1201"] <- "1001-1200"
})


qs_levels <- c(
  "1-20",
  "21-50",
  "51-100",
  "101-150",
  "151-200",
  "201-300",
  "301-400",
  "401-500",
  "501-600",
  "601-800",
  "801-1000",
  "1001-1200")


clean_data$world_rank_qs <- factor(clean_data$world_rank_qs, levels = qs_levels)

clean_data %>% ggplot(aes(x=factor(world_rank_qs)))+geom_bar()



### Save the clean dataset

# Lastly, we dropped unrelevant variables and created a codebook for our final dataset (`clean_data.RData`). 



write_csv(clean_data, file = here::here("dataset/clean_data.csv"))



write_csv(loan_data_clean, file = here::here("dataset", "loan_refusal_clean.csv"))

save(loan_data_clean, file = here::here("dataset/loan_refusal.RData"))



                             
                              
                                