setwd("G:/Columbia/STAT GR5243/project02")
b<-readRDS("nyc_street_coordinate.rds")
library(dplyr)
# 这一步是先把数据集按type分开，分为LineString和MultiLineString
c<-b%>%filter(b$type=="LineString")
d<-b%>%filter(b$type=="MultiLineString")
library(leaflet)
library(rgdal)
map<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()
map
# 这一步是使用LineString里的coordinate可以直接画，具体画法如下
for(i in 1:17627){
  map<-map%>%addPolylines(data=Line(c$coordinates[i][[1]]))
}
map
map1<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()
map1
# 这一步是需要将MultiLineString里的coordinate全部转化为和LineString里的coordinate一个形式
# 转化后的coordinate全部存在了coordinates.new里
check<-vector()
for(i in 1:242){
  check[i]<-length(d$coordinates[i])
}
check
check1<-vector()
for(i in 1:242){
  check1[i]<-length(d$coordinates[i][[1]])
}
check1
coordinates.new<-vector()
for(i in 1:242){
  if(check1[i]==2){
    coordinates.new[i]<-list(rbind(d$coordinates[i][[1]][[1]],d$coordinates[i][[1]][[2]]))
  } else{
    coordinates.new[i]<-list(cbind(d$coordinates[i][[1]][1:(length(d$coordinates[i][[1]])/2)],
                                   d$coordinates[i][[1]][((length(d$coordinates[i][[1]])/2)+1):(length(d$coordinates[i][[1]]))]))
  }
}
# 这一步是画coordinates.new里的线
for(i in 1:242){
  map1<-map1%>%addPolylines(data=Line(coordinates.new[i][[1]]))
}
map1
# 注意：我是分两个地图画的，最后需要整合到一起
# 整合后的数据集如下
d<-d[1:4]
d[5]<-vector()
for(i in 1:242){
  d[[i,5]]<-list(coordinates.new[[i]])
}
d<-d[c(1,2,3,5)]
colnames(d)[4]<-"coordinates"
e<-rbind(d[1:4],c[1:4])
saveRDS(e,"nyc_street_coordinate_new.rds")
# 合并为一个数据集后可以直接用以下code画
map2<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()
map2
for(i in 1:17869){
  map2<-map2%>%addPolylines(data=Line(e$coordinates[i][[1]]))
}
map2