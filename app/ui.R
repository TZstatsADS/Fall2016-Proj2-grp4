library(shiny)
library(leaflet)
library(RSelenium)

shinyUI(navbarPage("Better Parking",theme="bootstrap_theme_02.css",
                   tabPanel("Introduction",
                     titlePanel(h2("Introduction"))
                   ),
                   tabPanel("NYC Map",
                     titlePanel(h2("Parking Violation Analysis")),
                     sidebarLayout(
                       sidebarPanel(
                         
                       ),
                       mainPanel(
                         leafletOutput("nyc_map",height=500)
                       )
                     )
                   ),
                   tabPanel("Block Map",
                     titlePanel(h2("Parking Area Analysis")),
                     sidebarLayout(
                       sidebarPanel(
                         textInput("address","Enter the New York Address","2205 3rd AVE"),
                         textInput("date","Enter the Date (YYYY/MM/DD)","2016/09/15"),
                         textInput("start","Enter the Start Time (HH:MM)","06:00"),
                         textInput("end","Enter the End Time (HH:MM)","07:00"),
                         radioButtons("show","Select What to Show on Map",c("police office","business parking lot"))
                       ),
                       mainPanel(
                         leafletOutput("block_map",height=500)
                       )
                     )
                   ),
                   tabPanel("Information Searching",
                     titlePanel(h2("Ticket Searching System")),
                     sidebarLayout(
                       sidebarPanel(
                         textInput("plate_number","Enter the Plate ID","98255MB"),
                         submitButton("Apply changes")
                       ),
                       mainPanel(
                         dataTableOutput("ticket")
                       )
                     )
                   ),
                   tabPanel("Statistics",
                     titlePanel(h2("Data Analysis")),
                     sidebarLayout(
                       sidebarPanel(
                         
                       ),
                       mainPanel(
                         
                       )
                     )
                   ),
                   tabPanel("Reference and Contact",
                     navlistPanel("Reference and Contact",
                                  tabPanel("Reference"
                                           
                                  ),
                                  tabPanel("Contact"
                                           
                                  )
                       
                     )
                   )
))
