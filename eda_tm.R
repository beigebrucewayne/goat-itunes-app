library(tidyverse)
library(corpus)
library(tm)
library(tidytext)

data <- read_csv('./data/app_reviews.csv')
docs <- as.vector(data$review)
docs <- enc2utf8(docs)
docs <- lapply(docs, utf8_encode)

goat <- VCorpus(VectorSource(docs))

goat <- tm_map(goat, content_transformer(tolower))
goat <- tm_map(goat, stripWhitespace)
goat <- tm_map(goat, removePunctuation)
goat <- tm_map(goat, removeNumbers)

myStopwords <- c(stopwords('english'))
idx <- which(myStopwords == 'r')
myStopwords <- myStopwords[-idx]
goat <- tm_map(goat, removeWords, myStopwords)

dictCorpus <- goat

goat <- tm_map(goat, stemDocument)
goat <- tm_map(goat, stemCompletion, dictionary = dictCorpus)

myDtm <- DocumentTermMatrix(goat, control = list(minWordLength = 2))
