# Absolute Pannel Map Drop-down ####################################################################################################
# Maps by violation codes
mon<-switch(input$date,
            "Park Near Stores"= 36,
            "Park Without Current Inspection Sticker"=71,
            "Double Parking"=46,
            "Parking Time Exceeds"=37,
            "Park Near Fire Hydrant"=40)

GetViocodeData <- function(violation.code) {
  dat.pv.viocode <- dat.pv %>% filter(Violation.Code == violation.code) %>% # Switch code input 
    mutate(lng = substr(lng, 1, 7), lat = substr(lat, 1, 6), coor = paste0(lng, ",", lat)) %>%
    group_by(coor) %>%
    summarise(sum = n()) %>%
    mutate(lng = as.numeric(substr(coor, 1, 7)), lat = as.numeric(substr(coor, 9, 14))) %>%
    filter(!is.na(lat))
  return(dat.pv.viocode)
}

# Make data frames 
dat.vio40 <- GetViocodeData(40)
dat.vio36 <- GetViocodeData(36)
dat.vio71 <- GetViocodeData(71)
dat.vio46 <- GetViocodeData(46)
dat.vio37 <- GetViocodeData(37)

# Color List
color.list <- c("#edc951", "#eb6841", "#cc2a36", "#4f372d", "#00a0b0")

leaflet(data = dat.vio40) %>% #Data can be changed
  setView(lat= 40.7589, lng = -73.9851, zoom = 12)%>%
  addProviderTiles("CartoDB.Positron") %>%
  addProviderTiles("Stamen.Toner") %>%
  addProviderTiles("Stamen.TonerLabels") %>% 
  addCircleMarkers(lng = ~lng,
                   lat = ~lat,
                   radius = 3,
                   color = "#eb6841", # Color can be changed 
                   #radius = ~sum, 
                   stroke= FALSE,
                   fillOpacity = 0.8) 
