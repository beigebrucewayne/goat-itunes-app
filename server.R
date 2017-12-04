library(tidyverse)


function(input, output) {

  data <- reactive({
    dat <- read_csv('./data/app_reviews.csv')  
  })

}
