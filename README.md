## Analyzing GOAT Sneaker App iTunes Reviews  

![overview](https://i.imgur.com/54h28Rr.jpg)

## Table of Contents
- [Data](#data)
- [Most Popular Words](#most-popular-words)
- [Term Frequency - Inverse Document Frequency](#term-frequency---inverse-document-frequency)
- [Sentiment Analysis](#sentiment-analysis)
- [Network Graphs](#network-graphs)

&nbsp;
## Data

- Utilize R package [itunesR](https://github.com/amrrs/itunesr)
    - Allows access to iTunes app data that isn't accessible in iTunes Connect
    - `problem`: need App Id number
    - `solution`: Apple exposes this information through an API endpoint that returns the answer in a JSON blob
    - Query: https://itunes.apple.com/search?term=goat&country=us&entity=software
    - `app id`: 966758561

- Reviews -> came in as Factors
    - review text was coming in as factors with all lines being added as levels
    - droplevels() -> didn't work
    - `solution`: write it to a CSV and re-import

&nbsp;
## Most Popular Words

![most_frequent_words](https://i.imgur.com/Zb8YAP8.png)

The `Avg. Review Rating` is the cumulative average rating for each review that the word appeared in. For instance, reviews containing the word `pair` had an average rating of 3.07, the lowest average rating of words in the Top 10 of usage.

Word | Avg. Review Rating
-- | --
app | 4.23
shoes | 3.72
goat | 3.92
shoe | 4.13
sneakers | 4.46
buy | 4.08
love | 4.80
pair | 3.07
easy | 4.68
prices | 4.76

&nbsp;
## Term Frequency - Inverse Document Frequency

Essentially, finding out which individual words are most unique to each given rating. TF (term fequency) is what it sounds like. However, the wrinkle comes in through the IDF (inverse document frequency).

> Tf-idf stands for term frequency-inverse document frequency, and the tf-idf weight is a weight often used in information retrieval and text mining. This weight is a statistical measure used to evaluate how important a word is to a document in a collection or corpus. The importance increases proportionally to the number of times a word appears in the document but is offset by the frequency of the word in the corpus. Variations of the tf-idf weighting scheme are often used by search engines as a central tool in scoring and ranking a document's relevance given a user query - [more here](http://www.tfidf.com/).

![tfidf](https://i.imgur.com/0oYd11t.jpg)

&nbsp;
## Sentiment Analysis

![words_sentiment](https://i.imgur.com/HZSj5IK.png)
![wordcloud](https://i.imgur.com/3B8oVVN.jpg)

&nbsp;
## Network Graphs

The first graph reveals high traffic connections in app reviews without stop words. The second graph includes them, thus the noise. However, you can select on a node and the background will become somewhat opaque. It's interesting to see all of the various connections and what individual words standout as hubs. Admittedly, it's more for style points than actual value.  

[🚨 INTERACTIVE LIVE VERSION 🚨](http://baby-network.bitballoon.com)

![static_visual](https://i.imgur.com/nlhhXyg.png)  

&nbsp;
[🔥 INTERACTIVE LIVE VERSION 🔥](http://d3-bigram-network.bitballoon.com/)

![static_viz](https://i.imgur.com/LNewaPT.png)