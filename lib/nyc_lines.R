setwd("G:/Columbia/STAT GR5243/project02")
a<-readRDS("nyc_street_coordinate_new.rds")
library(dplyr)
library(leaflet)
library(rgdal)
map2<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()
map2
for(i in 1:17869){
  map2<-map2%>%addPolylines(data=Line(a$coordinates[i][[1]]))
}
map2