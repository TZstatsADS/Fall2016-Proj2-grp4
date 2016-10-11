library(shiny)
library(maps)
library(mapproj) 
library(leaflet)
library(rPython)
library(rgdal)
library(magrittr)
library(ggplot2)
library(sp)
library(jsonlite)
library(openxlsx)
library(googleway)

# Define UI for application that draws 4 pages
shinyUI(navbarPage(id="navbar",title="Parkman Go",
                   theme="black.css",
                   tabPanel("Introduction",
                            titlePanel(h2("Introduction")),
                            mainPanel(tabPanel("Introduction",includeMarkdown("introduction.md")))),
                   tabPanel("NYC Map",
                            div(class="outer"),
                            leafletOutput("nyc_map",height=500),
                            leafletOutput("violation_map",height=500),
                            absolutePanel(id="controls",class="panel panel-default",
                                          fixed = TRUE, draggable = TRUE, top = 60, left = "auto",
                                          right = 20, bottom = "auto", width = 330, height = "auto",h4("Violation Type"),
                            selectInput("type",label = "Choose a violation type to display",choices = c("Park Near Stores","Park Without Current Inspection Sticker",
                           "Double Parking","Parking Time Exceeds","Park Near Fire Hydrant"),selected = "Park Near Stores"))),
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
                            sidebarLayout(position="right",
                                          sidebarPanel(
                                            conditionalPanel(condition="input.ccpanel==1",
                                                             helpText("First graph:bar chart for Timeline distribution."),
                                                             helpText("Second graph: Pie chart for categories based on the Top 10 with the most counts."),
                                                             helpText("Third graph: Histogram for violation fee comparation.") ),
                                            selectInput("date1", 
                                                        label = "Choose a month to display",
                                                        choices = c("Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sept","Oct","Nov","Dec"),
                                                        selected="Jan"
                                            )), 
                                          mainPanel(tabsetPanel(
                                            tabPanel("Barchart",br(),tags$div(class="descrip_text", 
                                                                              textOutput("Bar_text")), br(),
                                                     plotOutput("ggBarPlotA",height="600px"),value=1),

                                            tabPanel("Piechart",br(),tags$div(class="descrip_text",
                                                                              textOutput("Pie_text")), br(),
                                                     plotlyOutput("ggPiePlot",height="600px"),value=1)
                                          )))),
                   tabPanel("Reference and Contact",
                     navlistPanel("Reference and Contact",
                                  tabPanel("Reference"
                                           
                                  ),
                                  tabPanel("Contact"
                                           
                                  )
                       
                     )
                   )
))
