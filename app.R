library(tidyverse)
library(shinydashboard)
library(tidytext)
library(shiny)
library(shinycssloaders)
library(wordcloud)
library(ggthemes)
library(DT)
library(tidyquant)
library(igraph)
library(networkD3)
library(sweep)
library(forecast)
library(tibbletime)
library(timetk)

data <- read_csv('./data/local_data.csv')
data %>%
  separate("Date", c("Date", "Drop"), sep = " ") %>%
  select("Title", "Author_Name", "App_Version", "Date", "Rating", "Review")


#### Arima + Time Series ####
t <- summarize(group_by(data, Date), mean(Rating))
t <- t %>% rename(Avg_Rating = `mean(Rating)`)
t <- t %>% filter(Date > as.Date("2017-01-01"))
t <- t %>% as_tbl_time(index = Date)
t <- tk_ts(t, start = 1, frequency = 30)
fit_arima <- auto.arima(t)
fcast_arima <- forecast(fit_arima, h = 150)
fcast_tbl <- sw_sweep(fcast_arima, timetk_idx = TRUE)
actual_tbl <- fcast_tbl %>% dplyr::filter(key == "actual")
value <- fcast_tbl %>% arrange(desc(index))
predValue <- round(value[[1, 3]], digits = 2)


#### Word Ratios ####
word_ratios <- data %>%
  unnest_tokens(word, Review) %>%
  count(word, Rating) %>%
  filter(sum(n) >= 10) %>%
  ungroup() %>%
  spread(Rating, n, fill = 0) %>%
  select(word, `5`, `1`) %>%
  mutate_if(is.numeric, funs((. + 1) / sum(. + 1))) %>%
  mutate(logratio = log(`5` / `1`)) %>%
  arrange(desc(logratio))


header <- dashboardHeader(
  title = "GOAT APP REVIEWS",
  titleWidth = 300
)



body <- dashboardBody(

  tags$head(
    tags$link(rel = "stylesheet", type = "text/css", href = "bootstrap.css")
  ),

  fluidRow(

    column(
      width = 12,
      box(title = "latest reviews",
      width = NULL,
      solidHeader = TRUE,
      DT::dataTableOutput("onestar") %>% withSpinner()
      )
    ),

    infoBoxOutput("avgrate"),

    column(
      width = 12,
      box(title = "App Ratings - Actual, Forecasted and Exponential 30 & 120 Day Moving Averages",
      width = NULL,
      solidHeader = TRUE,
      plotOutput("appr") %>% withSpinner()
      )
    ),

    column(
      width = 12,
      box(title = "Likeliness To Appear In 5 vs 1 Rating",
      width = NULL,
      solidHeader = TRUE,
      plotOutput('logodds') %>% withSpinner()
      )
    ),

    column(
      width = 7,
      box(title = "N-gram Word Cloud",
      width = NULL,
      solidHeader = TRUE,
      plotOutput('wordcloud') %>% withSpinner()
      )
    ),

    column(
      width = 5,
      box(#title = " ",
      width = NULL,
      solidHeader = TRUE,
      h3('# of grams'),
      sliderInput('ngramCount', ' ', min = 1, max = 5, value = 4),
      br(),
      br(),
      h3('# of words'),
      sliderInput('wordCount', '', min = 50, max = 300, value = 75),
      br(),
      h3('What\'s an N-gram?'),
      p('An n-gram is a contiguous sequence of n items from a given sequence of text or speech. You can read more', a(href='http://text-analytics101.rxnlp.com/2014/11/what-are-n-grams.html', 'here'), 'and', a(href='https://searchengineland.com/brainlabs-script-find-best-worst-search-queries-using-n-grams-228379', 'here.'))
      )
    ),

    column(
      width = 10,
      box(title = "Important Word Associations",
      solidHeader = TRUE,
      width = NULL,
      forceNetworkOutput("force") %>% withSpinner()
      )
    ),

    column(
      width = 2,
      box(
      h3("Remove Common Words?"),
      width = NULL,
      solidHeader = TRUE,
      radioButtons("filter_stopwords", "",
                   choices = c("Yes" = "yes",
                               "No" = "no"),
                   selected = "no")
      )
    )
  )

)



ui <- dashboardPage(
  skin = "black",
  header,
  dashboardSidebar(disable = TRUE),
  body
)



server <- function(input, output) {

  output$onestar <- DT::renderDataTable({

    DT::datatable(data %>%
      select(Title, Rating, Date, App_Version, Review) %>%
      arrange(desc(Date)) %>%
      mutate(Date = format(as.Date(Date), "%b - %y")),
      class = 'stripe cell-border hover compact order-column',
      rownames = FALSE,
      options = list(
        columnDefs = list(list(className = 'dt-center', targets = c(0, 1, 2, 3))),
        searching = FALSE,
        pageLength = 10
      )
    )
  })


  ngramsSelected <- reactive({
    input$ngramCount
  })


  wordsSelected <- reactive({
    input$wordCount
  })


  output$wordcloud <- renderPlot({

    data %>%
      unnest_tokens(ngram, Review, token = "ngrams", n = ngramsSelected()) %>%
      count(ngram) %>%
      with(wordcloud(ngram, n, max.words = wordsSelected(),
                     rot.per = 0.2,
                     colors = c('#F8766D', '#00BFC4')))

  })


  output$appr <- renderPlot({

    fcast_tbl %>%
      ggplot(aes(x = index, y = Avg_Rating, color = key)) +
        geom_ribbon(aes(ymin = lo.95, ymax = hi.95), alpha = 0.3, fill = '#D5DBFF', color = NA, size = 0) +
        geom_ribbon(aes(ymin = lo.80, ymax = hi.80), alpha = 0.3, fill = '#596DD5', color = NA, size = 0, alpha = 1) +
        geom_line(alpha = 0.1) +
        geom_point(alpha = 0.1) +
        geom_line(aes(x = index, y = Avg_Rating), alpha = 0.15, data = actual_tbl) +
        geom_ma(ma_fun = EMA, n = 30, size = 1, color = '#56BCC2', linetype = 1) +
        geom_ma(ma_fun = EMA, n = 120, size = 2, color = 'gray18', linetype = 1) +
        theme_hc() +
        labs(x = NULL, y = NULL) +
        theme(axis.line = element_blank(),
              panel.grid.major.y = element_blank(),
              legend.key = element_blank(),
              legend.position = "")
 })



  output$avgrate <- renderInfoBox({

    infoBox(
      value = predValue,
      color = "light-blue",
      title = "150 Day Forecasted Rating",
      icon = icon("line-chart")
    )

  })



  output$logodds <- renderPlot({
  
    word_ratios %>%
      group_by(logratio < 0) %>%
      top_n(15, abs(logratio)) %>%
      ungroup() %>%
      mutate(word = reorder(word, logratio)) %>%
      ggplot(aes(word, logratio, fill = logratio < 0)) +
      geom_col() +
      coord_flip() +
      theme_hc() +
      labs(x = NULL, y = "more likely") +
      scale_y_continuous(labels = c("8X", "6X", "4X", "2X", "Same", "2X", "4X", "6X", "8X"), breaks = seq(-4, 4)) +
      theme(legend.key = element_blank(), legend.position = "")
  })



  output$force <- renderForceNetwork({
  
    # bigram_data <- data %>%
      # unnest_tokens(bigram, Review, token = "ngrams", n = 2) %>%
      # separate(bigram, c("word1", "word2"), sep = " ")

    if (input$filter_stopwords == "no") {
      bigram_data <- data %>%
        unnest_tokens(bigram, Review, token = "ngrams", n = 2) %>%
        separate(bigram, c("word1", "word2"), sep = " ")
    } else if (input$filter_stopwords == "yes") {
      bigram_data <- data %>%
        unnest_tokens(bigram, Review, token = "ngrams", n = 2) %>%
        separate(bigram, c("word1", "word2"), sep = " ") %>%
        filter(!word1 %in% stop_words$word) %>%
        filter(!word2 %in% stop_words$word)
    }

    bg <- bigram_data %>%
      count(word1, word2, sort = TRUE) %>%
      filter(n > 3) %>%
      graph.data.frame(directed = TRUE)

    bigram_graph <- simplify(bg) 

    bg_wt <- cluster_walktrap(bigram_graph, steps = 6)

    bg_members <- membership(bg_wt)

    bg_list <- igraph_to_networkD3(bigram_graph, group = bg_members)

    bg_d3 <- forceNetwork(Links = bg_list$link, Nodes = bg_list$nodes,
                          Source = 'source', Target = 'target',
                          NodeID = 'name', Group = 'group',
                          zoom = TRUE, linkDistance = 70,
                          bounded = TRUE, opacity = 0.75,
                          opacityNoHover = FALSE, fontSize = 12,
                          fontFamily = "sans-serif")
  
  })

  
}


shinyApp(ui, server)
