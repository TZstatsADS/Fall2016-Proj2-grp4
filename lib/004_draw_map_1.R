# For data processing 
library(ff)
library(plyr)
library(dplyr)

# For plots 
library(ggmap)
library(leaflet)
library(zipcode)
library(choroplethrZip)

# STEP 1 Loading Data ############################################################################################# 
# Set up local path 
setwd("/Users/yanjin1993/Google Drive/Columbia University /2016 Fall /Applied Data Science /Project_002/")
# 1.1 Load original dataset 
#--------------------------------------
rawdat <- read.csv("original_data/sampling_data.csv")
# Save 120000 lines of sampling data to local 
official.data <- rawdat[1:120000, ]
write.csv(official.data, "original_data/official_data.csv")
saveRDS(official.data, "original_data/official_data.rds")

# 1.2 Load API data by Pengfei Wang 
#--------------------------------------
file.list1 <- c("pv0_2500.csv", "pv2500_5000.csv", "pv5000_7500.csv", "pv7500_10000.csv", 
                "pv10000_12500.csv", "pv12500_15000.csv", "pv15000_17500.csv", "pv17500_20000.csv",  
                "pv20000_22500.csv", "pv22500_25000.csv", "pv25000_27500.csv", "pv27500_30000.csv", 
                "pv30000_32500.csv", "pv32500_35000.csv", "pv35000_37500.csv", "pv37500_40000.csv",
                "pv72500_75000.csv", "pv75000_77500.csv", "pv77500_80000.csv", "pv80000_82500.csv", 
                "pv82500_85000.csv", "pv85000_87500.csv", "pv87500_90000.csv", "pv90000_92500.csv", 
                "pv92500_95000.csv", "pv95000_97500.csv", "pv97500_100000.csv", "pv100000_102500.csv", 
                "pv102500_105000.csv", "pv105000_107500.csv", "pv107500_110000.csv", "pv110000_112500.csv", 
                "pv112500_115000.csv", "pv115000_117500.csv", "pv117500_120000.csv")

datraw.api1 <- data.frame() 
for (file in file.list1) {
  datraw.api1 <- rbind.fill(datraw.api1, read.csv(file = paste0("original_data/Google_API/", file)))
}
datraw.api1 <- datraw.api1 %>% select(X, lng, lat) 

# 1.3 Load data by YJ 
#--------------------------------------
file.list2 <- c("pv40000_42500.csv", "pv42501_45000.csv", "pv45001_47500.csv", "pv47501_50000.csv",
                "pv50001_52500.csv", "pv52501_55000.csv", "pv55001_57500.csv", "pv57501_60000.csv",
                "pv60001_62500.csv", "pv62501_65000.csv", "pv65001_67500.csv", "pv67501_70000.csv", 
                "pv70001_72500.csv")

datraw.api2 <- data.frame() 
for (file in file.list2) {
  datraw.api2 <- rbind.fill(datraw.api2, read.csv(file = paste0("exported_data/", file)))
}
# Mask dplyr() from plyr()
detach("package:plyr", unload=TRUE) 
library(dplyr)
datraw.api2 <- datraw.api2 %>% select(X.1, lng, lat) %>% 
  rename(X = X.1) %>% filter(X != 72500)

# 1.4 Merge Google Map API datasets and the original dataset 
#--------------------------------------
# API datasets column combined
datraw.api <- rbind(datraw.api1, datraw.api2) 
# Column combined with original datasets
datclean.pv <- cbind(official.data, datraw.api %>% select(-X))
# # Add zipcode 
# test <- datclean.pv %>% mutate(geocode = as.list(lng, lat))



# 1.5 Save to local 
#--------------------------------------
write.csv(datclean.pv, "exported_data/datclean_pv.csv")
saveRDS(datclean.pv, "exported_data/datclean_pv.rds")

datclean.pv <- readRDS("exported_data/datclean_pv.rds")

# STEP 2 Drawing Map #############################################################################################  
# Make a copy of the final location data 
dat.pv <- datclean.pv
# Test 1: general plain map
overall.map <- leaflet() %>% setView(lng = -73.86869, lat = 40.75686, zoom = 10)
overall.map %>% addTiles() %>%
  addProviderTiles("CartoDB.Positron") %>%
  addMarkers(lng = as.numeric(dat.pv$lng),
             lat = as.numeric(dat.pv$lat), 
             #fillColor = ~pal, 
             # fillOpacity = 0.8, 
             # color = "#BDBDC3", 
             # weight = 1, 
             popup = state_popup,
             clusterOptions = markerClusterOptions())

# Test 2: Watercolor Version
leaflet(data = dat.pv) %>% 
  setView(lng = -73.86869, lat = 40.75686, zoom = 10) %>% 
  addProviderTiles("Stamen.Watercolor") %>%
  addProviderTiles("Stamen.TonerLabels") %>%
  #fitBounds(~min(lng), ~min(lat), ~max(lng), ~max(lat)) %>%
  addCircleMarkers(lng = as.numeric(dat.pv$lng),
                   lat = as.numeric(dat.pv$lat),
                   clusterOptions = markerClusterOptions())

# Read the fire hydrant data 
dat.firehyrant <- read.csv("original_data/Fire_Hydrants.csv") 
dat.firehyrant <- dat.firehyrant %>% rename(X.Summons.Number = Summons.Number)
dat.pv.fh <- dat.pv %>% filter(Violation.Code == 40)

# Test 3: General Map with Icon defined 
pal <- colorQuantile("YlGn", NULL, n = 5)

Icons <- iconList(
  fire = makeIcon("/Users/yanjin1993/Google Drive/Columbia University /2016 Fall /Applied Data Science /Project_002/fair_hydrant.jpg",
                  18, 18))
dat.pv.fh <- dat.pv.fh %>% mutate(type = "fire")
# Fire hydrant map 002 
leaflet(data = dat.pv.fh[1:50,]) %>%
  setView(lat=40.69196, lng = -73.96483, zoom = 10)%>%
  addProviderTiles("CartoDB.Positron") %>%
  #addProviderTiles("Stamen.Watercolor") %>%
  #addProviderTiles("Stamen.TonerLabels") %>%
  addMarkers(lng = as.numeric(dat.pv.fh$lng),
             lat = as.numeric(dat.pv.fh$lat),
             icon = greenLeafIcon)
  # addCircleMarkers(lng = as.numeric(dat.pv.fh$lng), 
  #                  lat = as.numeric(dat.pv.fh$lat), 
  #                  radius = 3, 
  #                  color = "red",
  #                  stroke=FALSE,
  #                  fillOpacity = 0.5,
  #                  popup = ~state_popup)

greenLeafIcon <- makeIcon(
  iconUrl = "https://s3.amazonaws.com/thumbnails.illustrationsource.com/huge.49.248822.JPG",
  iconWidth = 15, iconHeight = 15,
  iconAnchorX = 1, iconAnchorY = 1)

# Test 4: First page map

state_popup <- paste0("<strong>Street Name: </strong>", 
                      dat.pv$Street.Name, 
                      "<br><strong>Plate ID: </strong>", 
                      dat.pv$Plate.ID)

leaflet(data = dat.pv) %>%
  setView(lat= 40.7589, lng = -73.9851, zoom = 12)%>%
  #addProviderTiles("CartoDB.Positron") %>%
  addProviderTiles("Stamen.Toner") %>%
  addProviderTiles("Stamen.TonerLabels") %>%
  addMarkers(lng = as.numeric(dat.pv$lng),
             lat = as.numeric(dat.pv$lat),
             popup = state_popup,
             clusterOptions = markerClusterOptions())

