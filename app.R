library(shiny)
library(shinydashboard)
library(dplyr)
library(tidyr)
library(DT)
library(markdown)
library(itunesr)
library(ggplot2)

body <- dashboardBody(

 )

sidebar <- dashboardSidebar(

)

ui <- dashboardPage(
    skin = "black",

    dashboardHeader(
        title = "GOAT iTunes Analysis"
    ),

    sidebar,

    body
)

server <- function(input, output) {

}

shinyApp(ui, server)
