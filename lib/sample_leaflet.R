library(leaflet)
library(magrittr) # for %>%
library(sp)       # deal with spatial data
library(rgdal)    # Geojson
leaflet() %>%
  addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",
    attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
  setView(lng = -73.97, lat = 40.75, zoom = 13)

# dark "https://api.mapbox.com/styles/v1/mapbox/dark-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1IjoicGZ3IiwiYSI6ImNpdG92YW54ajAwcHAyb3J4Y3ljbXhzNzcifQ.NmwtaMaKGuxK7fNaDA47Uw"
# token access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw"
# my_token access_token=pk.eyJ1IjoicGZ3IiwiYSI6ImNpdG92YW54ajAwcHAyb3J4Y3ljbXhzNzcifQ.NmwtaMaKGuxK7fNaDA47Uw",

# data
dta_coor = readRDS('nyc_street_coordinate_new.rds')

# points
df = read_csv("~/Desktop/prj2/data/0_2500.csv")
df = df[,-1]
leaflet(data = df) %>%
     addTiles(urlTemplate = "https://api.mapbox.com/styles/v1/mapbox/light-v9/tiles/256/{z}/{x}/{y}?access_token=pk.eyJ1Ijoia3dhbGtlcnRjdSIsImEiOiJjaW9jenN1OGwwNGZsdjRrcWZnazh2OXVxIn0.QJrmnV9lJzdXHkH95ERdjw",
           attribution = 'Maps by <a href="http://www.mapbox.com/">Mapbox</a>') %>%
     setView(lng = -73.97, lat = 40.75, zoom = 13) %>%
     addCircleMarkers(lng=~lng, lat=~lat, radius=0.5)

# line

Sr1 = Polygon(cbind(c(-73.89982,-73.89929,-73.89852,-73.89779,-73.89705,-73.89621,-73.89580,-73.89543,-73.89516,-73.89499,-73.89466,-73.89401,-73.89307,-73.89183,-73.89143,-73.89097), 
                    c(40.81847,40.81815,40.81769,40.81725,40.81680,40.81632,40.81607,40.81585,40.81568,40.81558,40.81538,40.81500,40.81444,40.81370,40.81347,40.81321)))
Srs1 = Polygons(list(Sr1), "s1")
SpP = SpatialPolygons(list(Srs1))

Sr2 = Polygon(a$coordinates[2])

Srs2 = Polygons(list(Sr2,Sr1), "s2s1")

ploygons = readRDS(file = "/Users/pengfeiwang/Desktop/polygons.rds")
SpP = Polygons(ploygons)
leaflet() %>% 
  addTiles() %>%
  setView(lng = -73.899818, lat = 40.81847, zoom = 13) %>% 
  addPolygons(data = Sr2)
