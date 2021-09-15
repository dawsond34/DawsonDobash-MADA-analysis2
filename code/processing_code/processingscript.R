###############################
# processing script
#
#this script loads the raw data, processes and cleans it 
#and saves it as Rds file in the processed_data folder

#load needed packages. make sure they are installed.
library(readr) #for loading CSV files
library(dplyr) #for data processing
library(here) #to set paths
library(tidyverse)

#path to data
#note the use of the here() package and not absolute paths
data_location <- here::here("data","raw_data","Distribution_of_COVID-19_Deaths_and_Populations__by_Jurisdiction__Age__and_Race_and_Hispanic_Origin.csv")

#load data. 
#note that for functions that come from specific packages (instead of base R)
# I often specify both package and function like so
#package::function() that's not required one could just call the function
#specifying the package makes it clearer where the function "lives",
#but it adds typing. You can do it either way.
rawdata <- readr::read_csv(data_location)

#take a look at the data
dplyr::glimpse(rawdata)

#Creating another version of the rawdata so I can change this copy,.
rawdata2 = rawdata

#This is using an if else statement to change those observations with values of NA to 5.
#The reason behind this transformation is that there is a variable called suppression which tells when a value for 
#COVID-19 deaths is <10 for that specific Race origin, they suppress it to NA. Therefore since I want to keep these
#observations, I changed each value to 5 because it is the middle value of the suppression.
rawdata2$`Count of COVID-19 deaths` = ifelse(is.na(rawdata2$`Count of COVID-19 deaths`), 5 , rawdata2$`Count of COVID-19 deaths`)

#I changed the race origin to a factor variable to be able to use the fct_collapse command.
rawdata2$`Race/Hispanic origin`= as_factor(rawdata2$`Race/Hispanic origin`)

#This fct_collapse command decrease the amount of categories based on the programmers specific groups.
#I wanted to combine the least common races so I have less small groupings
rawdata2$`Race/Hispanic origin` = fct_collapse(rawdata2$`Race/Hispanic origin`, 
                                               White = "Non-Hispanic White",
                                               Black = "Non-Hispanic Black",
                                               Asian = "Non-Hispanic Asian",
                                               Hispanic = "Hispanic",
                                               Other = c("Other", "Non-Hispanic Native Hawaiian or Other Pacific Islander", "Non-Hispanic American Indian or Alaska Native"))

#This is creating the new data set processeddata. This only includes the four variables I think I want to use to run 
#analysis on. I also removed the observations that describe the amount of COVID-19 deaths for the whole United States 
#just to make calculations easier if wanting to do calculations based on certain categorical variables.
processeddata <- rawdata2 %>% select(State, `Race/Hispanic origin`, `Count of COVID-19 deaths`, AgeGroup) %>% 
  filter(AgeGroup == "All ages, unadjusted", State != "United States") 

#This is just looking at a summary of the variables of the new data set.
summary(processeddata)


# save data as RDS
# I suggest you save your processed and cleaned data as RDS or RDA/Rdata files. 
# This preserves coding like factors, characters, numeric, etc. 
# If you save as CSV, that information would get lost.
# See here for some suggestions on how to store your processed data:
# http://www.sthda.com/english/wiki/saving-data-into-r-data-format-rds-and-rdata

# location to save file
save_data_location <- here::here("data","processed_data","processeddata.rds")

saveRDS(processeddata, file = save_data_location)


