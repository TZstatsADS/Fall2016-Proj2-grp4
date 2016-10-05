library(jsonlite)
library(leaflet)
library(magrittr) # for %>%
library(sp)       # deal with spatial data
library(rgdal) 

url <- "https://raw.githubusercontent.com/PengfeiWangWZ/nyc-streets/master/nyc-streets.geojson"
res <- readOGR(dsn = url, layer = "OGRGeoJSON")

leaflet() %>% 
  addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",
           attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
  setView(lng = -73.899818, lat = 40.81847, zoom = 13) %>% 
  addPolylines(data = res, color = "#5b0468" ,opacity = 0.5 )

# purple #5b0468
# orange #fbcda5