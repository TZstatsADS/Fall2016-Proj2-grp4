library(shiny)
library(leaflet)
library(RSelenium)

shinyServer(function(input, output) {
  nyc<-reactive({
    nyc_map<-leaflet() %>%
      setView(lng=-73.90,lat=40.75,zoom=11) %>%
      addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
    return(nyc_map)
  })
  block<-reactive({
    block_map<-leaflet() %>%
      setView(lng=-73.935,lat=40.80,zoom=15) %>%
      addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",
               attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
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
