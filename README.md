## Analyzing iTunes App Reviews for GOAT Sneaker App

### Getting Data

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

### Overview

- Most Frequent Words In Review  

![most_frequent_words](https://i.imgur.com/ErCtmQ7.png)

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

