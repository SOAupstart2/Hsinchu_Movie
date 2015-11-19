# Hsinchu_Movie[![Gem Version](https://badge.fury.io/rb/kandianying.svg)](https://badge.fury.io/rb/kandianying)[![Build Status](https://travis-ci.org/SOAupstart2/Hsinchu_Movie.svg)](https://travis-ci.org/SOAupstart2/Hsinchu_Movie)

https://rubygems.org/gems/kandianying

A simple Ruby Gem to get data from cinema websites in Hsinchu. Currently, we can get the film lists and show times given a vieshow cinema code.

## Installation

Run the following command:
```
gem install kandianying
```

### General usage notes
Currently, usage requires specifying a `theater_id` and `language`.
- For Vieshow cinemas, `theater_id` ranges from 1 to 14. For a cinema located in Hsinchu, use 5 or 12.
- For Ambassador cinemas, `theater_id codes` are unique. For the Ambassador cinema in Hsinchu, use 38897fa9-094f-4e63-9d6d-c52408438cb6
- For `language`, this has to be either 'chinese' or 'english'.

### Command line usage
```
kandianying vieshow <theater_id> # Development deprecated.
# This prints out cinema name with films on display and show times.
```

### Usage in ruby code
```
require 'kandianying'

vieshow_movie = HsinChuMovie::Vieshow.new(<theater_id>, <language>)
vieshow_movie.movie_names  # Returns array of film names
vieshow_movie.movie_table  # Returns Hash containing film names, dates, times
vieshow_movie.to_json  # Returns JSON array of movie_table
ambassador_movie = HsinChuMovie::Ambassador.new(<theater_id>, <language>)
ambassador_movie.movie_names  # Returns array of film names
ambassador_movie.movie_table  # Returns Hash containing film names, dates, times
ambassador_movie.to_json  # Returns JSON array of movie_table

# <film_name> is a string that is any part of the name of film.
vieshow_movie.film_times(film_name)
ambassador_movie.film_times(film_name)
# Returns Hash containing film viewing dates and times.

# <date_time> is string of the type 'MONTH DATE TIME' such as 'November 5 22:00'.
# Abbreviations such as 'Nov 5 22:00' would suffice.
# If the date is the same as the query date, you can simply use the time '22:00'
vieshow_movie.films_after_time(date_time)
ambassador_movie.films_after_time(date_time)
# Returns hash containing films on display after given time with start times
```

## License
Distributed under the [MIT License](LICENSE).
