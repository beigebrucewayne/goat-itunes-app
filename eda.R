library(tidyverse)
library(ggthemes)
library(tidytext)

data  <- read_csv("./app_reviews.csv")

review_words  <- data %>%
  unnest_tokens(word, Review) %>%
  count(word, sort = TRUE)

data(stop_words)

# remove stop words -> the, of, to
review_words  <- review_words %>%
  anti_join(stop_words)

data_reviews <- data %>%
  unnest_tokens(word, Review) %>%
  group_by(word) %>%
  mutate(Avg_Review = mean(Rating))

review_words %>%
  filter(n > 10) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(aes(fill = n), show.legend = FALSE) +
  labs(title = "Most Used Words: GOAT App Reviews",
       subtitle = "Not including stop words (the, to, a, etc..)",
       x = "# of Appearances") +
  theme_fivethirtyeight() +
  coord_flip()

perfect_5 <- data_reviews %>% filter(Avg_Review == 5)
