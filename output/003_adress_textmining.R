setwd("/Users/yanjin1993/Google Drive/Columbia University /2016 Fall /Applied Data Science /Project_002/")
dat.pv <- readRDS(file = "exported_data/dat_pv_geocode.rds")
library(gdata) # StartsWith
library(stringi) # upper case 
library(tm)
library(NLP)


# 3. Text Cleaning Process #######################################################################################################
#dat.pv100 <- dat.pv[300:400,]
# 3.1 Standardize the type of ways
dat.pv.cp <- dat.pv %>% 
  mutate(Street.Name = ifelse(grepl("St|ST|st", st.name) == TRUE,
                              gsub("St|ST|st", " St ", st.name),
                          ifelse(grepl("Ave|ave|AVE|AV.", st.name) == TRUE, 
                              gsub("Ave|ave|AVE|AV."," Ave ", st.name), 
                              ifelse(grepl("Pl|PL|pl", st.name) == TRUE, 
                                     gsub("Pl|PL|pl", " Pl ", st.name),
                                             ifelse(grepl("Camp|camp|CAMP", st.name) == TRUE,
                                                    gsub("Camp|camp|CAMP", " Camp ", st.name),
                                                    ifelse(grepl("Exd|EXD|exd", st.name) == TRUE,
        gsub("Exd|EXD|exd", " Exd ", st.name), 
            ifelse(grepl("Ln|LN|ln", st.name) == TRUE,
                   gsub("Ln|LN|ln", " Ln ", st.name), 
                   ifelse(grepl("Brg|brd|BRG", st.name) == TRUE,
                          gsub("Brg|brd|BRG", " Brg ", st.name),
                          ifelse(grepl("Pkwy|PKWY|pkwy", st.name) == TRUE,
                                 gsub("Pkwy|PKWY|pkwy", " Pkwy ", st.name),
                                 ifelse(grepl("Blvd|BLVD|blvd", st.name) == TRUE,
                                        gsub("Blvd|BLVD|blvd", " Blvd ", st.name),
                                        # ifelse(grepl("Way|WAY|way", st.name) == TRUE,
                                        #        gsub("Way|WAY|way", " Way ", st.name),
                                        ifelse(grepl("Expy|EXPY|expy|EXPWY|EXPRESSWAY", st.name) == TRUE,
                                               gsub("Expy|EXPY|expy|EXPWY|EXPRESSWAY", " Expy ", st.name),
                                               ifelse(grepl("Dr|DR|dr", st.name) == TRUE,
                                                      gsub("Dr|DR|dr", " Dr ", st.name), 
                                                      ifelse(grepl("HWY|hwy|Hwy", st.name) == TRUE,
                                                             gsub("HWY|hwy|Hwy", " Hwy ", st.name), st.name)))))))))))))

# 3.2 Remove words after Ave, St, etc. 
dat.pv.cp <- dat.pv.cp %>% 
  mutate(Street.Name = ifelse(grepl("St", Street.Name) == TRUE,
                              paste(gsub("St.*", "", Street.Name), "St"),
                          ifelse(grepl("Ave", Street.Name) == TRUE, 
                              paste(gsub("Ave.*","", Street.Name), "Ave"), 
                              ifelse(grepl("Pl", Street.Name) == TRUE,
                                     paste(gsub("Pl.*", "", Street.Name), "Pl"),
                                            ifelse(grepl("Camp", Street.Name) == TRUE,
                                                   paste(gsub("Camp.*", "", Street.Name), "Camp"),
                                                         ifelse(grepl("Exd", Street.Name) == TRUE,
                                                                paste(gsub("Exd.*", "", Street.Name), "Exd"),
                                                                ifelse(grepl("Ln", Street.Name) == TRUE,
                   paste(gsub("Ln.*", "", Street.Name), "Ln"),
                   ifelse(grepl("Brg", Street.Name) == TRUE,
                          paste(gsub("Brg.*", "", Street.Name), "Brg"),
                          ifelse(grepl("Pkwy", Street.Name) == TRUE,
                                 paste(gsub("Pkwy.*", "", Street.Name), "Pkwy"),
                                 ifelse(grepl("Blvd", Street.Name) == TRUE,
                                        paste(gsub("Blvd.*", "", Street.Name), "Blvd"),
                                        ifelse(grepl("Expy", Street.Name) == TRUE,
                                               paste(gsub("Expy.*", "", Street.Name), "Expy"),
                                               ifelse(grepl("Dr", Street.Name) == TRUE,
                                                      paste(gsub("Dr.*", "", Street.Name), "Dr"),
                                                      ifelse(grepl("Hwy", Street.Name) == TRUE,
                                                             paste(gsub("Hwy.*", "", Street.Name), "Hwy"),
                                                             Street.Name)))))))))))))

# 3.3 Remove words after Ave but before St
dat.pv.cp <- dat.pv.cp %>% 
  mutate(Street.Name = ifelse(grepl("Ave", Street.Name) == TRUE,
                              paste0(gsub("Ave.*", "", Street.Name), "Ave"), Street.Name))

# 3.4 Remove EB, NB, WB, SB
dat.pv.cp <- dat.pv.cp %>% 
  mutate(Street.Name.cp = ifelse(startsWith(Street.Name, "EB ") == TRUE, 
                               gsub("EB ", "", Street.Name),
                              ifelse(startsWith(Street.Name, "WB ") == TRUE, 
                                     gsub("WB ", "", Street.Name),
                                     ifelse(startsWith(Street.Name, "NB ") == TRUE, 
                                            gsub("NB ", "", Street.Name),
                                            ifelse(startsWith(Street.Name, "SB ") == TRUE, 
                                                   gsub("SB ", "", Street.Name), Street.Name)))))
# 3.5 Make the first character of each uppercase
dat.pv.cp <- dat.pv.cp %>% 
  mutate(Street.Name.cp = stri_trans_totitle(Street.Name.cp))

# 3.6 Remove the tail whitespace 
dat.pv.cp <- dat.pv.cp %>% mutate(Street.Name.cp = trimws(Street.Name.cp))
# 3.7 Substitute all space by "_"
dat.pv.cp <- dat.pv.cp %>% 
  mutate(Street.Name.cp = gsub(" |  |   |    |     ", "_", Street.Name.cp))
# 3.8 Make into Corpus 
docs <- Corpus(VectorSource(dat.pv.cp$Street.Name.cp))

# 3.6 Count Street Name Frequency 
detach("package:plyr", unload=TRUE) 
library(dplyr)
freq.streetname <- dat.pv.cp %>% 
  select(Street.Name.cp) %>%
  group_by(Street.Name.cp) %>%
  summarise(count = n()) %>%
  arrange(desc(count))

# 3.7 Make "_" Back to " "
freq.streetname <- freq.streetname %>% 
  mutate(Street.Name.cp = gsub("_", " ", Street.Name.cp))


