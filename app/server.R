library(shiny)
library(leaflet)
library(rgdal)
library(magrittr)
library(sp)
library(jsonlite)
library(openxlsx)
library(rPython)
library(googleway)

res1<-readOGR(dsn='pre_instance.geojson',layer="OGRGeoJSON")
business<-read.xlsx("business_parking_lot.xlsx")

shinyServer(function(input,output) {
  nyc<-reactive({
    state_popup <- paste0("<strong>Estado: </strong>", 
                          dat.pv$Street.Name, 
                          "<br><strong>PIB per c?pita, miles de pesos, 2008: </strong>", 
                          dat.pv$Plate.ID)
    
    nyc_map<-leaflet(data = dat.pv) %>%
      setView(lat= 40.7589, lng = -73.9851, zoom = 12)%>%
      #addProviderTiles("CartoDB.Positron") %>%
      addProviderTiles("Stamen.Toner") %>%
      addProviderTiles("Stamen.TonerLabels") %>%
      addMarkers(lng = as.numeric(dat.pv$lng),
                 lat = as.numeric(dat.pv$lat),
                 popup = state_popup,
                 clusterOptions = markerClusterOptions())
    
    return(nyc_map)
  })
  
  violation<-reactive({
    GetViocodeData <- function(violation.code) {
      dat.pv.viocode <- dat.pv %>% filter(Violation.Code == violation.code) %>% # Switch code input 
        mutate(lng = substr(lng, 1, 7), lat = substr(lat, 1, 6), coor = paste0(lng, ",", lat)) %>%
        group_by(coor) %>%
        summarise(sum = n()) %>%
        mutate(lng = as.numeric(substr(coor, 1, 7)), lat = as.numeric(substr(coor, 9, 14))) %>%
        filter(!is.na(lat))
      return(dat.pv.viocode)
    }
    # Color List
    color.list <- c("#edc951", "#eb6841", "#cc2a36", "#4f372d", "#00a0b0")
    # Violation type switch #
    number<-switch(input$type,
                   "Park Near Stores"= 36,
                   "Park Without Current Inspection Sticker"=71,
                   "Double Parking"=46,
                   "Parking Time Exceeds"=37,
                   "Park Near Fire Hydrant"=40)
    # Color switch #
    color_s<-switch(input$type,
                    "Park Near Stores"= "#edc951",
                    "Park Without Current Inspection Sticker"="#eb6841",
                    "Double Parking"="#cc2a36",
                    "Parking Time Exceeds"="#4f372d",
                    "Park Near Fire Hydrant"="#00a0b0")
    # Make data frames 
    dat.vio40 <- GetViocodeData(40)
    dat.vio36 <- GetViocodeData(36)
    dat.vio71 <- GetViocodeData(71)
    dat.vio46 <- GetViocodeData(46)
    dat.vio37 <- GetViocodeData(37)
    violation_map<-leaflet(data = GetViocodeData(number)) %>% #Data can be changed
      setView(lat= 40.7589, lng = -73.9851, zoom = 12)%>%
      addProviderTiles("CartoDB.Positron") %>%
      addProviderTiles("Stamen.Toner") %>%
      addProviderTiles("Stamen.TonerLabels") %>% 
      addCircleMarkers(lng = ~lng,
                       lat = ~lat,
                       radius = 3,
                       color = "#edc951", # Color can be changed 
                       #radius = ~sum, 
                       stroke= FALSE,
                       fillOpacity = 0.8)
    return(violation_map)
  })
  
  #### output of nyc_map #####
  output$nyc_map<-renderLeaflet({state_popup <- paste0("<strong>Estado: </strong>", 
                                                       dat.pv$Street.Name, 
                                                       "<br><strong>PIB per c?pita, miles de pesos, 2008: </strong>", 
                                                       dat.pv$Plate.ID)
  
  leaflet(data = dat.pv) %>%
    addProviderTiles("CartoDB.Positron") %>%
    addMarkers(lng = as.numeric(dat.pv$lng),
               lat = as.numeric(dat.pv$lat),
               popup = state_popup,
               clusterOptions = markerClusterOptions())
  nyc()
  })
  #### output of violation_map ####
  output$violation_map<-renderLeaflet(
    violation_map1<-leaflet(data = GetViocodeData(number)) %>% #Data can be changed
      setView(lat= 40.7589, lng = -73.9851, zoom = 12)%>%
      addProviderTiles("CartoDB.Positron") %>%
      addProviderTiles("Stamen.Toner") %>%
      addProviderTiles("Stamen.TonerLabels") %>% 
      addCircleMarkers(lng = ~lng,
                       lat = ~lat,
                       radius = 3,
                       color = "#edc951", # Color can be changed 
                       #radius = ~sum, 
                       stroke= FALSE,
                       fillOpacity = 0.8),
    return(violation_map1)
  )
  
  block<-reactive({
    # Add color columns
    rule_simp2cha=lapply(res1$rule_simplified,as.character,stringsAsFactors=FALSE)
    result1=lapply(rule_simp2cha,function(x) {ifelse(grepl('From',x),0,1)})
    add_rule2cha=lapply(res1$addtl_info_parking_rule,as.character,stringsAsFactors=FALSE)
    result2=lapply(add_rule2cha,function(x) {ifelse(grepl('Metered',x),2,0)})
    ####################################################
    ##  0 for free, 1 for No parking, 2 for Metered  ##
    ####################################################
    street_level=c()
    for(i in 1:376) {
      result=result1[[i]]+result2[[i]]
      street_level=append(street_level,result)
    }
    
    pal=palette(c('#00FF00','#FF0000','#808080'))
    res1$addtl_info_next_period_parking_rule=as.list(street_level)
    
    pal<-colorBin(
      palette=c('#00FF00','#FF0000','#808080'),street_level,3
    )
    
    block_map<-leaflet()%>%
      addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')%>%
      addProviderTiles("Stamen.Toner")%>%
      addProviderTiles("Stamen.TonerLabels")%>%
      setView(lng=-73.937,lat=40.802,zoom=16)%>% 
      addPolylines(data=res1,opacity=1,popup=~as.character(rule_simplified),color=~pal(as.numeric(addtl_info_next_period_parking_rule)))
    return(block_map)
  })
  policeIcon<-reactive({
    makeIcon(
      iconUrl=paste("http://jimzalud.com/wp-content/uploads/police",as.character(input$icon),".png?raw=true",sep=""),
      iconWidth=25,iconHeight=25,iconAnchorX=13,iconAnchorY=13
    )%>%
      return()
  })
  fireIcon<-reactive({
    makeIcon(
      iconUrl=paste("http://www.turtlelakewi.com/vertical/Sites/%7BC9D8062C-1922-40DB-BABF-0640B84C8BA2%7D/uploads/fire_committee(1)",as.character(input$icon),".gif?raw=true",sep=""),
      iconWidth=25,iconHeight=25,iconAnchorX=13,iconAnchorY=13
    )%>%
      return()
  })
  parkingIcon<-reactive({
    makeIcon(
      iconUrl=paste("http://www.myparkingsign.com/img/lg/K/Parking-Sign-K-7197",as.character(input$icon),".gif?raw=true",sep=""),
      iconWidth=25,iconHeight=25,iconAnchorX=13,iconAnchorY=13
    )%>%
      return()
  })
  number<-eventReactive(input$submit,{
    python.exec('import sys')
    python.exec("sys.path.append('/Library/Frameworks/Python.framework/Versions/2.7/lib/python2.7/site-packages')")
    python.load('violation_check.py')
    python.assign("plate_number",input$plate_number)
    python.exec('a=Ticket_check(plate_number)')
    alist=python.get("a")
    alist=as.data.frame(alist)
    return(alist)
  })
  
  #### output of blockmap ####
  output$block_map<-renderLeaflet({
    if(input$show=="Government Office"){
      block()%>%addMarkers(-73.941098,40.800833,icon=policeIcon())%>%
        addMarkers(-73.936403,40.803321,icon=fireIcon())
    } else if(input$show=="Business Parking Lot"){
      block()%>%addMarkers(data=business,~lng,~lat,icon=parkingIcon(),popup=~as.character(price))
    }
  })
  output$street<-renderGoogle_map({
    google_map(key="AIzaSyBEwCy_6d2PImTjhBUEl8gT8ChiFJfzF1c",location=c(40.803321,-73.936403),zoom=16,search_box=T)
  })
  output$ticket<-renderDataTable({
    number()
  })
})

output$ggBarPlotA<-renderPlot({
  mon<-switch(input$date1,
              "Jan"=1,
              "Feb"=2,
              "Mar"=3,
              "Apr"=4,
              "May"=5,
              "Jun"=6,
              "Jul"=7,
              "Aug"=8,
              "Sept"=9,
              "Oct"=10,
              "Nov"=11,
              "Dec"=12)
  all<-read.rds("timeline.rds")
  c = filter(all, month==mon)
  barplot<-ggplot(c, aes(f,col=e)) + 
    geom_histogram(binwidth=1,position="identity")+geom_freqpoly(binwidth=1)+ 
    labs(title = "Timeline of Violation distribution") +
    theme(axis.text = element_text(size = 14),
          legend.key = element_rect(fill = "white"),
          legend.background = element_rect(fill = "grey40"),
          legend.position = c(0.14, 0.80),
          panel.grid.major = element_line(colour = "grey40"),
          panel.grid.minor = element_blank(),
          panel.background = element_rect(fill = "black"),
          plot.background = element_rect(fill = "black",colour = "black",size = 2,
                                         linetype = "longdash"))
  return(barplot)
})

