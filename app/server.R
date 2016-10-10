library(shiny)
library(leaflet)
library(RSelenium)

shinyServer(function(input, output) {
  nyc<-reactive({
    nyc_map<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()
    return(nyc_map)
  })
  block<-reactive({
    block_map<-leaflet()%>%setView(lng=-73.935,lat=40.80,zoom=15)%>%addTiles()
    return(block_map)
  })
  output$nyc_map<-renderLeaflet({
    nyc()
  })
  output$block_map<-renderLeaflet({
    block()
  })
  output$ticket<-renderDataTable({
    
  })
})
