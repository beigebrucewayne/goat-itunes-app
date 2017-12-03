library(tidyverse)
library(ggthemes)
library(tidytext)

data  <- read_csv("./app_reviews.csv")

# count words
count_words <- data %>%
  unnest_tokens(word, Review) %>%
  anti_join(stop_words) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na() %>%
  count(word, sort = TRUE)

review_words  <- data %>%
  unnest_tokens(word, Review) %>%
  anti_join(stop_words) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na()

data_reviews <- data %>%
  unnest_tokens(word, Review) %>%
  group_by(word) %>%
  mutate(Avg_Review = mean(Rating))

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

### word frequencies

word_freq <- data %>%
  unnest_tokens(word, Review) %>%
  anti_join(stop_words) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na() %>%
  group_by(word) %>%
  mutate(Avg_Rating = mean(Rating))

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
