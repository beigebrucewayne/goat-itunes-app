![logo](https://images.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.businessofapps.com%2Fwp-content%2Fuploads%2F2016%2F08%2FGOAT-logo.png&f=1)

## Analyzing iTunes App Reviews for GOAT Sneaker App

### Data

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

### Overview

- Most Frequent Words In Review  

![most_frequent_words](https://i.imgur.com/xmbNtga.png)

The `Avg. Review Rating` is the cumulative average rating for each review that the word appeared in. For instance, reviews containing the word `seller` had an average rating of 2.81, the lowest average rating of words in the Top 10 of usage.

Word | Avg. Review Rating
-- | --
app | 3.65
shoes | 3.13
goat | 3.39
pair | 2.81
shoe | 3.52
seller | 2.32
price | 3.48
bought | 3.48
sneakers | 3.52
buy | 3.00

- Most Frequent Words + Sentiment

![words_sentiment](https://i.imgur.com/PxXMBm3.png)
![wordcloud](https://i.imgur.com/hC5grpJ.jpg)