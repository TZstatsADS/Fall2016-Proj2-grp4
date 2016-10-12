#install.packages("jsonlite")
library(jsonlite)
library(dplyr)
library(tidyr)
library(plyr)

setwd("/Users/yanjin1993/Google Drive/Columbia University /2016 Fall /Applied Data Science /Project_002/")
nyc.st.json <- fromJSON("original_data/nyc-streets.geojson")
dat.nyc.st <- nyc.st.json$features 
datclean.nycst <- cbind(dat.nyc.st$properties %>% 
                          select(LINEARID, FULLNAME), dat.nyc.st$geometry)
# 1. Data Processing ###################################################################################################################################
# 1.1 Nested Data Flatten 
# Make a dataframe for flatten geo-code for each street name (LineString only)
rows <- data.frame()
for (i in 1:nrow(datclean.nycst)) {
  if (datclean.nycst$type[i] == "LineString"){
    # Extract the list of geocode for each street 
    cols <- as.data.frame(datclean.nycst$coordinates[[i]]) 
    cols <- cols %>% mutate(V1 = paste0(V1, ", ", V2)) %>% 
      select(-V2)
    rows <- rbind.fill(rows, as.data.frame(t(cols)))
  } else {
    # If is not a LineString type, then the entire row remains NA 
    rows <- rbind.fill(rows, data.frame(NA))
  }
} 
dat.rows <- rows %>% select(-NA.)

# Merge two dataframes 
dat.nyc.street <- cbind(datclean.nycst, dat.rows) 

# Save to local 
saveRDS(dat.nyc.street, "exported_data/nyc_street_coordinate.rds")
