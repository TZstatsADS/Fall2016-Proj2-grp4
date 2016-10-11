# install.packages("ff")
# 0. Package and Data Loading ##########################################################################################################################
library(ff)
library(tidyr)
library(dplyr)
library(googleway)
library(ggplot2)
library(ggmap)
library(zipcode)

# 0.1 Load the raw parking violation data 
setwd("/Users/yanjin1993/Google Drive/Columbia University /2016 Fall /Applied Data Science /Project_002/")
dat.parkvio <- read.csv(file = "original_data/sampling_data.csv", header = T)
# Save to local in RDS form (smaller)
saveRDS(dat.parkvio, "exported_data/dat_parkvio.rds")
readRDS("exported_data/dat_parkvio.rds")

# 0.2 Load the raw violation code data 
dataraw.viocode <- read.csv(file = "original_data/DOF_Parking_Violation_Codes.csv", header = T)


# 1. Data Processing###################################################################################################################################
dat.pv <- dat.parkvio %>% 
  mutate(Street.All = paste(Street.Name, Intersecting.Street), 
         st.name = NA, intersect.st = NA) 

# Separate Street names from Intersecting Street names 
for (i in 1:nrow(dat.pv)){
  dat.pv$intersect.st[i] <- ifelse(grepl("@", dat.pv$Street.All[i]) == TRUE, 
                                  strsplit(dat.pv$Street.All[i], "@")[[1]][2], NA)
  dat.pv$st.name[i] <- ifelse(grepl("@", dat.pv$Street.All[i]) == TRUE, 
                              strsplit(dat.pv$Street.All[i], "@")[[1]][1], dat.pv$Street.All[i])
}

# Save to local 
saveRDS(dat.pv, file = "exported_data/dat_pv.rds")

# Make a copy of the original sampled data 
datclean.pv <- dat.pv %>% 
  mutate(adress = paste(House.Number, Street.All, "New York, NY")) %>%
  mutate(lat = NA, lng = NA) %>%
  select(-Street.All, -Street.Name, -Intersecting.Street)

# Create a Google Map API key list 
key.list <- c("AIzaSyA_uAqzc3rTm81mCHogG1yCYgoZiq7TQRw", "AIzaSyD1ckvfrorOnMrLjAhNBN4SmYr3Q9XIpXU", #done 
              "AIzaSyBiANr1TK5HMpN0lIpiueSpdwQiIuOJE-I", "AIzaSyD05iq3ylJ9ucaDrrCGCgVtkLpjTHVElbw", #done
              "AIzaSyBkqnJ2IFQtF1vsW7VzIOGiWxda3xKIxfw", "AIzaSyCsbQau0LL9SvbXr4AYOuvSp2nJULa4fwA", #done
              "AIzaSyC6gpu9Xc7WIkHkS2k_FqCLMghDUsXEAPs", "AIzaSyB9T2SL7kRNSiZ5-Jg2gQ12yn7sPr8wItg", #done
              "AIzaSyC3IWcFarkVOQOzTf8zmhBt5lwRpWXu5eQ", "AIzaSyCdTK1PiaxT0Cu_OxMg4mFVKS0r_M46nFs", #done
              "AIzaSyD9_AC8pb2egSWa5fIVAOCTrx0VNAex9-M", "AIzaSyCzIVcTytlDJVuUhzk_09N7X-ddzHd1T9M", #done
              "AIzaSyBtpgPay0wHDIpjCrJtYjz3w2kPXs2pWy4", "AIzaSyBvEvCtSw7Nxx7tNpUUBcUaUwLS-0bwVmY", #done
              "AIzaSyDBO3tkiRMnGS4nMsqeLMqbrHMqLx6bB_s", "AIzaSyBn5Qm9AvuBxABtrkLF0hum338thtX8TPE", #done
              "AIzaSyDQJ7EkT1u8cDKRTEWXM555X7pdgE3cUAQ", "AIzaSyCWQKLEjqC-EEp007WORM9_Kf13xiGHwm8", #done
              "AIzaSyDnb1EBAB9lbqJKFKnb2p0EEbh2jejPcJw", "AIzaSyCQb96Fg4CHkOeGK5r94pXBJjuSByF8GGQ",
              "AIzaSyDMfNQsf3D3HGq-DNXsi1nx593wxLsqecY", "AIzaSyD-zIW2Y-HSPwy6pJdYoxuH22LWrdB8zWg")

# Function to get geo-code by address 
GetAPIgeocode <- function(APIkey, start, end){
  for (i in start:end) {
    code <- google_geocode(address = datclean.pv$adress[i], key = APIkey)
    datclean.pv$lat[i] <- code$results$geometry$location[1,1]
    datclean.pv$lng[i] <- code$results$geometry$location[1,2]
  }
}

# Looped by API key list due to the limitation of Google API 2500 per day 
for (i in 1:length(key.list)){
  GetAPIgeocode(APIkey = key.list[[i]], start = 40000 + (i-1)*2500, end = 40000 + i*2500)
}

# Function test loop 
for (i in 70001:72500) {
  code <- google_geocode(address = datclean.pv$adress[i], key = "AIzaSyCQb96Fg4CHkOeGK5r94pXBJjuSByF8GGQ")
  datclean.pv$lat[i] <- code$results$geometry$location[1,1]
  datclean.pv$lng[i] <- code$results$geometry$location[1,2]
}

# Save segmentally to local
write.csv(datclean.pv[20000:22500,], "exported_data/pv20000_22500.csv")
write.csv(datclean.pv[22501:25000,], "exported_data/pv22501_25000.csv")
write.csv(datclean.pv[25001:27500,], "exported_data/pv25001_27500.csv")
write.csv(datclean.pv[27501:30000,], "exported_data/pv27501_30000.csv")
write.csv(datclean.pv[40000:42500,], "exported_data/pv40000_42500.csv")
write.csv(datclean.pv[42501:45000,], "exported_data/pv42501_45000.csv")
write.csv(datclean.pv[45001:47500,], "exported_data/pv45001_47500.csv")
write.csv(datclean.pv[47501:50000,], "exported_data/pv47501_50000.csv")
write.csv(datclean.pv[50001:52500,], "exported_data/pv50001_52500.csv")
write.csv(datclean.pv[52501:55000,], "exported_data/pv52501_55000.csv")
write.csv(datclean.pv[55001:57500,], "exported_data/pv55001_57500.csv")
write.csv(datclean.pv[57501:60000,], "exported_data/pv57501_60000.csv")
write.csv(datclean.pv[60001:62500,], "exported_data/pv60001_62500.csv")
write.csv(datclean.pv[62501:65000,], "exported_data/pv62501_65000.csv")
write.csv(datclean.pv[65001:67500,], "exported_data/pv65001_67500.csv")
write.csv(datclean.pv[67501:70000,], "exported_data/pv67501_70000.csv")
write.csv(datclean.pv[70001:72500,], "exported_data/pv70001_72500.csv")

# Save to local 
saveRDS(datclean.pv, file = "exported_data/dat_pv_geocode.rds")
# 
# GetAPIgeocode(APIkey = "AIzaSyCJXfHNFfA7IVJge5wD5mJ3LvzmjkUSuHU", start = 1, end = 2400)
# 
# 
# d1 <- data.frame(a = c("1324 Coney Island Ave New York, NY", "660 Coney Island Ave New York, NY"))
# b <- as.character(d1$a[1])
# 
# a <- google_geocode(address = dat.pv$adress[3], key = "AIzaSyCJXfHNFfA7IVJge5wD5mJ3LvzmjkUSuHU")
# 
# str(a)
# View(a$results)
# 
# a$results$geometry$location[1,]
# 
# d1$like[1] <- a$results$geometry$location[1,1]
# d1$l2[1] <- a$results$geometry$location[1,2]
# 
# key <- "your_api_key"



