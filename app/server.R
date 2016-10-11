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
    nyc_map<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()
    return(nyc_map)
  })
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
  output$nyc_map<-renderLeaflet({
    nyc()
  })
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
