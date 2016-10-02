# a sample of our project
library(shiny)
library(leaflet)
library(dplyr)
library(shinythemes)
library(DT)

data<-read.csv("sampling_data.csv")
data<-data[,-1]
colnames(data)[1]<-c("Summons.Number")

shinyServer(function(input,output){
  output$nycMap<-renderLeaflet({
    if(input$numVio=="2500"){
      #numVio25<-data[sample(nrow(data),2500,replace=F),]
      map<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()%>%addMarkers(lng=-73.90,lat=40.75)
      map
    } else if(input$numVio=="5000"){
      #numVio50<-data[sample(nrow(data),5000,replace=F),]
      map<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()%>%addMarkers(lng=-73.95,lat=40.70)
      map
    } else if(input$numVio=="10000"){
      #numVio100<-data[sample(nrow(data),10000,replace=F),]
      map<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()%>%addMarkers(lng=-73.85,lat=40.65)
      map
    } else if(input$numVio=="50000"){
      #numVio500<-data[sample(nrow(data),50000,replace=F),]
    } else if(input$numVio=="100000"){
      #numVio1000<-data[sample(nrow(data),100000,replace=F),]
    } else{
      map<-leaflet()%>%setView(lng=-73.90,lat=40.75,zoom=11)%>%addTiles()
      map
    }
  })
  output$violation<-renderTable(data%>%filter(Plate.ID==input$plate))
  output$li<-renderText("This is Yanjin Li's page")
  output$sheng<-renderText("This is Tian Sheng's page")
  output$wang<-renderText("This is Pengfei Wang's page")
  output$yin<-renderText("This is Qing Yin's page")
})