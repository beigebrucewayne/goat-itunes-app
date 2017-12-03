## Analyzing GOAT Sneaker App iTunes Reviews  

![overview](https://images.duckduckgo.com/iu/?u=http%3A%2F%2Fkicksaddict.com%2Fwp-content%2Fuploads%2F2015%2F06%2FGOAT-screenshot-set-1.png&f=1)

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

- Reviews -> weird characters
    - clean text using regex
    - `str_extract(word, "[a-z']+")`

&nbsp;
## Word Frequency

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

![bad_words](https://i.imgur.com/DCcgZNH.png)

&nbsp;
## Sentiment Analysis

![words_sentiment](https://i.imgur.com/HZSj5IK.png)
![wordcloud](https://i.imgur.com/3B8oVVN.jpg)

&nbsp;
## Network Graph

The first graph reveals high traffic connections in app reviews without stop words. The second graph includes them, thus the noise. However, you can select on a node and the background will become somewhat opaque. It's interesting to see all of the various connections and what individuals words standout as hubs. Admittedly, it's more for style points than actual value.  

[🚨 INTERACTIVE LIVE VERSION 🚨](http://baby-network.bitballoon.com)

![static_visual](https://i.imgur.com/nlhhXyg.png)  

&nbsp;
[🔥 INTERACTIVE LIVE VERSION 🔥](http://d3-bigram-network.bitballoon.com/)

![static_viz](https://i.imgur.com/LNewaPT.png)