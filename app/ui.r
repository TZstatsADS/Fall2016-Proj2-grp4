# a sample of our project
library(shiny)
library(leaflet)
library(dplyr)
library(shinythemes)
library(DT)

shinyUI(navbarPage(theme=shinytheme("Readable"),"Parking Violation",
                   tabPanel("Map",
                            sidebarLayout(
                              sidebarPanel(
                                radioButtons("numVio","Number of Violations to show",
                                             c("2500","5000","10000",
                                               "50000","100000","None")),
                                selectInput("month","Month to show",
                                            c("Jan","Feb","Mar","Apr","May","Jun",
                                              "Jul","Aug","Sept","Oct","Nov","Dec"))
                              ),
                              mainPanel(
                                leafletOutput("nycMap")
                              )
                            )
                   ),
                   tabPanel("Check",
                            sidebarLayout(
                              sidebarPanel(
                                textInput("plate","Enter the Plate ID","98255MB")
                              ),
                              mainPanel(
                                tableOutput("violation")
                              )
                            )
                            
                     
                   ),
                   navbarMenu("More",
                              tabPanel("Data Analysis"
                                       
                              ),
                              tabPanel("Contact",
                                       navlistPanel("Team Members",
                                                    tabPanel("Yanjin Li",textOutput("li")),
                                                    tabPanel("Tian Sheng",textOutput("sheng")),
                                                    tabPanel("Pengfei Wang",textOutput("wang")),
                                                    tabPanel("Qing Yin",textOutput("yin"))
                                       )
                                      
                              )
                   )
         )
)