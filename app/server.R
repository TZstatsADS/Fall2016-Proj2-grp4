library(shiny)
library(leaflet)
library(rgdal)
library(magrittr)
library(sp)
library(jsonlite)
library(openxlsx)
library(googleway)
library(maps)
library(mapproj)
library(ggplot2)
library(plotly)
library(RColorBrewer)
library(car)
library(dplyr)
library(rPython)

res1<-readOGR(dsn='pre_instance.geojson',layer="OGRGeoJSON")
business<-read.xlsx("business_parking_lot.xlsx")
parking1<-readRDS("timeline.rds")
datpv<-readRDS("datclean_pv.rds")
parking2<-as.data.frame(read.csv("pie_data.csv"))

shinyServer(function(input,output) {
  nyc<-reactive({
    nyc_map<-leaflet()%>%setView(lat=40.7589,lng=-73.9851,zoom=12)%>%
      addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>')%>%
      addProviderTiles("Stamen.Toner")%>%
      addProviderTiles("Stamen.TonerLabels")
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
      palette=c('#83d0c9','#ff084a','#fdcf58'),street_level,3
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
  monthSwitch<-reactive({
    mon_num<-switch(input$park_month,
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
    return(mon_num)
  })
  output$nyc_map<-renderLeaflet({
    if(input$vio_type=="ALL"){
      state_popup<-paste0("<strong>Street Name: </strong>",datpv$Street.Name,
                          "<br><strong>Plate ID: </strong>",
                          datpv$Plate.ID)
      nyc()%>%addMarkers(lng=as.numeric(datpv$lng),lat=as.numeric(datpv$lat),popup=state_popup,
                         clusterOptions=markerClusterOptions())
    } else if(input$vio_type=="Park Near Stores"){
      datpvvio1<-datpv%>%filter(Violation.Code==36)%>%
        mutate(lng=substr(lng,1,7),lat=substr(lat,1,6),coor=paste0(lng,",",lat))%>%
        group_by(coor)%>%summarise(sum=n())%>%
        mutate(lng=as.numeric(substr(coor,1,7)),lat=as.numeric(substr(coor,9,14)))%>%
        filter(!is.na(lat))
      nyc()%>%addCircleMarkers(data=datpvvio1,lng=~lng,lat=~lat,radius=3,color="#edc951",stroke=FALSE,fillOpacity=0.8)
    } else if(input$vio_type=="Park Without Current Inspection Sticker"){
      datpvvio2<-datpv%>%filter(Violation.Code==71)%>%
        mutate(lng=substr(lng,1,7),lat=substr(lat,1,6),coor=paste0(lng,",",lat))%>%
        group_by(coor)%>%summarise(sum=n())%>%
        mutate(lng=as.numeric(substr(coor,1,7)),lat=as.numeric(substr(coor,9,14)))%>%
        filter(!is.na(lat))
      nyc()%>%addCircleMarkers(data=datpvvio2,lng=~lng,lat=~lat,radius=3,color="#eb6841",stroke=FALSE,fillOpacity=0.8)
    } else if(input$vio_type=="Double Parking"){
      datpvvio3<-datpv%>%filter(Violation.Code==46)%>%
        mutate(lng=substr(lng,1,7),lat=substr(lat,1,6),coor=paste0(lng,",",lat))%>%
        group_by(coor)%>%summarise(sum=n())%>%
        mutate(lng=as.numeric(substr(coor,1,7)),lat=as.numeric(substr(coor,9,14)))%>%
        filter(!is.na(lat))
      nyc()%>%addCircleMarkers(data=datpvvio3,lng=~lng,lat=~lat,radius=3,color="#cc2a36",stroke=FALSE,fillOpacity=0.8)
    } else if(input$vio_type=="Parking Time Exceeds"){
      datpvvio4<-datpv%>%filter(Violation.Code==37)%>%
        mutate(lng=substr(lng,1,7),lat=substr(lat,1,6),coor=paste0(lng,",",lat))%>%
        group_by(coor)%>%summarise(sum=n())%>%
        mutate(lng=as.numeric(substr(coor,1,7)),lat=as.numeric(substr(coor,9,14)))%>%
        filter(!is.na(lat))
      nyc()%>%addCircleMarkers(data=datpvvio4,lng=~lng,lat=~lat,radius=3,color="#4f372d",stroke=FALSE,fillOpacity=0.8)
    } else if(input$vio_type=="Park Near Fire Hydrant"){
      datpvvio5<-datpv%>%filter(Violation.Code==40)%>%
        mutate(lng=substr(lng,1,7),lat=substr(lat,1,6),coor=paste0(lng,",",lat))%>%
        group_by(coor)%>%summarise(sum=n())%>%
        mutate(lng=as.numeric(substr(coor,1,7)),lat=as.numeric(substr(coor,9,14)))%>%
        filter(!is.na(lat))
      nyc()%>%addCircleMarkers(data=datpvvio5,lng=~lng,lat=~lat,radius=3,color="#00a0b0",stroke=FALSE,fillOpacity=0.8)
    }
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
  output$ggBarPlotA<-renderPlot({
    ggplot(parking1%>%filter(month==monthSwitch()),aes(f,col=e))+
      geom_histogram(binwidth=1,position="identity")+geom_freqpoly(binwidth=1)+
      labs(title="Timeline of Violation distribution")+
      theme(axis.text=element_text(size=14),legend.key=element_rect(fill="white"),
            legend.background=element_rect(fill="grey40"),legend.position=c(0.14,0.80),
            panel.grid.major=element_line(colour="grey40"),panel.grid.minor=element_blank(),
            panel.background=element_rect(fill="black"),
            plot.background=element_rect(fill="black",colour="black",size=2,linetype="longdash"))
  })
  output$ggPiePlot<-renderPlotly({
    plot_ly(parking2,labels=parking2$label,values=parking2$score,hole=0.5,type="pie")%>%
      layout(title="Donut Chart of Violation Type",xaxis=list(title=NULL,showgrid=F),yaxis=list(title=NULL,showgrid=F),plot_bgcolor='rgba(0,0,0,1)')
  })
})
