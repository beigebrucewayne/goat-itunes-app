library(tidyverse)
library(ggthemes)
library(tidytext)

data  <- read_csv("./app_reviews.csv")
big_data  <- read_csv("./big_data_reviews.csv")

# count words

count_words <- big_data %>%
  select(-date) %>%
  unnest_tokens(word, review) %>%
  anti_join(stop_words) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na() %>%
  count(word, sort = TRUE)

# words

review_words  <- big_data %>%
  select(-date) %>%
  unnest_tokens(word, review) %>%
  anti_join(stop_words) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na()

# graphing word counts

count_words %>%
  filter(n > 10) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(aes(fill = "darkunica"), show.legend = FALSE) +
  labs(title = "Most Used Words: GOAT App Reviews",
       subtitle = "Not including stop words (the, to, a, etc..)",
       y = "count") +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  theme(axis.text.y = element_text(colour = '#FFFFFF'),
        panel.grid.major.y = element_line(colour = '#2A2A2B')) +
  coord_flip()

### word avg ratings

word_freq <- big_data %>%
  unnest_tokens(word, review) %>%
  anti_join(stop_words) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na() %>%
  group_by(word) %>%
  mutate(avg_rating = mean(rating))

### Most Common + / - words

word_sentiments <- review_words %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  ungroup()

word_sentiments %>%
  group_by(sentiment) %>%
  top_n(10) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(title = "Most Used Positive / Negative Words: GOAT App Reviews",
       y = "count") +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  theme(axis.text.y = element_text(colour = '#FFFFFF'),
        panel.grid.major.y = element_line(colour = '#2A2A2B')) +
  coord_flip()

# word cloud

library(reshape2)
library(wordcloud)

word_cloud <- review_words %>%
  inner_join(get_sentiments("bing")) %>%
  count(word, sentiment, sort = TRUE) %>%
  acast(word ~ sentiment, value.var = "n", fill = 0) %>%
  comparison.cloud(colors = c("#F8766D", "#00BFC4"),
                   max.words = 300,
                   random.order = TRUE,
                   rot.per = .2)


# 1 star reviews
