library(itunesr)
library(tidyquant)
library(sweep)
library(tidytext)
library(tidyverse)
library(igraph)
library(ggraph)
library(forecast)
library(tibbletime)
library(timetk)

gr1 <- getReviews(966758561, 'us', 1)
gr2 <- getReviews(966758561, 'us', 2)
gr3 <- getReviews(966758561, 'us', 3)
gr4 <- getReviews(966758561, 'us', 4)
gr5 <- getReviews(966758561, 'us', 5)
gr6 <- getReviews(966758561, 'us', 6)
gr8 <- getReviews(966758561, 'us', 8)
gr9 <- getReviews(966758561, 'us', 9)
gr10 <- getReviews(966758561, 'us', 10)
gr11 <- getReviews(966758561, 'gb', 1)
gr12 <- getReviews(966758561, 'gb', 2)
gr13 <- getReviews(966758561, 'ca', 1)
gr14 <- getReviews(966758561, 'ca', 2)
gr15 <- getReviews(966758561, 'ca', 3)
gr16 <- getReviews(966758561, 'ca', 4)

gr <- data.frame()
gr <- rbind(gr, gr1, gr2, gr3, gr4, gr5, gr6, gr8, gr9, gr10, gr11, gr12, gr13, gr14, gr15, gr16)

gr <- data.frame(lapply(gr, as.character), stringsAsFactors =  FALSE)

gr <- tibble::as_tibble(gr)

data <- read_csv('~/Desktop/goat-tunes/data/local_data.csv')

count_bigrams <- function(dataset) {

  dataset %>%
    unnest_tokens(bigram, Review, token = "ngrams", n = 2) %>%
    separate(bigram, c("word1", "word2"), sep = " ") %>%
    filter(!word1 %in% stop_words$word,
           !word2 %in% stop_words$word) %>%
    count(word1, word2, sort = TRUE)

}

visualize_bigrams <- function(bigrams) {
  
  set.seed(2017)
  a <- grid::arrow(type = "closed", length = unit(.15, "inches"))
  
  bigrams %>%
    graph_from_data_frame() %>%
    graph(layoout = "fr") +
    geom_edge_link(aes(edge_alpha = n), show.legend = FALSE, arrow = a) +
    geom_node_point(color = "light-blue", size = 5) +
    geom_node_text(aes(label = name), vjust = 1, hjust = 1) +
    theme_hc()
}


bigram_data <- data %>%
  count_bigrams()


g_bigrams <- bigram_data %>%
  filter(n > 3,
         !str_detect(word1, "\\d"),
         !str_detect(word2, "\\d")) %>%
  visualize_bigrams()



t <- data %>%
  unnest_tokens(word, Review) %>%
  group_by(Rating) %>%
  count(word, sort = TRUE) %>%
  anti_join(stop_words) %>%
  left_join(data %>%
            group_by(Rating) %>%
            summarise(total = n())) %>%
  mutate(freq = n / total) %>%
  arrange(desc(freq))

h_data <- data %>%
  unnest_tokens(word, Review)

h_data <- summarize(group_by(h_data, word), mean(Rating)) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na() %>%
  filter(nchar(word) > 2) %>%
  count(word, `mean(Rating)`, sort = TRUE) %>%
  arrange(desc(n))

class(gr[['Rating']]) <- "numeric"

data <- gr %>% separate("Date", c("Date", "Drop"), sep = " ")
  # mutate(Month = format(as.Date(Date), "%m"), Year = format(as.Date(Date), "%y"))
  # filter(Year == '17')
  # select(-Drop) %>%
  # arrange(desc(as.Date(Date)))
  # filter(Year == '17')

# t <- summarize(group_by(data, Month), mean(Rating))
t <- summarize(group_by(data, Date), mean(Rating))

# class(t[['Month']]) <- "date"

t <- t %>% rename(Avg_Rating = `mean(Rating)`)

t <- t %>% mutate(Date = as.Date(Date))

# t <- t %>% as_tbl_time(index = Month)
t <- t %>% as_tbl_time(index = Date)

t <- tk_ts(t, start = 1, frequency = 30)

fit_arima <- auto.arima(t)

fcast_arima <- forecast(fit_arima, h = 100)

fcast_tbl <- sw_sweep(fcast_arima, timetk_idx = TRUE)

actual_tbl <- fcast_tbl %>% filter(key == "actual")

fcast_tbl %>%
  ggplot(aes(x = index, y = Avg_Rating, color = key)) +
    geom_ribbon(aes(ymin = lo.95, ymax = hi.95), fill = '#D5DBFF', color = NA, size = 0) +
    geom_ribbon(aes(ymin = lo.80, ymax = hi.80), fill = '#596DD5', color = NA, size = 0, alpha = 0.8) +
    geom_line() +
    geom_point() +
    geom_line(aes(x = index, y = Avg_Rating), data = actual_tbl) +
    geom_line(aes(x = index, y = Avg_Rating), data = actual_tbl) +
    geom_ma(ma_fun = EMA, n = 30, size = 1, color = 'white', linetype = 1) +
    geom_ma(ma_fun = EMA, n = 90, size = 3, color = 'grey61', linetype = 1) +
    theme_hc(bgcolor = "darkunica") +
    labs(x = NULL,
         y = "avg. app rating") +
    theme(axis.line = element_blank(),
          panel.grid.major.y = element_blank())
