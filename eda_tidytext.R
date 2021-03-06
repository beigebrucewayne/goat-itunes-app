library(tidyverse)
library(scales)
library(ggthemes)
library(tidytext)

big_data  <- read_csv("./data/app_reviews.csv")

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
  top_n(25) %>%
  ggplot(aes(word, n)) +
  geom_col(aes(fill = "darkunica"), show.legend = FALSE) +
  labs(title = "Top 25 Most Used Words",
       subtitle = "Not including stop words (the, to, a, etc..)",
       y = "count") +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  theme(axis.text.y = element_text(colour = '#FFFFFF'),
        panel.grid.major.y = element_line(colour = '#2A2A2B')) +
  coord_flip()

### word avg ratings

word_freq <- big_data %>%
  select(-date) %>%
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
  top_n(15) %>%
  ungroup() %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n, fill = sentiment)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~sentiment, scales = "free_y") +
  labs(title = "Most Used Negative / Positive Words",
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
                   max.words = 310,
                   random.order = TRUE,
                   rot.per = .2)


# 1 star reviews

one_star <- word_freq %>%
  filter(avg_rating == 1) %>%
  group_by(word) %>%
  count(word, sort = TRUE) %>%
  ungroup() %>%
  top_n(15) %>%
  mutate(word = reorder(word, n)) %>%
  ggplot(aes(word, n)) +
  geom_col(aes(fill = "darkunica"), show.legend = FALSE) +
  labs(title = "Most Used Words In 1 Star Reviews",
       subtitle = "Not including stop words (the, to, a etc...)",
       y = "count") +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  theme(axis.text.y = element_text(colour = '#FFFFFF'),
        panel.grid.major.y = element_line(colour = '#2A2A2B')) +
  coord_flip()


# trigram

trigram <- big_data %>%
  select(-date) %>%
  unnest_tokens(trigram, review, token = "ngrams", n = 3) %>%
  group_by(trigram) %>%
  mutate(avg_rating = mean(rating)) %>%
  count(trigram, avg_rating, sort = TRUE) %>%
  filter(avg_rating < 2) %>%
  arrange(avg_rating)

rating_sentiment <- big_data %>%
  select(-date) %>%
  unnest_tokens(bigram, review, token = "ngrams", n = 2) %>%
  group_by(bigram) %>%
  top_n(10) %>%
  count(bigram, rating, sort = TRUE) %>%
  ungroup() %>%
  mutate(bigram = reorder(bigram, n)) %>%
  ggplot(aes(bigram, n)) +
  geom_col(show.legend = FALSE) +
  facet_wrap(~rating, scales = "free_y") +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  coord_flip()

# network graph

library(igraph)
library(networkD3)

bigram <- big_data %>%
  unnest_tokens(bigram, review, token = "ngrams", n = 2) %>%
  separate(bigram, c("word1", "word2"), sep = " ")

# bigram_filtered <- bigram %>%
  # filter(!word1 %in% stop_words$word) %>%
  # filter(!word2 %in% stop_words$word)

# bigram_counts <- bigram_filtered %>%
bigram_counts <- bigram %>%
  count(word1, word2, sort = TRUE)

bigram_graph <- bigram_counts %>%
  filter(n > 3) %>%
  graph.data.frame(directed = TRUE)

bigram_graph  <- simplify(bigram_graph)

bg_wt <- cluster_walktrap(bigram_graph, steps = 25)

bg_members <- membership(bg_wt)

bg_list <- igraph_to_networkD3(bigram_graph, group = bg_members)

bg_d3 <- forceNetwork(Links = bg_list$link, Nodes = bg_list$nodes,
             Source = 'source', Target = 'target',
             NodeID = 'name', Group = 'group',
             zoom = TRUE, linkDistance = 70,
             bounded = TRUE, opacity = 0.75,
             opacityNoHover = FALSE, fontSize = 12,
             fontFamily = "sans-serif")


# pairwise correlations
library(widyr)

bad_words <- big_data %>%
  unnest_tokens(word, review) %>%
  select(rating, word) %>%
  filter(!word %in% stop_words$word)

word_pairs <- bad_words %>%
  pairwise_count(word, rating, sort = TRUE)

word_cors <- bad_words %>%
  group_by(word) %>%
  filter(n() >= 20) %>%
  pairwise_cor(word, rating, sort = TRUE) %>%
  drop_na()

word_cors %>%
  filter(item1 %in% c("buy", "love", "waited", "terrible")) %>%
  group_by(item1) %>%
  top_n(3) %>%
  ungroup() %>%
  mutate(item2 = reorder(item2, correlation)) %>%
  ggplot(aes(item2, correlation)) +
  geom_bar(stat = "identity") +
  facet_wrap(~ item1, scales = "free") +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  coord_flip()


count_words <- big_data %>%
  select(-date) %>%
  unnest_tokens(word, review) %>%
  anti_join(stop_words) %>%
  mutate(word = str_extract(word, "[a-z']+")) %>%
  drop_na() %>%
  count(word, rating, sort = TRUE)

words_tf_idf <- count_words %>%
  bind_tf_idf(word, rating, n) %>%
  arrange(desc(tf_idf)) %>%
  mutate(word = factor(word, levels = rev(unique(word))))

words_tf_idf %>%
  group_by(rating) %>%
  top_n(15) %>%
  ungroup %>%
  ggplot(aes(word, tf_idf, fill = as.character(rating))) +
  geom_col(show.legend = FALSE) +
  labs(title = "Highest tf-idf Words In Each Rating",
       subtitle = "tf-idf formula -> tfidf(t, d, D) = tf(t, d) · idf(t, D)",
       x = "words",
       y = "tf-idf score") +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  facet_wrap(~rating, ncol = 5, scales = "free") +
  coord_flip()

# frequency

library(tidyr)

frequency <- big_data %>%
  unnest_tokens(word, review) %>%
  group_by(rating) %>%
  count(word, sort = TRUE) %>%
  left_join(big_data %>%
            group_by(rating) %>%
            summarise(total = n())) %>%
  mutate(freq = n / total)

frequency  <- frequency %>%
  select(rating, word, freq) %>%
  spread(rating, freq) %>%
  select(word, `5`, `1`) %>%
  arrange(`5`, `1`)

ggplot(frequency, aes(`5`, `1`)) +
  geom_jitter(alpha = 0.1, size = 2, width = 0.1, height = 0.1) +
  geom_text(aes(label = word, color = 'white'), check_overlap = TRUE, vjust = 1.5) +
  scale_x_log10(labels = percent_format()) +
  scale_y_log10(labels = percent_format()) +
  geom_abline(colour = 'white') +
  labs(title = "Word Frequency by Rating",
       subtitle = "Which words are more likely to appear in which rating",
       y = "more likely used in 1 star review",
       x = "more likely used in 5 star review") +
  theme_hc(bgcolor = "darkunica") +
  theme(axis.line = element_blank(),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        legend.key = element_blank(),
        legend.position = "",
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        panel.grid.minor = element_blank())

# word ratios

word_ratios  <- big_data %>%
  unnest_tokens(word, review) %>%
  count(word, rating) %>%
  filter(sum(n) >= 10) %>%
  ungroup() %>%
  spread(rating, n, fill = 0) %>%
  select(word, `5`, `1`) %>%
  mutate_if(is.numeric, funs((. + 1) / sum(. + 1))) %>%
  mutate(logratio = log(`5` / `1`)) %>%
  arrange(desc(logratio))

# most distinct words each rating

word_ratios %>%
  group_by(logratio < 0) %>%
  top_n(15, abs(logratio)) %>%
  ungroup() %>%
  mutate(word = reorder(word, logratio)) %>%
  ggplot(aes(word, logratio, fill = logratio < 0)) +
  geom_col() +
  coord_flip() +
  labs(title = "Comparing Odds Ratios",
       subtitle = "Distinct 5 Star Words vs 1 Star Words",
       y = "log odds ratio (5 rating / 1 rating)") +
  scale_fill_discrete(name = "", labels = c("5", "1")) +
  theme_hc(bgcolor = "darkunica") +
  scale_fill_hc("darkunica") +
  theme(axis.line = element_blank(),
        legend.title = element_blank(),
        panel.grid.major = element_blank(),
        legend.key = element_blank(),
        legend.position = "",
        panel.grid.major.y = element_blank(),
        panel.border = element_blank(),
        axis.text.y = element_text(colour = '#FFFFFF'),
        panel.grid.minor = element_blank())
