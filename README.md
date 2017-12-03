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

- Most Frequent Words In Review  

![most_frequent_words](https://i.imgur.com/UkXcKJx.png)

The `Avg. Review Rating` is the cumulative average rating for each review that the word appeared in. For instance, reviews containing the word `pair` had an average rating of 2.81, the lowest average rating of words in the Top 10 of usage.

Word | Avg. Review Rating
-- | --
app | 4.22
shoes | 3.64
goat | 3.90
shoe | 4.07
sneakers | 4.34
buy | 4.00
love | 4.78
pair | 2.81
price | 3.84
sell | 3.68

- Most Used Words: 1 Star Reviews

![bad_words](https://i.imgur.com/YHb1dem.png)

&nbsp;
## Sentiment Analysis

- Most Frequent Words + Sentiment

![words_sentiment](https://i.imgur.com/eqiWgSn.png)
![wordcloud](https://i.imgur.com/M11cXKn.jpg)