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

shinyUI(navbarPage("Parkman Go",theme="bootstrap_theme_01.css",
                   tabPanel("Introduction",
                     titlePanel(h2("Introduction")),
                     mainPanel(tabPanel("Introduction",
                                        includeMarkdown("introduction.md")
                               )
                     )
                   ),
                   tabPanel("NYC Map",
                     leafletOutput("nyc_map",height=600),
                     absolutePanel(fixed=TRUE,draggable=TRUE,
                                   top=60,left="auto",right=20,bottom="auto",
                                   width=330,height="auto",
                                   h4("Violation Type"),
                                   selectInput("vio_type",label="Choose a Violation Type to Display",
                                               choices=c("ALL","Park Near Stores","Park Without Current Inspection Sticker",
                                                         "Double Parking","Parking Time Exceeds","Park Near Fire Hydrant"))
                     )
                   ),
                   tabPanel("Block Map",
                     titlePanel(h2("Parking Area Analysis")),
                     sidebarLayout(
                       sidebarPanel(
                         textInput("address","Enter the New York Address","2205 3rd AVE"),
                         textInput("date_sta","Enter the Date (YYYY/MM/DD)","2016/09/13"),
                         textInput("start","Enter the Start Time (HH:MM)","06:00"),
                         textInput("date_end","Enter the Date (YYYY/MM/DD)","2016/09/13"),
                         textInput("end","Enter the End Time (HH:MM)","07:00"),
                         radioButtons("show","Select What to Show on Map",c("Government Office","Business Parking Lot"))
                       ),
                       mainPanel(
                         tabsetPanel(type="pill",
                                     tabPanel("map",
                                              leafletOutput("block_map",height=500)
                                              ),
                                     tabPanel("street view",
                                              google_mapOutput("street",height=500)
                                              )
                           
                         )
                       )
                     )
                   ),
                   tabPanel("Information Searching",
                     titlePanel(h2("Ticket Searching System")),
                     sidebarLayout(
                       sidebarPanel(
                         textInput("plate_number","Enter the Plate ID"),
                         actionButton("submit","Apply changes")
                       ),
                       mainPanel(
                         dataTableOutput("ticket")
                       )
                     )
                   ),
                   tabPanel("Statistics",
                            titlePanel(h2("Data Analysis")),
                            tabsetPanel(
                              tabPanel("Barchart",
                                       titlePanel(h3("Bar Chart")),
                                       sidebarLayout(
                                         sidebarPanel(
                                           selectInput("park_month", 
                                                       label="Choose a Month to Display",
                                                       choices=c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec")
                                           )
                                         ),
                                         mainPanel(
                                           plotOutput("ggBarPlotA",height="600px")
                                         )
                                       )
                              ),
                              tabPanel("Piechart",
                                       titlePanel(h3("Pie Chart")),
                                       plotlyOutput("ggPiePlot",height="600px"))
                            )
                   ),
                   tabPanel("Reference and Contact",
                     navlistPanel("Reference and Contact",
                                  tabPanel("Reference"
                                           
                                  ),
                                  tabPanel("Contact",
                                           includeMarkdown("contact.md")
                                           
                                  )
                       
                     )
                   )
))
