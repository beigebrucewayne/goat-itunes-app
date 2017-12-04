library(shinydashboard)




header <- dashboardHeader(
  title = "GOAT App Reviews"
)



body <- dashboardBody(

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
  ),

)



dashboardPage(
  skin = "black",
  header,
  dashboardSidebar(disable = TRUE),
  body
)
